//SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import {SymTest} from "halmos-cheatcodes/SymTest.sol";
import {Test} from "forge-std/Test.sol";
import {Script, console2} from "forge-std/Script.sol";


import {IERCOLAS} from "src/Interfaces/IERCOLAS.sol";

abstract contract OLASERC20Test is SymTest, Test {
    // erc20 token address
    address internal token;
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
        uint256 oldBalanceOther = IERCOLAS(token).balanceOf(other);

        uint256 oldAllowance = IERCOLAS(token).allowance(other, caller);

        // consider an arbitrary function call to the token from the caller
        vm.prank(caller);
        (bool success,) = address(token).call(abi.encodePacked(selector, args));
        vm.assume(success);

        uint256 newBalanceOther = IERCOLAS(token).balanceOf(other);

        // ensure that the caller cannot spend other' tokens without approvals
        if (newBalanceOther < oldBalanceOther) {
            assert(oldAllowance >= oldBalanceOther - newBalanceOther);
        }
    }

//=================================================
// TRANSFER / TRANSFERFROM
//=================================================

    function _check_transfer(address sender, address receiver, address other, uint256 amount) public virtual {
        // consider other that are neither sender or receiver
        require(other != sender);
        require(other != receiver);

        // record their current balance
        uint256 oldBalanceSender   = IERCOLAS(token).balanceOf(sender);
        uint256 oldBalanceReceiver = IERCOLAS(token).balanceOf(receiver);
        uint256 oldBalanceOther   = IERCOLAS(token).balanceOf(other);

        vm.prank(sender);
        IERCOLAS(token).transfer(receiver, amount);

        if (sender != receiver) {
            assert(IERCOLAS(token).balanceOf(sender) <= oldBalanceSender); // ensure no subtraction overflow
            assert(IERCOLAS(token).balanceOf(sender) == oldBalanceSender - amount);
            assert(IERCOLAS(token).balanceOf(receiver) >= oldBalanceReceiver); // ensure no addition overflow
            assert(IERCOLAS(token).balanceOf(receiver) == oldBalanceReceiver + amount);
        } else {
            // sender and receiver may be the same
            assert(IERCOLAS(token).balanceOf(sender) == oldBalanceSender);
            assert(IERCOLAS(token).balanceOf(receiver) == oldBalanceReceiver);
        }
        // make sure other balance is not affected
        assert(IERCOLAS(token).balanceOf(other) == oldBalanceOther);
    }

    function _check_transferFrom(address caller, address from, address to, address other, uint256 amount) public virtual {
        require(other != from);
        require(other != to);

        uint256 oldBalanceFrom   = IERCOLAS(token).balanceOf(from);
        uint256 oldBalanceTo     = IERCOLAS(token).balanceOf(to);
        uint256 oldBalanceOther = IERCOLAS(token).balanceOf(other);

        uint256 oldAllowance = IERCOLAS(token).allowance(from, caller);

        vm.prank(caller);
        IERCOLAS(token).transferFrom(from, to, amount);

        if (from != to) {
            assert(IERCOLAS(token).balanceOf(from) <= oldBalanceFrom);
            assert(IERCOLAS(token).balanceOf(from) == oldBalanceFrom - amount);
            assert(IERCOLAS(token).balanceOf(to) >= oldBalanceTo);
            assert(IERCOLAS(token).balanceOf(to) == oldBalanceTo + amount);

            assert(oldAllowance >= amount); // ensure allowance was enough
            assert(oldAllowance == type(uint256).max || IERCOLAS(token).allowance(from, caller) == oldAllowance - amount); // allowance decreases if not max
        } else {
            assert(IERCOLAS(token).balanceOf(from) == oldBalanceFrom);
            assert(IERCOLAS(token).balanceOf(to) == oldBalanceTo);
        }
        assert(IERCOLAS(token).balanceOf(other) == oldBalanceOther);
    }


//=================================================
// APPROVE / IN DECREASSEALOWANCE 
//=================================================


    function _checkApprove(bytes4 selector, bytes memory args, address caller, address other) public virtual {
        // consider two arbitrary distinct accounts
        vm.assume(other != caller);

        // record their current balances
        uint256 oldBalanceOther = IERCOLAS(token).balanceOf(other);

        uint256 oldAllowance = IERCOLAS(token).allowance(other, caller);

        // consider an arbitrary function call to the token from the caller
        vm.startPrank(caller);
        // (bool success,) = address(token).call(abi.encodePacked(other, args));
        // vm.assume(success);
        IERCOLAS(token).increaseAllowance(other, svm.createUint256("deadline"));
        IERCOLAS(token).decreaseAllowance(other, svm.createUint256("deadline"));

        uint256 newBalanceOther = IERCOLAS(token).balanceOf(other);
        uint256 newAllowance = IERCOLAS(token).allowance(other, caller);
        vm.stopPrank();


        // ensure that the caller cannot spend other' tokens without approvals
        if (newBalanceOther < oldBalanceOther) {
            assert(oldAllowance >= newAllowance);
        }
    }

// INVARIANT TEST 

//inflation_remainder_within_cap()
    function _check_invariant_Foo(bytes4[] memory selectors, bytes[] memory data) public {
        for (uint i = 0; i < selectors.length; i++) {
            (bool success,) = address(token).call(abi.encodePacked(selectors[i], data[i]));
            vm.assume(success);
            assert(IERCOLAS(token).inflationRemainder() <= IERCOLAS(token).tenYearSupplyCap() - IERCOLAS(token).totalSupply());

        }
    }


    
}


    //     // Allowance should be modified correctly via increase/decrease
    // function _check_test_ERC20_setAndIncreaseAllowance(
    //     bytes4 selector,
    //     bytes memory args,
    //     address caller,
    //     address target,
    //     uint256 initialAmount,
    //     uint256 increaseAmount
    // ) public {

    //     require(caller != target);

    //     vm.startPrank(caller);
    //     bool r = IERCOLAS(token).approve(target, initialAmount);
    //     assertTrue(r,"Failed to set initial allowance via approve");
    //     assertEq(
    //         IERCOLAS(token).allowance(address(this), target),
    //         initialAmount,
    //         "Allowance not set correctly"
    //     );
    // //   // consider an arbitrary function call to the token from the caller
    // //     (bool success,) = address(token).call(abi.encodePacked(selector, args));
    // //     vm.assume(success);

    //     bool t = IERCOLAS(token).increaseAllowance(target, increaseAmount);
    //     assertTrue(t,"Failed to increase allowance");

    //     uint256 parametroa = IERCOLAS(token).allowance(address(this), target);
    //     uint256 parametrob = initialAmount + increaseAmount;
    //     vm.stopPrank();
    //     console2.log("aaaa",parametroa);
    //     console2.log("bbb",parametrob);

    //     assertEq(
    //         parametroa,
    //         parametrob,
    //         "Allowance not increased correctly"
    //     );
    //     emit Result( parametroa, parametrob);

    // }