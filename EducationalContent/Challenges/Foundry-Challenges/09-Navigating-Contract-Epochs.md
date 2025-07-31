## Foundry Challenge: Navigating Contract Epochs - Synchronized Time & Block Manipulation

### Introduction

Some smart contracts are designed with multi-stage lifecycles. Think of a token sale with distinct phases like an early bird round, a main sale, and a post-sale period, or a staking contract with different reward tiers over time. Transitions between these stages often depend not just on specific timestamps but also on a minimum number of block confirmations past those timestamps to ensure finality or maturity. This challenge explores how to test such contracts using Foundry's cheat codes to manipulate both time and block progression.

### Your Mission

Your task is to write tests for a hypothetical contract that has different operational "epochs" or phases. You'll need to test a specific function within this contract as it moves across these epochs. This involves:
1.  Advancing `block.timestamp` using `vm.warp` to enter a new epoch.
2.  Advancing `block.number` using `vm.roll` to meet a 'confirmation' or 'maturity' requirement within that epoch.
3.  Verifying that a certain action (e.g., claiming a bonus) becomes available or changes its behavior as expected according to the contract's epoch-dependent logic.

### Hint

Foundry provides powerful cheat codes that allow for independent control over `block.timestamp` (`vm.warp`) and `block.number` (`vm.roll`). You will likely need to use these in conjunction to accurately simulate the conditions for epoch transitions.

### Question

How can you use Foundry cheat codes to simulate different operational epochs of a contract that depend on both specific timestamps and subsequent block progression, and how would you test functionalities that unlock or change within these epochs?

### Solution Section

#### Example Contract

Let's consider a simplified contract `EpochManager.sol` that defines three phases: SEED, GENERAL, and MATURED.

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract EpochManager {
    enum Phase { SEED, GENERAL, MATURED }

    uint256 public constant SEED_END_TIMESTAMP = 1704067200; // Jan 1, 2024 00:00:00 GMT
    uint256 public constant GENERAL_END_TIMESTAMP = 1706745600; // Feb 1, 2024 00:00:00 GMT
    uint256 public constant MIN_CONFIRMATIONS = 100;

    uint256 public seedEndBlock;
    bool public bonusClaimed = false;

    event BonusClaimed(address claimer, uint256 timestamp, uint256 blockNumber);

    function currentPhase() public view returns (Phase) {
        if (block.timestamp < SEED_END_TIMESTAMP) {
            return Phase.SEED;
        } else if (block.timestamp < GENERAL_END_TIMESTAMP) {
            return Phase.GENERAL;
        } else {
            return Phase.MATURED;
        }
    }

    // In a real scenario, setting seedEndBlock might be done upon deployment or by an admin.
    // For testing, we can imagine it's set when the SEED phase begins.
    // We'll simulate this by setting it in the test setup.
    function recordSeedEndBlock() internal {
        if (seedEndBlock == 0 && block.timestamp >= SEED_END_TIMESTAMP) {
            seedEndBlock = block.number;
        }
    }

    function claimBonus() public {
        recordSeedEndBlock(); // Record the block number when SEED_END_TIMESTAMP is first passed

        Phase phase = currentPhase();
        require(phase == Phase.GENERAL, "EpochManager: Not in GENERAL phase");
        require(block.number >= seedEndBlock + MIN_CONFIRMATIONS, "EpochManager: Insufficient confirmations past SEED phase");
        require(!bonusClaimed, "EpochManager: Bonus already claimed");

        bonusClaimed = true;
        emit BonusClaimed(msg.sender, block.timestamp, block.number);
    }

    // Getter for test purposes
    function getSeedEndBlock() public view returns (uint256) {
        return seedEndBlock;
    }
}

```

#### Example Test Contract (`EpochManager.t.sol`)

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/EpochManager.sol"; // Adjust path as needed

contract EpochManagerTest is Test {
    EpochManager epochManager;

    uint256 internal constant INITIAL_BLOCK_TIMESTAMP = 1701388800; // Dec 1, 2023
    uint256 internal constant INITIAL_BLOCK_NUMBER = 1000;

    function setUp() public {
        vm.warp(INITIAL_BLOCK_TIMESTAMP);
        vm.roll(INITIAL_BLOCK_NUMBER);
        epochManager = new EpochManager();
    }

    function test_InitialPhase_IsSeed() public {
        assertEq(uint(epochManager.currentPhase()), uint(EpochManager.Phase.SEED));
    }

    function test_Fail_ClaimBonus_InSeedPhase() public {
        vm.expectRevert("EpochManager: Not in GENERAL phase");
        epochManager.claimBonus();
    }

    function test_TransitionToGeneral_ClaimBonus_SuccessAfterConfirmations() public {
        // 1. Warp time to just after SEED_END_TIMESTAMP to enter GENERAL phase
        // This first call to claimBonus will also set `seedEndBlock` internally.
        vm.warp(EpochManager.SEED_END_TIMESTAMP + 1);
        
        // At this point, currentPhase is GENERAL, but confirmations are not met.
        // The internal `recordSeedEndBlock` will set `seedEndBlock` to current block.number (INITIAL_BLOCK_NUMBER)
        assertEq(uint(epochManager.currentPhase()), uint(EpochManager.Phase.GENERAL));
        
        // Attempt to claim bonus immediately (should fail due to insufficient confirmations)
        // The first time we call claimBonus *after* SEED_END_TIMESTAMP, it sets seedEndBlock.
        // The revert happens because block.number is not yet seedEndBlock + MIN_CONFIRMATIONS.
        vm.expectRevert("EpochManager: Insufficient confirmations past SEED phase");
        epochManager.claimBonus(); 
        
        uint256 recordedSeedEndBlock = epochManager.getSeedEndBlock();
        // seedEndBlock is set by the first call to a function that calls recordSeedEndBlock() 
        // *after* SEED_END_TIMESTAMP. In the previous expectRevert, claimBonus was called,
        // which internally called recordSeedEndBlock(). So, recordedSeedEndBlock is INITIAL_BLOCK_NUMBER.
        assertEq(recordedSeedEndBlock, INITIAL_BLOCK_NUMBER, "seedEndBlock mismatch");

        // 2. Roll blocks to meet MIN_CONFIRMATIONS requirement
        // We need block.number to be recordedSeedEndBlock + MIN_CONFIRMATIONS
        vm.roll(recordedSeedEndBlock + EpochManager.MIN_CONFIRMATIONS);

        // Now, bonus claim should succeed
        epochManager.claimBonus();
        assertTrue(epochManager.bonusClaimed(), "Bonus should be claimed");
    }

    function test_TransitionToMaturedPhase() public {
        // Warp time past GENERAL_END_TIMESTAMP
        vm.warp(EpochManager.GENERAL_END_TIMESTAMP + 1);
        assertEq(uint(epochManager.currentPhase()), uint(EpochManager.Phase.MATURED));

        // Attempting to claim bonus in MATURED phase should fail
        vm.expectRevert("EpochManager: Not in GENERAL phase");
        epochManager.claimBonus();
    }

    function test_ClaimBonus_SequenceWithExplicitBlockSetting() public {
        // Set initial time to be before SEED_END
        vm.warp(EpochManager.SEED_END_TIMESTAMP - 1 days);
        vm.roll(2000); // Start at a different block number for this test

        assertEq(uint(epochManager.currentPhase()), uint(EpochManager.Phase.SEED));

        // Warp to just after SEED_END_TIMESTAMP.
        // The block number is still 2000.
        vm.warp(EpochManager.SEED_END_TIMESTAMP + 1);
        uint256 blockWhenSeedEnded = block.number; // This is 2000

        // First call to claimBonus to trigger seedEndBlock recording.
        // It will revert because not enough confirmations.
        vm.expectRevert("EpochManager: Insufficient confirmations past SEED phase");
        epochManager.claimBonus();

        // Check that seedEndBlock was recorded correctly.
        assertEq(epochManager.getSeedEndBlock(), blockWhenSeedEnded, "seedEndBlock not set correctly");
        
        // Now roll to meet confirmations
        vm.roll(blockWhenSeedEnded + EpochManager.MIN_CONFIRMATIONS);
        
        // Timestamp is still SEED_END_TIMESTAMP + 1 (GENERAL phase time)
        // Block number is now blockWhenSeedEnded + MIN_CONFIRMATIONS
        // So, claimBonus should succeed.
        epochManager.claimBonus();
        assertTrue(epochManager.bonusClaimed(), "Bonus should now be claimed");
    }
}

```

#### Explanation

To effectively test contracts with time-sensitive and block-sensitive logic, Foundry offers `vm.warp(newTimestamp)` and `vm.roll(newBlockNumber)`:

1.  **`vm.warp(uint256 newTimestamp)`**: This cheat code directly sets `block.timestamp` to `newTimestamp`. All subsequent transactions in the current test context will see this new timestamp until it's changed again. This is crucial for testing functionalities that unlock or change behavior at specific times (e.g., entering a new phase of a sale).

2.  **`vm.roll(uint256 newBlockNumber)`**: This cheat code sets `block.number` to `newBlockNumber`. Similar to `vm.warp`, this affects subsequent transactions. This is used to simulate the progression of blocks, often necessary for conditions like "X blocks must have passed since event Y."

**Sequential Usage for Epoch Simulation:**

In our `test_TransitionToGeneral_ClaimBonus_SuccessAfterConfirmations` example:
*   We first call `vm.warp(EpochManager.SEED_END_TIMESTAMP + 1)`. This moves the perceived time into the `GENERAL` phase.
*   At this moment, if `claimBonus()` is called, it correctly identifies the phase as `GENERAL`. However, the contract also has a requirement: `block.number >= seedEndBlock + MIN_CONFIRMATIONS`. The `seedEndBlock` is intended to be the block number when the `SEED_END_TIMESTAMP` was first crossed. Our `EpochManager` contract cleverly sets this `seedEndBlock` internally the first time `claimBonus` (or any function calling `recordSeedEndBlock`) is called *after* `SEED_END_TIMESTAMP`.
*   The initial call to `epochManager.claimBonus()` after warping time is expected to revert. This is because even though time has advanced, `block.number` has not yet met the `MIN_CONFIRMATIONS` requirement relative to when `seedEndBlock` was set (which was `INITIAL_BLOCK_NUMBER` in the `setUp` because `recordSeedEndBlock` uses the current `block.number` if `seedEndBlock` is 0 and time criterion is met).
*   We then use `vm.roll(recordedSeedEndBlock + EpochManager.MIN_CONFIRMATIONS)`. This advances the `block.number` to satisfy the confirmation requirement.
*   A subsequent call to `epochManager.claimBonus()` now succeeds because both the time-based condition (being in `GENERAL` phase) and the block-based condition (sufficient confirmations) are met.

By using `vm.warp` and `vm.roll` in sequence, developers can meticulously simulate the conditions required to trigger different states and behaviors in their contracts, ensuring that epoch transitions and associated logic function as designed. Assertions (`assertTrue`, `assertEq`, `vm.expectRevert`) are then used to verify the contract's state and responses at each step.
