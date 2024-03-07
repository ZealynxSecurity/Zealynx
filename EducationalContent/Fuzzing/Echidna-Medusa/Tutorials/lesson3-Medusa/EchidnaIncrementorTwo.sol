// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IncrementorTwo.sol";

contract EchidnaIncrementorAssert {
    IncrementorTwo incrementor;

    constructor() {
        incrementor = new IncrementorTwo();
    }
   
   function assert_counterIsEqualOrBigger(uint256 amount) public {
        incrementor.increase(amount);

        assert(incrementor.newCounter() <= incrementor.counter());
        
        uint256 valueCalculated = incrementor.calculate();

        assert(valueCalculated > 0);
   }
}