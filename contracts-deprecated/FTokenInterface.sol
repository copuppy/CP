// SPDX-License-Identifier: MIT

pragma solidity ^0.6.9;

abstract contract FTokenInterface {
    function mint(uint mintAmount) external virtual returns (uint);
    function redeem(uint redeemTokens) external virtual returns (uint);
    function redeemUnderlying(uint redeemAmount) external virtual returns (uint);
    function supplyRatePerBlock() external view virtual returns (uint);
    function exchangeRateCurrent() external virtual returns (uint);
    function exchangeRateStored() external view virtual returns (uint);
    function balanceOfUnderlying(address owner) external virtual returns (uint);
    function balanceOf(address owner) external view virtual returns (uint);

    function underlying() external view virtual returns (address);
    function comptroller() external view virtual returns (address);
}

abstract contract ComtrollerInterface {
    function claimComp(address[] memory holders, address[] memory cTokens, bool borrowers, bool suppliers) external virtual;
    function getCompAddress() external view virtual returns (address);
}