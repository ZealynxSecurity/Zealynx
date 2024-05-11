## Foundry Challenge #4:
### Reverts in Your Smart Contract Test

Smart contracts often need to fail gracefully under certain conditions to ensure the integrity and security of the blockchain. For example, a contract might revert transactions if the sender does not meet specific requirements or if the inputs to a function are invalid.

Testing these failure modes can be tricky without the right tools.

**Your mission:**
Discover how to assert that a smart contract function reverts as expected during your tests.

### Can you figure out which Foundry cheat code enables you to test for expected reverts, and how would you implement it in a test case?

:arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down:

### Solution to the Challenge: Expect Reverts in Your Smart Contract Test

To ensure that a smart contract function reverts as expected, you can use the vm.expectRevert cheat code in Foundry. This cheat code allows you to specify the expected revert reason or error type, making it possible to precisely test error handling in your contracts.

**Example Contract:**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract RestrictedAccess {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function sensitiveAction() external {
        require(msg.sender == owner, "Unauthorized: Caller is not the owner");
    }
}

contract RestrictedAccessTest is Test {
    RestrictedAccess public restrictedContract;
    address public testUser = address(2);

    function setUp() public {
        restrictedContract = new RestrictedAccess();
    }

    function testSensitiveActionAsOwner() public {
        restrictedContract.sensitiveAction();  // Should succeed as the deployer is the owner
    }

    function testFailSensitiveActionAsNonOwner() public {
        vm.prank(testUser);
        vm.expectRevert("Unauthorized: Caller is not the owner");
        restrictedContract.sensitiveAction();  // Should revert
    }
}
```

### Explanation:

- Contract Setup: The RestrictedAccess contract has a function sensitiveAction that can only be executed by the contract owner, identified at the time of contract deployment.
  
- Test Contract: Initializes an instance of RestrictedAccess.
  
- Test Function (testSensitiveActionAsOwner): Tests that the sensitiveAction function can be successfully called by the owner (no revert expected).
  
- Test Function (testFailSensitiveActionAsNonOwner): Sets up a test where a non-owner tries to execute the sensitiveAction. It uses vm.prank to simulate the call from a non-owner address and vm.expectRevert to specify the expected revert message. This test checks that the function correctly reverts with the expected error message.
