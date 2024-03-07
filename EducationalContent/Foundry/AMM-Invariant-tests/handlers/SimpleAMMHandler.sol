// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../src/SimpleAMM.sol";
import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

contract SimpleAMMHandler is CommonBase, StdCheats, StdUtils {
    SimpleAMM public simpleAMM;

    // Ghost variables to track expected user balances
    mapping(address => uint256) public ghost_expectedBalanceTokenA;
    mapping(address => uint256) public ghost_expectedBalanceTokenB;

    // Keep track of user addresses
    address[] private userAddresses;

    constructor(SimpleAMM _simpleAMM) {
        simpleAMM = _simpleAMM;
        simpleAMM.addLiquidity(1000, 1000);

        // Let's get our msg.sender some credit
        ghost_expectedBalanceTokenA[msg.sender] += 5000;
        ghost_expectedBalanceTokenB[msg.sender] += 5000;
    }

    function addLiquidity(uint256 tokenAAmount, uint256 tokenBAmount) external {
        tokenAAmount = bound(tokenAAmount, 1, 10000);
        tokenBAmount = bound(tokenBAmount, 1, 10000);

        // Adjust expected balances
        ghost_expectedBalanceTokenA[msg.sender] -= tokenAAmount;
        ghost_expectedBalanceTokenB[msg.sender] -= tokenBAmount;

        simpleAMM.addLiquidity(tokenAAmount, tokenBAmount);
    }

    function removeLiquidity(
        uint256 tokenAAmount,
        uint256 tokenBAmount
    ) external {
        tokenAAmount = bound(tokenAAmount, 1, 10000);
        tokenBAmount = bound(tokenBAmount, 1, 10000);

        // Adjust expected balances
        ghost_expectedBalanceTokenA[msg.sender] += tokenAAmount;
        ghost_expectedBalanceTokenB[msg.sender] += tokenBAmount;

        simpleAMM.removeLiquidity(tokenAAmount, tokenBAmount);
    }

    function swapTokenAForTokenB(uint256 tokenAAmount) external {
        uint256 tokenBAmount;
        tokenAAmount = bound(tokenAAmount, 1, 10000);

        // Adjust expected balances
        ghost_expectedBalanceTokenA[msg.sender] -= tokenAAmount;
        ghost_expectedBalanceTokenB[msg.sender] += tokenBAmount;

        simpleAMM.swapTokenAForTokenB(tokenAAmount);
    }

    // Function to retrieve user addresses
    function getUserAddresses() external view returns (address[] memory) {
        return userAddresses;
    }

    // Utility function to add a new user address to the list
    function addUserAddress(address user) internal {
        if (!addressExists(user)) {
            userAddresses.push(user);
        }
    }

    // Check if an address is already in the list
    function addressExists(address user) internal view returns (bool) {
        for (uint i = 0; i < userAddresses.length; i++) {
            if (userAddresses[i] == user) {
                return true;
            }
        }
        return false;
    }
}
