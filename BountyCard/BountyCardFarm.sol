// SPDX-License-Identifier: UNLICENSED
pragma solidity = 0.6.12;
pragma experimental ABIEncoderV2;

interface CPNFT{
    function mintAndSet(address d, uint256[] memory _val) external returns(uint256);
    function getCPPriceOfBUSD() external view returns(uint256);
    function Props(uint256 tokenId) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256);
    function setNFTProp(uint256 tokenId, uint8 _index, uint256 _val) external;
    function setNFTPropWithoutEvent(uint256 tokenId, uint8 _index, uint256 _val) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function burn(uint256 tokenId) external;
    function cardStringValSlot1Map(uint256 tokenId) external view returns(string memory);
    function setHouseName(uint256 tokenId,string memory _name,bool needEvent) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function mint(address account, uint amount) external;

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IRandomBack{
    function produce(uint256 systemType,uint256 length,uint256[] memory info,address userAddr) external;
    function consume(string[] memory seed,address userAddr) external;
}
interface ICakeLPFarm {
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
}

contract BountyCardFun {
    using SafeMath for uint256;
    address payable owner;
    CPNFT nft;
    IERC20 USDT;
    IERC20 CP;
    bool public pause;
    bool private _status; 
    mapping(address => uint256) public freeTimes;
    mapping(address => string[]) public seeds;
    mapping(address => uint256) public pendingCount;
    mapping(address => bool) public opers;
    mapping(uint256 => uint256) public picIdSecondRewardMap;
    mapping(uint256 => uint256) public picIdSecondMap;
    
    function initialize() public {
        require(msg.sender == 0xaEA6B356954A24de0eaDb626db36068bC752CC7d, 'not owner');
        owner = msg.sender;
        nft = CPNFT(0x746070Ef5f8c63b7EF13D1E4447490430aC3c3DD);
        USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        CP = IERC20(0x82C19905B036bf4E329740989DCF6aE441AE26c1);
        
        picIdSecondRewardMap[100001]=uint256(5e18)/5/3600/24;
        picIdSecondRewardMap[100002]=uint256(108e18)/30/3600/24;
        picIdSecondRewardMap[100003]=uint256(108e18)/30/3600/24;
        picIdSecondRewardMap[100004]=uint256(108e18)/30/3600/24;
        picIdSecondRewardMap[100005]=uint256(108e18)/30/3600/24;
        picIdSecondRewardMap[100006]=uint256(120e18)/30/3600/24;
        picIdSecondRewardMap[100007]=uint256(120e18)/30/3600/24;
        picIdSecondRewardMap[100008]=uint256(120e18)/30/3600/24;
        picIdSecondRewardMap[100009]=uint256(120e18)/30/3600/24;
        picIdSecondRewardMap[100010]=uint256(135e18)/30/3600/24;
        picIdSecondRewardMap[100011]=uint256(135e18)/30/3600/24;
        picIdSecondRewardMap[100012]=uint256(135e18)/30/3600/24;
        picIdSecondRewardMap[100013]=uint256(135e18)/30/3600/24;
        
        picIdSecondRewardMap[100014]=uint256(600e18)/60/3600/24;
        picIdSecondRewardMap[100015]=uint256(300e18)/60/3600/24;
        picIdSecondRewardMap[100016]=uint256(360e18)/60/3600/24;
        picIdSecondRewardMap[100017]=uint256(420e18)/60/3600/24;
        
        picIdSecondRewardMap[21001]=uint256(30e18)/30/3600/24;
        picIdSecondRewardMap[21002]=uint256(45e18)/30/3600/24;
        picIdSecondRewardMap[21003]=uint256(120e18)/60/3600/24;
        
        
        picIdSecondMap[100001]=5*3600*24;
        picIdSecondMap[100002]=30*3600*24;
        picIdSecondMap[100003]=30*3600*24;
        picIdSecondMap[100004]=30*3600*24;
        picIdSecondMap[100005]=30*3600*24;
        picIdSecondMap[100006]=30*3600*24;
        picIdSecondMap[100007]=30*3600*24;
        picIdSecondMap[100008]=30*3600*24;
        picIdSecondMap[100009]=30*3600*24;
        picIdSecondMap[100010]=30*3600*24;
        picIdSecondMap[100011]=30*3600*24;
        picIdSecondMap[100012]=30*3600*24;
        picIdSecondMap[100013]=30*3600*24;
        picIdSecondMap[100014]=60*3600*24;
        picIdSecondMap[100015]=60*3600*24;
        picIdSecondMap[100016]=60*3600*24;
        picIdSecondMap[100017]=60*3600*24;
        
        picIdSecondMap[21001]=30*3600*24;
        picIdSecondMap[21002]=30*3600*24;
        picIdSecondMap[21003]=60*3600*24;
    }
    
    modifier nonReentrant() {
        require(!_status, 'reentrant call'); 
        _status = true;
        _;
        _status = false; 
    }
    
    function active(uint256[] memory ids) public nonReentrant {
        USDT.transferFrom(msg.sender,address(this),ids.length.mul(30e18));
        uint256 avgLP = swapAndLiquify(ids.length.mul(30e18)).div(ids.length);
        for(uint256 i=0;i<ids.length;i++){
            require(nft.ownerOf(ids[i]) == msg.sender,'not card owner');
            uint256 picId;
            uint256 lockVal;
            uint256 endTime;
            (picId,,,,endTime,lockVal,,,,,,) = nft.Props(ids[i]);
            require(picId>=100001 && picId<=100017,'picId error');
            require(lockVal == 0,'already lockVal');
            require(endTime == 0, 'has used');
            nft.setNFTPropWithoutEvent(ids[i],6,avgLP);
            nft.setNFTPropWithoutEvent(ids[i],3,now);
            nft.setNFTProp(ids[i],5,now.add(picIdSecondMap[picId]));
        }
    }
    
    function activeCombination(uint256 _type,uint256[] memory ids) public nonReentrant {
        require(ids.length == 4,'length error');
        require(_type>=1 && _type<=3,'type error');
        uint256[18] memory waitIds = [uint256(1),1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
        USDT.transferFrom(msg.sender,address(this),ids.length.mul(30e18));
        uint256 avgLP = swapAndLiquify(ids.length.mul(30e18)).div(ids.length);
        for(uint256 i=0;i<ids.length;i++){
            require(nft.ownerOf(ids[i]) == msg.sender,'not card owner');
            uint256 picId;
            uint256 lockVal;
            uint256 endTime;
            (picId,,,,endTime,lockVal,,,,,,) = nft.Props(ids[i]);
            require(picId>=100001 && picId<=100017,'picId error');
            require(lockVal == 0,'already lockVal');
            require(endTime == 0, 'has used');
            nft.setNFTPropWithoutEvent(ids[i],6,avgLP);
            nft.setNFTPropWithoutEvent(ids[i],3,now);
            nft.setNFTPropWithoutEvent(ids[i],4,_type);
            nft.setNFTProp(ids[i],5,now.add(picIdSecondMap[picId]));
            waitIds[picId-100000]=0;
        }
        if(_type==1){
            require(waitIds[2]==0 && waitIds[3]==0  && waitIds[4]==0  && waitIds[5]==0,"activeCombination pids error");
        }
        if(_type==2){
            require(waitIds[6]==0 && waitIds[7]==0  && waitIds[8]==0  && waitIds[9]==0,"activeCombination pids error");
        }
        if(_type==3){
            require(waitIds[10]==0 && waitIds[11]==0  && waitIds[12]==0  && waitIds[13]==0,"activeCombination pids error");
        }
    }
    
    function harvest(uint256[] memory ids) public nonReentrant returns(uint256){
        uint256 totalReward = 0;
        for(uint256 i=0;i<ids.length;i++) {
            require(nft.ownerOf(ids[i]) == msg.sender,'not card owner');
            uint256 picId;
            uint256 updateTime;
            uint256 endTime;
            uint256 lockVal;
            uint256 combinationType;
            (picId,,updateTime,combinationType,endTime,lockVal,,,,,,) = nft.Props(ids[i]);
            require((picId>=100001 && picId<=100017) || (picId>=21001 && picId<=21003) ,'picId error');
            require(lockVal!=0,'need lockVal');
            
            if(updateTime>=endTime || now == updateTime)continue;
            uint256 delta = 0;
            if(now>=endTime){
                delta=endTime.sub(updateTime);
                nft.setNFTProp(ids[i],3,endTime);
            }else{
                delta=now.sub(updateTime);
                nft.setNFTProp(ids[i],3,now);
            }
            
            if(combinationType == 0){
                totalReward = totalReward.add(delta.mul(picIdSecondRewardMap[picId]));
            }
            else if(combinationType == 1){
                totalReward = totalReward.add(delta.mul(picIdSecondRewardMap[picId].div(36).mul(40)));
            }
            else if(combinationType == 2){
                totalReward = totalReward.add(delta.mul(picIdSecondRewardMap[picId].div(40).mul(46)));
            }
            else if(combinationType == 3){
                totalReward = totalReward.add(delta.mul(picIdSecondRewardMap[picId].div(45).mul(50)));
            }
        }
        CP.transfer(msg.sender,totalReward);
        return totalReward;
    }
    
    function burn(uint256[] memory ids) public nonReentrant {
        for(uint256 i=0;i<ids.length;i++) {
            require(nft.ownerOf(ids[i]) == msg.sender,'not card owner');
            uint256 picId;
            uint256 updateTime;
            uint256 endTime;
            uint256 lockVal;
            (picId,,updateTime,,endTime,lockVal,,,,,,) = nft.Props(ids[i]);
            require(picId>=100001 && picId<=100017,'picId error');
            require(lockVal!=0,'need lockVal');
            require(updateTime>=endTime,'not end');
            IERC20(0x44800df6f37f2838BeD043929e20fF5059eCBF6F).transfer(msg.sender,lockVal);
            nft.setNFTProp(ids[i],6,0);
        }
    }
    
    function swapAndLiquify(uint256 usdtBalance) internal returns(uint256) {
        uint256 beforeLP = IERC20(0x44800df6f37f2838BeD043929e20fF5059eCBF6F).balanceOf(address(this));
        address[] memory routerPath = new address[](2);
        routerPath[0]=address(USDT);
        routerPath[1]=address(0x82C19905B036bf4E329740989DCF6aE441AE26c1);
        USDT.approve(0x10ED43C718714eb63d5aA57B78B54704E256024E,uint256(-1));
        
        uint256 beforeCP = CP.balanceOf(address(this));
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E).swapExactTokensForTokens(usdtBalance.div(2), 0, routerPath, address(this), now);
        
        IERC20(0x82C19905B036bf4E329740989DCF6aE441AE26c1).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E,uint256(-1));
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E).addLiquidity(routerPath[0], routerPath[1], IERC20(routerPath[0]).balanceOf(address(this)),CP.balanceOf(address(this)).sub(beforeCP), 0, 0, address(this), now);
        return IERC20(0x44800df6f37f2838BeD043929e20fF5059eCBF6F).balanceOf(address(this)).sub(beforeLP);
    }
}
