// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract C {
    bool value_found = false;

    function magic(uint256 magic_1, uint256 magic_2, uint256 magic_3, uint256 magic_4) public {
        require(magic_1 == 42);
        require(magic_2 == 129);
        require(magic_3 == magic_4 + 333);
        value_found = true;
        return;
    }

    function assert_magic_values() public view returns (bool) {
        return !value_found;
    }
}