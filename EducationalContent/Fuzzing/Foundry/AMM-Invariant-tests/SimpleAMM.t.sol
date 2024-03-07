// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import "../src/SimpleAMM.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import "./handlers/SimpleAMMHandler.sol";
import "../openzeppelin/IERC20.sol";

contract SimpleAMMTest is StdInvariant, Test {
    SimpleAMM simpleAMM;
    SimpleAMMHandler simpleAMMHandler;
    IERC20 tokenA;
    IERC20 tokenB;

    // Token contract addresses
    address tokenAAddress;
    address tokenBAddress;

    function setUp() public {
        simpleAMM = new SimpleAMM();
        simpleAMMHandler = new SimpleAMMHandler(simpleAMM);

        tokenAAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        tokenBAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

        tokenA = IERC20(tokenAAddress);
        tokenB = IERC20(tokenBAddress);

        // Add some initial liquidity for testing purposes
        targetContract(address(simpleAMMHandler));
    }

    // Invariant: Constant Product Invariant
    function invariant_ConstantProduct() public {
        uint256 reserveTokenA = simpleAMM.reserveTokenA();
        uint256 reserveTokenB = simpleAMM.reserveTokenB();
        uint256 constantProduct = simpleAMM.constantProduct();
        assertEq(
            reserveTokenA * reserveTokenB,
            constantProduct,
            "Constant product invariant violated"
        );
    }

    // Invariant: Reserve Non-Negativity
    function invariant_ReserveNonNegativity() public {
        assertGe(simpleAMM.reserveTokenA(), 0, "reserveTokenA is negative");
        assertGe(simpleAMM.reserveTokenB(), 0, "reserveTokenB is negative");
    }

    // Invariant: Swap Rate Fairness
    function invariant_SwapRateFairness() public {
        uint256 reserveTokenA = simpleAMM.reserveTokenA();
        uint256 reserveTokenB = simpleAMM.reserveTokenB();
        uint256 constantProduct = simpleAMM.constantProduct();

        // Allow for a small tolerance due to integer division rounding
        uint256 tolerance = 1; // Define an appropriate tolerance

        uint256 product = reserveTokenA * reserveTokenB;
        bool isProductCloseToConstant = (product >=
            constantProduct - tolerance) &&
            (product <= constantProduct + tolerance);

        assertTrue(
            isProductCloseToConstant,
            "Swap rate fairness violated: Product of reserves not close to constant product"
        );
    }

    // Invariant: Liquidity Addition and Removal Consistency
    function invariant_LiquidityAdditionRemovalConsistency() public {
        uint256 initialReserveA = simpleAMM.reserveTokenA();
        uint256 initialReserveB = simpleAMM.reserveTokenB();

        // Perform a test liquidity addition and removal
        uint256 testAmountA = 500; // Choose appropriate test amounts
        uint256 testAmountB = 500;
        simpleAMMHandler.addLiquidity(testAmountA, testAmountB);
        simpleAMMHandler.removeLiquidity(testAmountA, testAmountB);

        uint256 finalReserveA = simpleAMM.reserveTokenA();
        uint256 finalReserveB = simpleAMM.reserveTokenB();

        // Assert the final reserves are equal to the initial reserves
        assertEq(
            finalReserveA,
            initialReserveA,
            "Reserve A should remain unchanged after add/remove liquidity"
        );
        assertEq(
            finalReserveB,
            initialReserveB,
            "Reserve B should remain unchanged after add/remove liquidity"
        );
    }

    // // Invariant: No Token Creation or Destruction
    // function invariant_NoTokenCreationDestruction() public {
    //     // Replace `TokenA` and `TokenB` with actual token contract references
    //     // Keep in mind this is a simplified AMM with only one known pair
    //     uint256 totalSupplyA = tokenA.totalSupply();
    //     uint256 totalSupplyB = tokenB.totalSupply();

    //     uint256 reserveA = simpleAMM.reserveTokenA();
    //     uint256 reserveB = simpleAMM.reserveTokenB();

    //     // Calculating total tokens held by users (excluding reserves)
    //     // This could be handled in multiple ways and since it's not relevant for
    //     // the sake of our invariant test exercise, assume it does what it says
    //     uint256 userHeldA = calculateUserHeldTokens(tokenA);
    //     uint256 userHeldB = calculateUserHeldTokens(tokenB);

    //     // Asserting that total supply equals sum of reserves and user-held tokens
    //     assertEq(
    //         totalSupplyA,
    //         reserveA + userHeldA,
    //         "Token A conservation violated"
    //     );
    //     assertEq(
    //         totalSupplyB,
    //         reserveB + userHeldB,
    //         "Token B conservation violated"
    //     );
    // }

    // Invariant: Positive Liquidity
    function invariant_PositiveLiquidity() public {
        uint256 reserveA = simpleAMM.reserveTokenA();
        uint256 reserveB = simpleAMM.reserveTokenB();

        // Check that both reserves are greater than zero
        assertTrue(reserveA > 0, "Liquidity for token A is not positive");
        assertTrue(reserveB > 0, "Liquidity for token B is not positive");
    }

    // Invariant: Swap Amount Validation
    function invariant_SwapAmountValidation() public {
        uint256 reserveTokenB = simpleAMM.reserveTokenB();
        uint256 randomAmountTokenA = 1234; // Generate a random amount of Token A

        uint256 swapAmountB = simpleAMM.getSwapAmount(randomAmountTokenA);

        // Check that both reserves are greater than zero
        assertTrue(
            swapAmountB <= reserveTokenB,
            "Swap amount exceeds reserveTokenB"
        );
    }

    // Invariant: Solvency
    function invariant_Solvency() public {
        uint256 reserveTokenA = simpleAMM.reserveTokenA();
        uint256 reserveTokenB = simpleAMM.reserveTokenB();
        uint256 minimumReserveThreshold = 500;

        // Ensure reserves are above a minimum threshold
        assertTrue(
            reserveTokenA > minimumReserveThreshold,
            "Insufficient ReserveTokenA for solvency"
        );
        assertTrue(
            reserveTokenB > minimumReserveThreshold,
            "Insufficient ReserveTokenB for solvency"
        );
    }

    // Invariant: User Balance Consistency
    function invariant_UserBalanceConsistency() public {
        address[] memory userAddresses = simpleAMMHandler.getUserAddresses();
        for (uint i = 0; i < userAddresses.length; i++) {
            address user = userAddresses[i];

            uint256 expectedBalanceA = simpleAMMHandler
                .ghost_expectedBalanceTokenA(user);
            uint256 actualBalanceA = tokenA.balanceOf(user);
            assertEq(
                expectedBalanceA,
                actualBalanceA,
                "User balance inconsistency for Token A"
            );

            uint256 expectedBalanceB = simpleAMMHandler
                .ghost_expectedBalanceTokenB(user);
            uint256 actualBalanceB = tokenB.balanceOf(user);
            assertEq(
                expectedBalanceB,
                actualBalanceB,
                "User balance inconsistency for Token B"
            );
        }
    }
}
