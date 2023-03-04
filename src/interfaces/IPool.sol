// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IPool {
    function selectNFT(uint idx, address to) external returns(address, uint96);

    function numNFTs() external view returns(uint128);
}