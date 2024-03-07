// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract IncrementorTwo {
    uint256 public counter = 2 ** 200;
    uint256 public newCounter;

    function increase(uint256 val) public {   
        newCounter = counter;    
        unchecked {
            counter += val;
        }
    }

    function calculate() public view returns (uint256 amount) {
        return (newCounter - counter);
    }
}