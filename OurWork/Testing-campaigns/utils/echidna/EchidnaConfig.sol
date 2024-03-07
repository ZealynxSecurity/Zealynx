// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IHevm.sol";
import "./Debugger.sol";

contract EchidnaConfig {
    IHevm hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    // Constant echidna addresses
    address internal constant USER1 = address(0x10000);
    address internal constant USER2 = address(0x20000);
    address internal constant USER3 = address(0x30000);
    uint256 internal constant INITIAL_BALANCE = 1_000_000e18;
}