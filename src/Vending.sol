// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/interfaces/IPool.sol";

contract Vending {
    address internal admin;

    address internal buyer;

    IPool internal pool;

    uint internal cost;

    constructor(address _admin, uint _cost) {
        admin = _admin;

        cost = _cost;
    }

    function spin() external payable returns(address collection, uint96 id, uint idx) {
        require(msg.value >= cost || msg.sender == buyer, "ETH_TOO_LOW");

        idx = uint256((blockhash(block.number - 1))) % pool.numNFTs();

        (collection, id) = pool.selectNFT(idx, msg.sender);
    }

    function setPool(address _pool) external {
        require(msg.sender == admin, "NOT_ADMIN");

        pool = IPool(_pool);
    }

    function claim(address to) external {
        require(msg.sender == admin, "NOT_ADMIN");

        (bool success, ) = to.call{ value: address(this).balance }("");

        require(success, "TRANSFER_UNSUCCESSFUL");
    }
}