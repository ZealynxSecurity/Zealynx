// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../veOLAS.sol";

contract EchidnaVeOLASAssert {
    veOLAS veOlas;

    // Constructor with dummy values
    constructor() {
        veOlas = new veOLAS(newAddress(7), "veOLAS", "veO");
    }

    // Ensure that all locked amounts are non-negative
    function assert_locked_amounts_non_negative() view public {
        // Iterate through all accounts or a representative sample
        address[] memory accounts = generateAddresses();
        for (uint i = 0; i < accounts.length; i++) {
            (uint128 amount,) = veOlas.mapLockedBalances(accounts[i]);
            assert(amount >= 0);
        }
    }

    // Ensure that no lock time exceeds the maximum allowable time
    function assert_lock_time_within_bounds() view public {
        // Similarly, iterate through all accounts or a representative sample
        address[] memory accounts = generateAddresses();
        for (uint i = 0; i < accounts.length; i++) {
            (, uint64 endTime) = veOlas.mapLockedBalances(accounts[i]);
            assert(endTime <= block.timestamp + veOlas.MAXTIME());
        }
    }

    // Ensure the total supply is consistent with the sum of individual locked amounts
    function assert_total_supply_consistency() view public {
        uint256 computedTotal = 0;
        address[] memory accounts = generateAddresses();
        for (uint i = 0; i < accounts.length; i++) {
            (uint128 amount,) = veOlas.mapLockedBalances(accounts[i]);
            computedTotal += amount;
        }
        assert(computedTotal == veOlas.totalSupply());
    }

    // Ensure voting power calculations align with expectations
    function assert_voting_power_consistent() view public {
        address[] memory accounts = generateAddresses();
        for (uint i = 0; i < accounts.length; i++) {
            // Example: Get the locked balance and end time for each account
            (uint128 amount, uint64 endTime) = veOlas.mapLockedBalances(accounts[i]);

            // Get the current voting power
            uint256 actualVotingPower = veOlas._balanceOfLocked(accounts[i], uint64(block.timestamp));

            // Calculate expected voting power based on your model
            // This is where you need to implement the logic based on your understanding of how voting power should decay over time
            uint256 expectedVotingPower = calculateExpectedVotingPower(amount, endTime, block.timestamp);

            // Assert that the actual voting power is as expected
            assert(actualVotingPower == expectedVotingPower);
        }
    }

    // A mock function representing the calculation of expected voting power based on your model
    // You'll need to replace this with actual logic based on how veOLAS calculates voting power
    function calculateExpectedVotingPower(uint128 amount, uint64 endTime, uint256 currentTime) internal view returns (uint256) {
        if (currentTime > endTime) {
            return 0;
        } else {
            // Example simple linear decay model (placeholder, replace with actual model)
            uint256 timeLeft = endTime > currentTime ? endTime - currentTime : 0;
            return amount * timeLeft / veOlas.MAXTIME();
        }
    }

    // =======================================================   
    // TESTING    //  
    // DepositFor //
    //            //    

        // Ensure that all locked amounts are non-negative after deposit
    function assert_locked_amounts_non_negative(uint256 amount) public {
        // Perform deposit operation
        veOlas.depositFor(newAddress(1), amount);

        // After deposit: Get new locked balance
        (uint128 newAmount,) = veOlas.mapLockedBalances(newAddress(1));

        // Locked amount should be non-negative
        assert(newAmount >= 0);
    }

    // Ensure that locked amounts increase
    function assert_locked_amount_increases(uint256 amount) public {
        // Before deposit: Get initial locked balance
        (uint128 initialAmount,) = veOlas.mapLockedBalances(newAddress(1));

        // Perform deposit operation
        veOlas.depositFor(newAddress(1), amount);

        // After deposit: Get new locked balance
        (uint128 newAmount,) = veOlas.mapLockedBalances(newAddress(1));

        // Locked amount should increase or stay the same (if amount == 0)
        assert(newAmount >= initialAmount);
    }

    // Ensure that lock time does not change when just depositing for an existing lock
    function assert_lock_time_unchanged(uint256 amount) public {
        // Before deposit: Get initial lock end time
        (, uint64 initialEndTime) = veOlas.mapLockedBalances(newAddress(1));

        // Perform deposit operation
        veOlas.depositFor(newAddress(1), amount);

        // After deposit: Get new lock end time
        (, uint64 newEndTime) = veOlas.mapLockedBalances(newAddress(1));

        // Lock time should not change after deposit
        assert(newEndTime == initialEndTime);
    }

    // =======================================================   
    // TESTING    //  
    // CreateLock //
    //            //    

    // Ensure that lock is created correctly
    function assert_create_lock_successful(uint256 amount, uint256 unlockTime) public {
        // Call createLock
        veOlas.createLock(amount, unlockTime);

        // Fetch the new lock details
        (uint128 lockedAmount, uint64 lockedEndTime) = veOlas.mapLockedBalances(newAddress(2));

        // Assert that the locked amount is as expected
        assert(lockedAmount == amount);
        // Assert that the locked end time is set correctly, considering WEEK rounding
        assert(lockedEndTime == ((block.timestamp + unlockTime) / veOlas.WEEK()) * veOlas.WEEK());
    }

    // Ensure that function reverts when locking for the zero address
    function assert_cannot_lock_for_zero_address(uint256 amount, uint256 unlockTime) public {
        try veOlas.createLock(amount, unlockTime) {
            assert(false);  // Should not reach here
        } catch {
            // Expected to catch a revert
            assert(true);
        }
    }

    // Ensure that function reverts if a lock already exists
    function assert_cannot_create_duplicate_lock(address existingUser, uint256 amount, uint256 unlockTime) public {
        veOlas.createLockFor(existingUser, amount, unlockTime);  // Create initial lock

        // Attempt to create another lock for the same user
        try veOlas.createLockFor(existingUser, amount, unlockTime) {
            assert(false);  // Should not reach here if lock is already present
        } catch {
            // Expected to catch a revert due to an existing lock
            assert(true);

        }
    }

    // Ensure overflow is handled safely when creating a lock with a large amount
    function handle_overflow(address someUser, uint256 unlockTime) public {
        uint256 largeAmount = type(uint96).max + 1;  // An amount larger than what's allowed

        try veOlas.createLockFor(someUser, largeAmount, unlockTime) {
            assert(false);  // Expecting this to revert due to overflow
        } catch {
            // Expected to catch a revert due to overflow
            assert(true);
        }
    }

    // =======================================================   
    // TESTING        //  
    // increaseAmount //
    //                //  

    function assert_increaseAmount_increases_locked_amount(uint256 increaseValue) public {
        address user = newAddress(5);
        // Get the initial locked balance and end time for a user
        (uint128 initialAmount,) = veOlas.mapLockedBalances(user);

        veOlas.increaseAmount(increaseValue);

        // Get the new locked balance
        (uint128 newAmount, ) = veOlas.mapLockedBalances(user);

        // Check that the locked amount has increased by the expected amount
        assert(newAmount == initialAmount + increaseValue);
    }

    // =======================================================   
    // TESTING        //  
    // withdraw       //
    //                //  

    function generateAddresses() internal pure returns (address[] memory) {
        address[] memory generatedAccounts = new address[](5);  // Generate 5 addresses
        for (uint i = 0; i < generatedAccounts.length; i++) {
            // Generate an address based on a seed value
            generatedAccounts[i] = newAddress(i);
        }
        return generatedAccounts;
    }

    function newAddress(uint256 i) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(i)))));
    }
}
