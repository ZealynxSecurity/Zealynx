// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IHevm.sol";
import "./IncrementorTwo.sol";

contract EchidnaUseCheatcodes {
    IHevm hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    address internal constant USER1 = address(0x10000);
    IncrementorTwo incrementor;

    constructor() {
        hevm.deal(USER1, 5 ether);
        incrementor = new IncrementorTwo();
    }

    function test_checking_cheatcodes(uint256 amount) public {
        // Filter the fuzzer input
        hevm.assume(amount > 1000);

        // assume, warp, prank
        uint256 initialTime = block.timestamp;

        // Move the action to 10 days in the future
        hevm.warp(initialTime + 10 days);
        // Set the user that will be triggering the next call
        hevm.prank(USER1);

        // Make the call
        incrementor.increase(amount);
    }
}