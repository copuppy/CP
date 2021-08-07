// SPDX-License-Identifier: MIT

pragma solidity ^0.6.9;

abstract contract SavingsPoolInterface {
    function claimMiningToken(address tokenHolder) virtual public;
}