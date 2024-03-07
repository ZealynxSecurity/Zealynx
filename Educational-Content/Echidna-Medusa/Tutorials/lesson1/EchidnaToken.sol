// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Token.sol";

contract EchidnaToken {
    Token token;
    constructor() {
        token = new Token();
    }

    function echidna_balance_under_1000() public view returns (bool) {
        return token.balances(msg.sender) <= 1000;
    }
}