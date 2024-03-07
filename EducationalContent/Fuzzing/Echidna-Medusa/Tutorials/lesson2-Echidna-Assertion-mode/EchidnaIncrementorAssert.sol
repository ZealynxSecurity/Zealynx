// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Incrementor.sol";

contract EchidnaIncrementorAssert {
    Incrementor incrementor;

    constructor() {
        incrementor = new Incrementor();
    }
   
   function assert_counterIsEqualOrBigger(uint256 amount) public {
        incrementor.increase(amount);

        assert(incrementor.newCounter() <= incrementor.counter());
        
        incrementor.calculate();
   }
}