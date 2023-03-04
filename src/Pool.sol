// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { ERC721, ERC721TokenReceiver } from "solmate/tokens/ERC721.sol";

contract Pool is ERC721TokenReceiver {

    address public admin;

    address public vendingMachine;

    constructor(address _admin, address _vendingMachine) {
        admin = _admin;
        vendingMachine = _vendingMachine;
    }

    struct NFT {
        address collection;
        uint96 id;
    }

    mapping(uint => bytes32) internal idxToNFT;

    uint128 public numNFTs;

    uint128 internal open;

    function selectNFT(uint idx, address to) external returns (address collection, uint96 id) {
        require(msg.sender == vendingMachine, "NOT_VENDING_MACHINE");

        bytes memory data = abi.encodePacked(idxToNFT[idx]);

        assembly {
            collection := mload(add(data,20))
            id := mload(add(data,32))
        }

        idxToNFT[idx] = idxToNFT[--numNFTs];

        ERC721(collection).safeTransferFrom(address(this), to, id);
    }

    function addNFTs(NFT[] calldata nfts) external {
        unchecked { ++open; }

        uint128 numNFTs_ = numNFTs;

        uint length = nfts.length;

        NFT memory nft;

        for (uint i; i < length; ) {
            nft = nfts[i];

            ERC721(nft.collection).safeTransferFrom(msg.sender, address(this), nft.id);

            idxToNFT[numNFTs_++] = bytes32(abi.encodePacked(nft.collection ,nft.id));

            unchecked { ++i; }
        }

        numNFTs = numNFTs_;

        unchecked { --open; }
    }
    
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external view override returns (bytes4) {
        require(open == 1, "SENT_OUTSIDE_CALL");

        return ERC721TokenReceiver.onERC721Received.selector;
    }
}