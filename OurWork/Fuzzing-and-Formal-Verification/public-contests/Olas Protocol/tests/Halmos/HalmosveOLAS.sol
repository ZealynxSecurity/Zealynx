// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import {veERC20Test} from "./veERC20Test.sol";

import {veOLAS} from "../veOLAS.sol";
import {OLAS} from "../OLAS.sol";

/// @custom:halmos --solver-timeout-assertion 0
contract HalmosveOLAS is veERC20Test {

    /// @custom:halmos --solver-timeout-branching 1000
    function setUp() public override {
        address deployer = address(0x1000);

        vm.prank(deployer);
        OLAS _olas = new OLAS();
        olas = address(_olas);

        vm.prank(deployer);
        veOLAS token_ = new veOLAS(olas, "name", "symbol");
        token = address(token_);

        uint256 supp = svm.createUint256("supp");
        vm.prank(deployer);
        _olas.mint(deployer, supp);


        holders = new address[](3);
        holders[0] = address(0x1001);
        holders[1] = address(0x1002);
        holders[2] = address(0x1003);

        for (uint i = 0; i < holders.length; i++) {
            address account = holders[i];
            uint256 balance = svm.createUint256('balance');
            vm.prank(deployer);
            _olas.transfer(account, balance);
            for (uint j = 0; j < i; j++) {
                address other = holders[j];
                uint256 amount = svm.createUint256('amount');
                vm.prank(account);
                _olas.approve(other, amount);
            }
        }
    }

    function check_NoBackdoor(bytes4 selector, address caller, address other) public {
        bytes memory args = svm.createBytes(1024, 'data');
        _checkNoBackdoor(selector, args, caller, other);
    }



    // function check_increaseAmount_increases_locked_amount(uint256 increaseValue, address caller) public {
    //     _check_increaseAmount_increases_locked_amount(increaseValue,caller);
    // }

    // function check_testFuzz_HalmosBalanceAndSupply(uint256 tenOLABalance1, uint256 oneOLABalance1,uint256 twoOLABalance1,uint256 oneWeek,address sender, address other) public {

    //     _check_testFuzz_HalmosBalanceAndSupply(tenOLABalance1, oneOLABalance1,twoOLABalance1,oneWeek,sender, other);
    // }


}