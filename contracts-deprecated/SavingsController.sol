// SPDX-License-Identifier: MIT

pragma solidity ^0.6.9;

import "./SavingsPoolInterface.sol";

contract SavingsController {
    function claimMiningToken(address holder, address[] calldata savingsPools) public {
        for (uint i = 0; i < savingsPools.length; i++ ) {
            SavingsPoolInterface savingsPool = SavingsPoolInterface(savingsPools[i]);
            savingsPool.claimMiningToken(holder);
        }
    }
}