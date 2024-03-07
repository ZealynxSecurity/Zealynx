// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import {SymTest} from "halmos-cheatcodes/SymTest.sol";
import {Test} from "forge-std/Test.sol";
import {Script, console2} from "forge-std/Script.sol";


import {IERCveOLAS} from "src/Interfaces/IERCveOLAS.sol";


abstract contract veERC20Test is SymTest, Test {
    // erc20 token address
    address public token;
    address internal olas;

    // token holders
    address[] internal holders;
    event Result (uint256 parametroa, uint256 parametrob);
    function setUp() public virtual;


//=================================================
// BACKDOR
//=================================================

    function _checkNoBackdoor(bytes4 selector, bytes memory args, address caller, address other) public virtual {
        // consider two arbitrary distinct accounts
        vm.assume(other != caller);

        // record their current balances
        uint256 oldBalanceOther = IERCveOLAS(olas).balanceOf(other);

        uint256 oldAllowance = IERCveOLAS(olas).allowance(other, caller);

        // consider an arbitrary function call to the token from the caller
        vm.prank(caller);
        (bool success,) = address(token).call(abi.encodePacked(selector, args));
        vm.assume(success);

        uint256 newBalanceOther = IERCveOLAS(olas).balanceOf(other);

        // ensure that the caller cannot spend other' tokens without approvals
        if (newBalanceOther < oldBalanceOther) {
            assert(oldAllowance >= oldBalanceOther - newBalanceOther);
        }
    }

    // function _check_increaseAmount_increases_locked_amount(uint256 increaseValue, address caller) public {
    //     // Get the initial locked balance and end time for a user
    //     (uint initialAmount) = IERCveOLAS(token).balanceOf(caller);

    //     vm.prank(caller);
    //     IERCveOLAS(token).increaseAmount(increaseValue);

    //     // Get the new locked balance
    //     (uint newAmount ) = IERCveOLAS(token).balanceOf(caller);

    //     // Check that the locked amount has increased by the expected amount
    //     assert(newAmount == initialAmount + increaseValue);
    // }

    // function _check_testFuzz_HalmosBalanceAndSupply(uint256 tenOLABalance1, uint256 oneOLABalance1,uint256 twoOLABalance1,uint256 oneWeek,address sender, address other) public {

    //     vm.assume(oneOLABalance1 != 0);
    //     vm.assume(twoOLABalance1 != 0);
    //     vm.expectRevert(bytes("Overflow"));


    //     vm.prank(sender);
    //     // Transferir 10 OLAS a account
    //     olas.transfer(other, tenOLABalance1);
    //     vm.prank(sender);

    //     // Aprobar OLAS para el contrato veOLAS
    //     olas.approve(address(token), oneOLABalance1);
    //     vm.prank(other); // Impersonar account para la aprobación
    //     olas.approve(address(token), tenOLABalance1);

    //     // Verificar suministro inicial
    //     uint256 lockDuration = oneWeek; // Duración de 1 semana
    //     vm.assume(lockDuration != 0);
    //     // vm.expectRevert(bytes("UnlockTimeIncorrect"));

    //     vm.prank(sender);
    //     // Crear bloqueos
    //     token.createLock(oneOLABalance1, lockDuration);
    //     vm.prank(other); // Impersonar account para crear bloqueo
    //     token.createLock(twoOLABalance1, lockDuration);

    //     // Verificar suministro y balance
    //     uint256 balanceDeployer = token.getVotes(address(sender));
    //     uint256 balanceAccount = token.getVotes(other);
    //     uint256 supply = token.totalSupplyLocked();
    //     uint256 sumBalance = balanceAccount + balanceDeployer;
        
    //     assert(supply == sumBalance);

    //     uint256 blockNumber = block.number; // Número de bloque actual en Foundry

    //     // Verificar balance en un bloque específico
    //     balanceDeployer = token.balanceOfAt(address(sender), blockNumber);
    //     balanceAccount = token.balanceOfAt(other, blockNumber);

    //     supply = token.totalSupplyAt(blockNumber);
    //     sumBalance = balanceAccount + balanceDeployer;

    //     assert(supply == sumBalance);
    // }





// //=================================================
// // APPROVE / IN DECREASSEALOWANCE 
// //=================================================

//         // Allowance should be modified correctly via increase/decrease
//     function _check_test_ERC20_setAndIncreaseAllowance(
//         bytes4 selector,
//         bytes memory args,
//         address caller,
//         address target,
//         uint256 initialAmount,
//         uint256 increaseAmount
//     ) public {

//         require(caller != target);

//         vm.startPrank(caller);
//         bool r = IERCveOLAS(token).approve(target, initialAmount);
//         assertTrue(r,"Failed to set initial allowance via approve");
//         assertEq(
//             IERCveOLAS(token).allowance(address(this), target),
//             initialAmount,
//             "Allowance not set correctly"
//         );
//       // consider an arbitrary function call to the token from the caller
//         // (bool success,) = address(token).call(abi.encodePacked(selector, args));
//         // vm.assume(success);

//         bool t = IERCveOLAS(token).increaseAllowance(target, increaseAmount);
//         assertTrue(t,"Failed to increase allowance");

//         uint256 parametroa = IERCveOLAS(token).allowance(address(this), target);
//         uint256 parametrob = initialAmount + increaseAmount;
//         vm.stopPrank();
//         console2.log("aaaa",parametroa);
//         console2.log("bbb",parametrob);

//         assertEq(
//             parametroa,
//             parametrob,
//             "Allowance not increased correctly"
//         );
//         emit Result( parametroa, parametrob);

//     }


}