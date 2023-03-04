// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/Pool.sol";
import "src/Vending.sol";

import { ERC721 } from "solmate/tokens/ERC721.sol";

contract Ape is ERC721 {
    constructor()ERC721("NAME", "SYMBOL"){}

    function tokenURI(uint256) public pure override returns (string memory){
        return "Hi";
    }

    uint id;

    function mint() external {
        _mint(msg.sender, ++id);
    }

}

contract VendingMachineTest is Test { 
    Ape ape;

    Pool pool;

    Vending vending;

    address admin = address(uint160(uint256(keccak256(abi.encodePacked(("hi"))))));
    address user = address(uint160(uint256(keccak256(abi.encodePacked(("bye"))))));

    function setUp() public {
        ape = new Ape();

        vending = new Vending(admin, 1 ether);

        pool = new Pool(admin, address(vending));

        vm.deal(user, 1000 ether);

        vm.prank(admin);
        vending.setPool(address(pool));
    }

    function testInventory() public {
        Pool.NFT[] memory nfts = new Pool.NFT[](20);

        vm.startPrank(admin);

        for (uint96 i; i < 20; ++i) {
            ape.mint();

            nfts[i] = Pool.NFT(address(ape), i + 1);
        }

        ape.setApprovalForAll(address(pool), true);

        pool.addNFTs(nfts);

        vm.stopPrank();

        assertEq(ape.ownerOf(12), address(pool));
        assertEq(ape.ownerOf(20), address(pool));
    }

    function testSpin() public {
        testInventory();

        vm.roll(312312);

        vm.startPrank(user);

       (, uint96 id, uint idx) = vending.spin{ value : 1 ether }();

        console.log("ID",id);
        console.log("IDX",idx);

        vm.roll(312320);

        (, id, idx) = vending.spin{ value : 1 ether }();

        console.log("ID",id);
        console.log("IDX",idx);

        vm.roll(312321);

        (, id, idx) = vending.spin{ value : 1 ether }();

        console.log("ID",id);
        console.log("IDX",idx);

        vm.roll(3129000);

        (, id, idx) = vending.spin{ value : 1 ether }();

        console.log("ID",id);
        console.log("IDX",idx);

        vm.roll(3123210);

        (, id, idx) = vending.spin{ value : 1 ether }();

        console.log("ID",id);
        console.log("IDX",idx);


    }
    
}
