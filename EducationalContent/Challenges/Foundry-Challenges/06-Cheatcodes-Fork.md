## Foundry Challenge: 
### Test Against a Fork of the Live Ethereum Network

Testing your smart contracts in a local development environment is essential, but sometimes you need to see how they interact with real, live blockchain data. For instance, you might want to test how your contract integrates with existing contracts on the mainnet or other networks.

**Your mission:** 
Learn how to create a fork of a live Ethereum network in your tests to verify that your smart contracts work correctly with real blockchain data.

### Can you determine which Foundry cheat code allows you to fork a live network, and how would you use it in a test case?

:arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down:

### Solution to the Challenge: Test Against a Fork of the Live Ethereum Network

The vm.createFork and vm.selectFork cheat codes allow you to create a fork of a live Ethereum network and select it for testing. This lets you run tests in an environment that mirrors the state of the actual blockchain.

Example Contract:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract ForkTest is Test {
    IERC20 public dai;
    address public daiHolder = 0x28C6c06298d514Db089934071355E5743bf21d60; // Example DAI holder address
    string public MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    function setUp() public {
        // Create a fork of the mainnet
        uint256 forkId = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(forkId);

        // Initialize the DAI contract with the mainnet address
        dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    }

    function testForkedState() public {
        // Check the balance of the DAI holder on the forked mainnet
        uint256 balance = dai.balanceOf(daiHolder);
        assert(balance > 0, "DAI balance should be greater than 0");
    }
}
```

### Explanation:

- Contract Setup: This test setup assumes you have an RPC URL for the Ethereum mainnet stored in your environment variables as MAINNET_RPC_URL.
  
- Forking the Network: The setUp function creates a fork of the mainnet using vm.createFork and selects it with vm.selectFork. This effectively mirrors the state of the Ethereum mainnet for testing purposes.
  
- Initialize Contract: The DAI contract is initialized with the mainnet DAI contract address.
  
- Test Function (testForkedState): This function checks the balance of a known DAI holder address on the forked mainnet. The test asserts that the balance is greater than zero, verifying that the forked state reflects the actual mainnet state.
