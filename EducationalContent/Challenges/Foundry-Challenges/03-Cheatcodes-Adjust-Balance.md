## Foundry Challenge #3:
### Adjust Ethereum Balances in Your Smart Contract Test

Consider a scenario where your smart contract behaves differently based on the user's Ether balance. Perhaps a function within your contract can only be executed if the user has more than 1 Ether. Testing such conditions can be cumbersome if you need to simulate real transactions to adjust balances.

Your mission: Learn how to instantly set an Ethereum address's balance in your tests to a specific amount of Ether, allowing you to test how the contract behaves for users with different financial statuses.

### Can you figure out which Foundry cheat code would let you manipulate Ether balances, and how you would apply it in your test scenario?

:arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down:

### Solution to the Challenge: Adjust Ethereum Balances in Your Smart Contract Test

To instantly set the balance of an Ethereum address in your tests, you can utilize the vm.deal cheat code provided by Foundry. This powerful tool allows you to specify any Ether amount for any address, which is invaluable for testing conditions dependent on user balances.

Example Contract:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract BalanceSensitiveContract {
    uint256 public constant MINIMUM_BALANCE = 1 ether;

    function performSensitiveAction() external view returns (string memory) {
        require(address(msg.sender).balance >= MINIMUM_BALANCE, "Insufficient balance to perform action");
        return "Action performed";
    }
}

contract BalanceSensitiveContractTest is Test {
    BalanceSensitiveContract public sensitiveContract;

    function setUp() public {
        sensitiveContract = new BalanceSensitiveContract();
    }

    function testPerformSensitiveActionWithSufficientBalance() public {
        address richUser = address(1);  // Example user address
        vm.deal(richUser, 2 ether);  // Set the balance of richUser to 2 ether
        vm.prank(richUser);
        string memory result = sensitiveContract.performSensitiveAction();
        assertEq(result, "Action performed", "Action should be performed when balance is sufficient");
    }

    function testFailPerformSensitiveActionWithInsufficientBalance() public {
        address poorUser = address(2);  // Example user address
        vm.deal(poorUser, 0.5 ether);  // Set the balance of poorUser to 0.5 ether
        vm.prank(poorUser);
        sensitiveContract.performSensitiveAction();  // Should fail due to insufficient balance
    }
}
```

### Explanation:

- Contract Setup: The BalanceSensitiveContract contains a function performSensitiveAction that can only be executed if the caller's balance is at least 1 Ether.

- Test Contract: Sets up an instance of BalanceSensitiveContract.

- Test Function (testPerformSensitiveActionWithSufficientBalance): This function sets an example user's balance to 2 Ether using vm.deal and then tests that the sensitive action can be successfully performed.

- Test Function (testFailPerformSensitiveActionWithInsufficientBalance): Another function sets a different user's balance to 0.5 Ether, which is not enough to meet the minimum balance requirement. The test expects the function call to fail, confirming the contract's balance check works as intended.