## Foundry Challenge #2:
### Travel Through Time in Your Smart Contract Test

In the world of Ethereum, certain actions or functions might only be available or behave differently depending on the block number. Suppose you have a contract that rewards early adopters by giving special bonuses if they interact with it before a certain block number. How do you test this functionality effectively without waiting for real blocks to be mined?

**Your mission:** 
Discover how to artificially advance to a specific block number in your tests to simulate interactions at different times on the Ethereum blockchain.

### Can you identify which Foundry cheat code lets you manipulate block numbers, and how you would apply it in your test script?

:arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down::arrow_down:

### Solution to the Challenge: Travel Through Time in Your Smart Contract Test

To simulate interactions at specific block numbers in your smart contract tests, you can use the vm.roll cheat code provided by Foundry. This cheat code lets you set the block number to a specific value, which is incredibly useful for testing contracts that depend on block height for certain conditions.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract TimeSensitiveReward {
    uint256 public immutable rewardCutoffBlock;
    uint256 public rewardAmount = 100;

    constructor(uint256 _rewardCutoffBlock) {
        rewardCutoffBlock = _rewardCutoffBlock;
    }

    function claimReward() external returns (uint256) {
        require(block.number < rewardCutoffBlock, "Reward period has ended");
        return rewardAmount;
    }
}

contract TimeSensitiveRewardTest is Test {
    TimeSensitiveReward public rewardContract;
    uint256 public cutoffBlock = 200;

    function setUp() public {
        rewardContract = new TimeSensitiveReward(cutoffBlock);
    }

    function testClaimRewardBeforeCutoff() public {
        vm.roll(199);  // Set the block number just before the cutoff
        uint256 reward = rewardContract.claimReward();
        assertEq(reward, 100, "Should receive reward");
    }

    function testFailClaimRewardAfterCutoff() public {
        vm.roll(200);  // Set the block number at the cutoff
        rewardContract.claimReward();  // This should fail
    }
}
```

### Explanation:

- Contract Setup: The TimeSensitiveReward contract includes a function claimReward that can only be successfully called if the current block number is less than a specified cutoff block number. This simulates a scenario where rewards are only available for a limited time.

- Test Contract: The TimeSensitiveRewardTest sets up the reward contract with a cutoff block of 200.

- Test Function (testClaimRewardBeforeCutoff): This function uses vm.roll to set the block number to 199 (just before the cutoff), then it calls the claimReward function and checks that the reward is correctly claimed.

- Test Function (testFailClaimRewardAfterCutoff): Another function sets the block number to 200 (at the cutoff) and expects the claimReward function call to fail because the reward period has ended.