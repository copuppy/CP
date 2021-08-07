// SPDX-License-Identifier: MIT

pragma solidity ^0.6.9;

import "@openzeppelin/contracts/proxy/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./FTokenInterface.sol";

contract SavingsPool is Initializable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    address public governance;

    uint public constant initialMiningIndex = 1e18;
    uint public constant day7Seconds = 604800;
    uint public constant day14Seconds = day7Seconds * 2;
    uint public constant day30Seconds = 2592000;
    uint public constant day90Seconds = day30Seconds * 3;
    uint public constant day180Seconds = day30Seconds * 6;


    // mining related
    uint public miningIndex;
    uint public miningBlock;
    uint public startBlock;
    address public miningToken;
    mapping(address => uint) saverMiningIndex;
    mapping(address => uint) saverMiningAccrued;

    address public underlyingAsset;
    address public fToken;
    uint public miningSpeed;

    mapping(address => uint) public depositTime;
    mapping(uint => uint) public redeemFeeConfig;
    uint public feeAmount;
    uint public totalFee;

    mapping(address => uint) fTokenBalances;

    event Deposit(address owner, uint amount, uint fTokenChange);
    event Redeemed(address owner, uint amount, uint redeemFee, uint amountWithoutFee, uint fTokenChange);
    event Claimed(address owner, address miningToken, uint amount);
    event NewGovernance(address oldGovernance, address newGovernance);
    event NewMiningSpeed(uint oldMiningSpeed, uint newMiningSpeed);
    event NewRedeemFee(uint timeDelta, uint oldFeeRate, uint newFeeRate);

    modifier onlyGovernance() {
        require(msg.sender == governance, "Not governance");
        _;
    }

    modifier mine() {
        updateMiningIndex();
        distributeMining();
        _;
    }

    bool private _status; 

    modifier nonReentrant() {
        require(!_status, 'reentrant call'); _status = true;
        _;
        _status = false; 
    }

    function initialize(address _fToken, address _governance) initializer public {
        require(_fToken != address(0), "_fToken is zero address"); 
        require(_governance != address(0), "_governance is zero address");

        fToken = _fToken;
        underlyingAsset = FTokenInterface(fToken).underlying();
        governance = _governance;
        redeemFeeConfig[day7Seconds] = 50;
        redeemFeeConfig[day14Seconds] = 40;
        redeemFeeConfig[day30Seconds] = 30;
        redeemFeeConfig[day90Seconds] = 20;
        redeemFeeConfig[day180Seconds] = 10;
    }

    function deposit(uint depositAmount) nonReentrant mine external {
        require(depositAmount > 0, "deposit amount should > 0");
        depositTime[msg.sender] = block.timestamp;

        IERC20(underlyingAsset).safeTransferFrom(msg.sender, address(this), depositAmount);

        uint fTokenAmountBeforeDeposit = IERC20(fToken).balanceOf(address(this));
        IERC20(underlyingAsset).approve(fToken, depositAmount);
        uint error = FTokenInterface(fToken).mint(depositAmount);
        require(error == 0, "Error to mint fToken");
        uint fTokenAmountAfterDeposit = IERC20(fToken).balanceOf(address(this));
        uint fTokenAmountChange = fTokenAmountAfterDeposit.sub(fTokenAmountBeforeDeposit);

        fTokenBalances[msg.sender] = fTokenBalances[msg.sender].add(fTokenAmountChange);

        emit Deposit(msg.sender, depositAmount, fTokenAmountChange);
    }

    function redeem(uint redeemAmount) nonReentrant mine external {
        require(fTokenBalances[msg.sender] > 0, "Balance should > 0");
        require(redeemAmount > 0, "Redeem amount should > 0");

        uint fTokenAmountBeforeRedeem = IERC20(fToken).balanceOf(address(this));
        uint error = FTokenInterface(fToken).redeemUnderlying(redeemAmount);
        require(error == 0, "Error to redeem");
        uint fTokenAmountAfterRedeem = IERC20(fToken).balanceOf(address(this));
        uint fTokenAmountChange = fTokenAmountBeforeRedeem.sub(fTokenAmountAfterRedeem);

        require(fTokenBalances[msg.sender] >= fTokenAmountChange, "fTokenBalance is not enough to redeem");
        fTokenBalances[msg.sender] = fTokenBalances[msg.sender].sub(fTokenAmountChange);

        uint redeemFee = calculateFee(msg.sender, redeemAmount);
        uint actualRedeem = redeemAmount.sub(redeemFee);
        feeAmount = feeAmount.add(redeemFee);
        totalFee = totalFee.add(redeemFee);
        IERC20(underlyingAsset).safeTransfer(msg.sender, actualRedeem);

        emit Redeemed(msg.sender, redeemAmount, redeemFee, actualRedeem, fTokenAmountChange);
    }

    function calculateFee(address saver, uint redeemAmount) public view returns(uint) {
        uint timeDelta = block.timestamp - depositTime[saver];
        uint feeRate = getFeeRate(timeDelta);
        return redeemAmount.mul(feeRate).div(100);
    }

    function getFeeRate(uint timeDelta) public view returns(uint) {
        if (timeDelta < day7Seconds) return redeemFeeConfig[day7Seconds];
        if (timeDelta < day14Seconds) return redeemFeeConfig[day14Seconds];
        if (timeDelta < day30Seconds) return redeemFeeConfig[day30Seconds];
        if (timeDelta < day90Seconds) return redeemFeeConfig[day90Seconds];
        if (timeDelta < day180Seconds) return redeemFeeConfig[day180Seconds];
        return 0;
    }

    function updateFeeRate(uint timeDelta, uint newFeeRate) public onlyGovernance {
        require(timeDelta == day7Seconds || 
                timeDelta == day14Seconds || 
                timeDelta == day30Seconds || 
                timeDelta == day90Seconds || 
                timeDelta == day180Seconds, "Invalid timeDelta");
        uint oldFeeRate = redeemFeeConfig[timeDelta];
        redeemFeeConfig[timeDelta] = newFeeRate;

        emit NewRedeemFee(timeDelta, oldFeeRate, newFeeRate);
    }

    function redeemAll() nonReentrant external {
        require(fTokenBalances[msg.sender] > 0, "Balance should > 0");
        uint tokenBalance = tokenBalanceOf(msg.sender);
        uint fTokenBalance = fTokenBalances[msg.sender];
        fTokenBalances[msg.sender] = 0;
        uint error = FTokenInterface(fToken).redeem(fTokenBalance);
        require(error == 0, "Error to redeem");

        uint redeemFee = calculateFee(msg.sender, tokenBalance);
        uint actualRedeem = tokenBalance.sub(redeemFee);
        feeAmount = feeAmount.add(redeemFee);
        totalFee = totalFee.add(redeemFee);

        IERC20(underlyingAsset).safeTransfer(msg.sender, actualRedeem);

        emit Redeemed(msg.sender, tokenBalance, redeemFee, actualRedeem, fTokenBalance);
    }

    function claimRedeemFee(address feeReceiver, uint amount) public onlyGovernance {
        require(feeAmount >= amount, "No enough fee left");
        feeAmount = feeAmount.sub(amount);
        IERC20(underlyingAsset).safeTransfer(feeReceiver, amount);
    }

    function claimAllRedeemFee() public onlyGovernance {
        require(feeAmount > 0, "No enough fee left");
        feeAmount = 0;
        IERC20(underlyingAsset).safeTransfer(governance, feeAmount);
    }

    function claimMiningToken(address tokenHolder) nonReentrant mine public {
        uint miningTokenAmount = saverMiningAccrued[tokenHolder];
        if (miningTokenAmount == 0) return;
        saverMiningAccrued[tokenHolder] = 0;
        IERC20(miningToken).safeTransfer(tokenHolder, miningTokenAmount);

        emit Claimed(tokenHolder, miningToken, miningTokenAmount);
    }

    function claimFilda(address receiver) public {
        if (receiver != governance) {
            require(msg.sender == governance, "Not governance");
        }

        address comtrollerAddr = FTokenInterface(fToken).comptroller();
        ComtrollerInterface comtroller = ComtrollerInterface(comtrollerAddr);
        address[] memory holders = new address[](1);
        holders[0] = address(this);
        address[] memory fTokens = new address[](1);
        fTokens[0] = fToken;
        comtroller.claimComp(holders, fTokens, false, true);

        address fildaAddr = comtroller.getCompAddress();
        uint fildaAmount = IERC20(fildaAddr).balanceOf(address(this));
        IERC20(fildaAddr).transfer(receiver, fildaAmount);
    }

    function claimFilda() public {
        claimFilda(governance);
    }

    function fTokenBalanceOf(address owner) external view returns(uint) {
        return fTokenBalances[owner];
    }

    function tokenBalanceOf(address owner) public returns(uint) {
        uint exchangeRateCurrent = FTokenInterface(fToken).exchangeRateCurrent();
        uint balance = fTokenBalances[owner].mul(exchangeRateCurrent).div(1e18);
        return balance;
    }

    function storedTokenBalanceOf(address owner) view external returns(uint) {
        uint exchangeRateCurrent = FTokenInterface(fToken).exchangeRateStored();
        uint balance = fTokenBalances[owner].mul(exchangeRateCurrent).div(1e18);
        return balance;
    }

    function totalBalance() public returns(uint) {
        return FTokenInterface(fToken).balanceOfUnderlying(address(this));
    }

    function updateMiningIndex() internal {
        uint blockNumber = block.number;
        uint deltaBlocks = blockNumber - miningBlock;
        if (deltaBlocks > 0 && miningSpeed > 0 && miningBlock > 0) {
            uint totalFTokenBalance = FTokenInterface(fToken).balanceOf(address(this));
            uint miningAccrued = deltaBlocks.mul(miningSpeed);
            uint ratio = totalFTokenBalance > 0 ? miningAccrued.mul(1e18).div(totalFTokenBalance) : 0;
            miningIndex = miningIndex.add(ratio);
        }
        miningBlock = blockNumber;
    }

    function distributeMining() internal {
        uint currentSaverMiningIndex = saverMiningIndex[msg.sender];
        saverMiningIndex[msg.sender] = miningIndex;

        if (currentSaverMiningIndex == 0 && miningIndex > 0) {
            currentSaverMiningIndex = initialMiningIndex;
        }

        if (currentSaverMiningIndex > 0) {
            uint deltaIndex = miningIndex.sub(currentSaverMiningIndex);
            uint saverFTokens = fTokenBalances[msg.sender];
            uint saverDelta = saverFTokens.mul(deltaIndex).div(1e18);
            saverMiningAccrued[msg.sender] = saverMiningAccrued[msg.sender].add(saverDelta);
        }
    }

    function miningBalanceStore(address saver) view public returns(uint) {
        return saverMiningAccrued[saver];
    }

    function miningBalanceCurrent(address saver) mine public returns(uint) {
        return saverMiningAccrued[saver];
    }

    function setGovernance(address newGovernance) public onlyGovernance {
        require(newGovernance != address(0), "newGovernance is zero address");

        address oldGovernance = governance;
        governance = newGovernance;

        emit NewGovernance(oldGovernance, newGovernance);
    }

    function setMiningSpeed(uint newMiningSpeed) public onlyGovernance {
        uint oldMiningSpeed = miningSpeed;
        miningSpeed = newMiningSpeed;

        emit NewMiningSpeed(oldMiningSpeed, newMiningSpeed);
    }

    function startMining(address _miningToken, uint _startBlock, uint _miningSpeed) public onlyGovernance {
        require(_miningToken != address(0), "_miningToken is zero address");

        miningToken = _miningToken;
        miningIndex = initialMiningIndex;
        miningBlock = startBlock = _startBlock;
        miningSpeed = _miningSpeed;
    }
}