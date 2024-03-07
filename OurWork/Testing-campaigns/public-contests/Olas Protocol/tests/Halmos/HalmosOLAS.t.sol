// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import {OLASERC20Test} from "./OLASERC20Test.sol";

import {OLAS} from "../OLAS.sol";

/// @custom:halmos --solver-timeout-assertion 0
contract HalmosOLAS is OLASERC20Test {

    /// @custom:halmos --solver-timeout-branching 1000
    function setUp() public override {
        address deployer = address(0x1000);

        vm.prank(deployer);
        OLAS token_ = new OLAS();
        token = address(token_);
        uint256 supp = svm.createUint256("supp");
        vm.prank(deployer);
        token_.mint(deployer, supp);


        holders = new address[](3);
        holders[0] = address(0x1001);
        holders[1] = address(0x1002);
        holders[2] = address(0x1003);

        for (uint i = 0; i < holders.length; i++) {
            address account = holders[i];
            uint256 balance = svm.createUint256('balance');
            vm.prank(deployer);
            token_.transfer(account, balance);
            for (uint j = 0; j < i; j++) {
                address other = holders[j];
                uint256 amount = svm.createUint256('amount');
                vm.prank(account);
                token_.approve(other, amount);
            }
        }
    }

    function check_NoBackdoor(bytes4 selector, address caller, address other) public {
        bytes memory args = svm.createBytes(1024, 'data');
        _checkNoBackdoor(selector, args, caller, other);
    }

    function check_transfer(address sender, address receiver, address other, uint256 amount) public {
        _check_transfer(sender, receiver, other, amount);
    }

    function check_transferFrom(address caller, address from, address to, address other, uint256 amount) public virtual {
        _check_transferFrom(caller, from, to, other, amount);
    }

    // function check_test_ERC20_setAndIncreaseAllowance(bytes4 selector, address caller, address target,uint256 initialAmount,uint256 increaseAmount) public {
    //     bytes memory args = svm.createBytes(1024, 'data');
    //     _check_test_ERC20_setAndIncreaseAllowance( selector, args, caller, target, initialAmount, increaseAmount);
    // }

    function check_Approve(bytes4 selector, address caller, address other) public {
        bytes memory args = svm.createBytes(1024, 'data');
        _checkApprove(selector, args, caller, other);
    }

    function check_invariant_Foo(bytes4[] memory selectors, bytes[] memory data) public {
         _check_invariant_Foo( selectors,  data);
    }


}
