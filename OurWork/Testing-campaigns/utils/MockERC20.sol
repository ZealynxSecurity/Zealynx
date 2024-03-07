// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is AccessControl, ERC20 {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint8 private __decimals = 18;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        // _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // _setupRole(MINTER_ROLE, msg.sender);
    }

    function decimals() public view override returns (uint8) {
        return __decimals;
    }

    function setDecimals(uint8 _decimals) external {
        __decimals = _decimals;
    }

    function mint(address _to, uint256 _value) external {
        _mint(_to, _value);
    }
}
 //onlyRole(MINTER_ROLE)