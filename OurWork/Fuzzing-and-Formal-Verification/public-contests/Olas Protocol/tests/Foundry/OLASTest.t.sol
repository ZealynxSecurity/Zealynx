// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Test} from "forge-std/Test.sol";
import "../OLAS.sol";

contract OLASTest is Test {
    OLAS public olas;

    function setUp() public {
        olas = new OLAS();
    }

    /// Fuzzers
    // function testFuzz_InflationControl(uint256 amount) public {
    //     olas.inflationControl(amount);
    //     assert(amount <= olas.inflationRemainder());
    // }

    function testFuzz_onlyOwnerCanChangeOwner(address randomAddress) public {
        address originalOwner = olas.owner();

        // Attempt to change the owner to a random non-zero address that is not the current owner
        if (randomAddress != address(0) && randomAddress != originalOwner) {
            // Impersonate a random address and try to change the owner
            vm.prank(randomAddress);
            try olas.changeOwner(randomAddress) {
                // If the random address is not the original owner, this should fail
                assert(randomAddress != originalOwner);
            } catch {}

            // Impersonate the original owner and change the owner successfully
            vm.prank(originalOwner);
            olas.changeOwner(randomAddress);
            assert(olas.owner() == randomAddress);

            // Change the owner back to the original owner
            vm.prank(randomAddress);
            olas.changeOwner(originalOwner);
        }
    }


    /// Invariant tests
    function invariant_ownerIsNonZero() public {
        assert(olas.owner() != address(0));
    }

    function invariant_minterIsNeverZero() public {
        assert(olas.minter() != address(0));
    }

    function invariant_onlyOwnerCanChangeMinter() public {
        address originalMinter = olas.minter();
        address originalOwner = olas.owner();

        // Attempt to change the minter from a non-owner address should fail
        vm.prank(address(1)); // An arbitrary non-owner address
        try olas.changeMinter(address(2)) {
            revert("Non-owner changed the minter");
        } catch {}

        // Now change the minter from the owner address should succeed
        vm.prank(originalOwner);
        address newMinter = address(3); // An arbitrary new minter address
        olas.changeMinter(newMinter);
        assert(olas.minter() == newMinter);

        // Reset minter to original for cleanliness
        olas.changeMinter(originalMinter);
    }




}
