## Foundry Challenge: 
### Manipulate Gas Price in Your Smart Contract Test

Gas price is a crucial factor in Ethereum transactions, influencing the cost of executing smart contracts and how they interact with the blockchain. In some scenarios, your contract may need to handle different gas prices correctly, such as when calculating transaction costs or optimizing gas usage.

**Your mission:**
Discover how to set and test different gas prices in your smart contract to ensure your contract handles various gas price scenarios correctly.

### Can you figure out which Foundry cheat code allows you to manipulate the transaction gas price, and how would you apply it in a test scenario?

### Solution to the Challenge: Manipulate Gas Price in Your Smart Contract Test

The vm.txGasPrice cheat code allows you to set the gas price for a transaction within your test environment. This enables you to simulate and test how your contract behaves under different gas price scenarios.

Example Contract:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract GasSensitiveContract {
    uint256 public lastTransactionGasPrice;

    function sensitiveAction() external {
        // Store the gas price of the transaction that calls this function
        lastTransactionGasPrice = tx.gasprice;
    }

    function getGasPrice() external view returns (uint256) {
        return lastTransactionGasPrice;
    }
}

contract GasSensitiveContractTest is Test {
    GasSensitiveContract public gasContract;

    function setUp() public {
        gasContract = new GasSensitiveContract();
    }

    function testGasPriceManipulation() public {
        // Set the gas price to 50 gwei
        uint256 testGasPrice = 50 gwei;
        vm.txGasPrice(testGasPrice);

        // Call the contract function that records the gas price
        gasContract.sensitiveAction();

        // Verify that the stored gas price matches the set gas price
        uint256 recordedGasPrice = gasContract.getGasPrice();
        assertEq(recordedGasPrice, testGasPrice, "Gas price should match the set value");
    }

    function testDifferentGasPrice() public {
        // Set the gas price to a different value, e.g., 100 gwei
        uint256 testGasPrice = 100 gwei;
        vm.txGasPrice(testGasPrice);

        // Call the contract function that records the gas price
        gasContract.sensitiveAction();

        // Verify that the stored gas price matches the new set gas price
        uint256 recordedGasPrice = gasContract.getGasPrice();
        assertEq(recordedGasPrice, testGasPrice, "Gas price should match the set value");
    }
}
```

### Explanation:

- Contract Setup: The GasSensitiveContract contract has a function sensitiveAction that records the gas price of the transaction that calls it. This gas price is stored in lastTransactionGasPrice.

- Test Contract: Initializes an instance of GasSensitiveContract.

- Test Function (testGasPriceManipulation):
    - Set Gas Price: The test sets the gas price to 50 gwei using vm.txGasPrice.
    - Call Function: It then calls the sensitiveAction function, which records the gas price.
    - Verification: The test asserts that the recorded gas price matches the value set with vm.txGasPrice.

- Test Function (testDifferentGasPrice):
    - Set Different Gas Price: The test sets a different gas price, 100 gwei, using vm.txGasPrice.
    - Call Function and Verify: The process is repeated to verify that the contract correctly records the new gas price.