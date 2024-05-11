## Foundry Challenge #5:
### Manipulate Contract Storage Directly in Your Test

Smart contracts often rely on internal state variables to control behavior and enforce rules. Normally, these variables are encapsulated within the contract, only modifiable through specific functions that include necessary checks and balances. 

However, during testing, you might want to simulate unusual or edge-case scenarios by directly modifying these internal states.

**Your mission:**
Learn how to directly alter a smart contract's storage in your tests to simulate different states and conditions.

### Can you determine which Foundry cheat code allows you to manipulate contract storage, and how would you apply it in a test case?

:arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down:

### Solution to the Challenge: Manipulate Contract Storage Directly in Your Test

The vm.store cheat code is used to write values directly to a contract's storage, bypassing the usual mechanisms. This is particularly useful for setting up certain states before running a test, or for testing how a contract behaves when its internal state is inconsistent or unusual.

Example Contract:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract StatefulContract {
    uint256 public criticalValue;

    event ValueChanged(uint256 newValue);

    function setCriticalValue(uint256 _value) external {
        criticalValue = _value;
        emit ValueChanged(_value);
    }
}

contract StatefulContractTest is Test {
    StatefulContract public statefulContract;

    function setUp() public {
        statefulContract = new StatefulContract();
    }

    function testDirectStorageManipulation() public {
        bytes32 slot = keccak256(abi.encode(uint256(0))); // Assuming criticalValue is at slot 0
        vm.store(address(statefulContract), slot, bytes32(uint256(123456)));

        uint256 storedValue = statefulContract.criticalValue();
        assertEq(storedValue, 123456, "The storage was not updated correctly");
    }
}
```

### Explanation:

- Contract Setup: StatefulContract has a single state variable criticalValue and a function to update it. This setup is typical for contracts that maintain internal states influenced by function calls.
  
- Test Contract: Initializes an instance of StatefulContract.
  
- Test Function (testDirectStorageManipulation): This function uses vm.store to directly set the value of criticalValue without calling the setCriticalValue function. It calculates the slot where criticalValue is stored using keccak256, assuming it is the first variable (at slot 0). The test then verifies that the value was set correctly by checking it against the expected value.