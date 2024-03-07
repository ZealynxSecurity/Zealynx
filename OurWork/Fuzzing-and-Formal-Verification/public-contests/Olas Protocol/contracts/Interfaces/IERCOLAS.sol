// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

/// @dev Interface of the ERC20 standard as defined in the EIP.
/// @dev This includes the optional name, symbol, and decimals metadata.
interface IERCOLAS {
    /// @dev Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Emitted when the allowance of a `spender` for an `owner` is set, where `value`
    /// is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Returns the amount of tokens in existence.
    function totalSupply() external view returns (uint256);

    /// @notice Returns the amount of tokens owned by `account`.
    function balanceOf(address account) external view returns (uint256);

    /// @notice Moves `amount` tokens from the caller's account to `to`.
    function transfer(address to, uint256 amount) external returns (bool);

    /// @notice Returns the remaining number of tokens that `spender` is allowed
    /// to spend on behalf of `owner`
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice Sets `amount` as the allowance of `spender` over the caller's tokens.
    /// @dev Be aware of front-running risks: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice Moves `amount` tokens from `from` to `to` using the allowance mechanism.
    /// `amount` is then deducted from the caller's allowance.
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    /// @notice Returns the name of the token.
    function name() external view returns (string memory);

    /// @notice Returns the symbol of the token.
    function symbol() external view returns (string memory);

    /// @notice Returns the decimals places of the token.
    function decimals() external view returns (uint8);

    // OLAS
    // Events
    event MinterUpdated(address indexed minter);
    event OwnerUpdated(address indexed owner);

    // Functions
    function changeOwner(address newOwner) external;
    function changeMinter(address newMinter) external;
    function mint(address account, uint256 amount) external;
    function inflationControl(uint256 amount) external view returns (bool);
    function inflationRemainder() external view returns (uint256 remainder);
    function burn(uint256 amount) external;
    function decreaseAllowance(address spender, uint256 amount) external returns (bool);
    function increaseAllowance(address spender, uint256 amount) external returns (bool);

    // Constants
    function oneYear() external view returns (uint256);
    function tenYearSupplyCap() external view returns (uint256);
    function maxMintCapFraction() external view returns (uint256);
    function timeLaunch() external view returns (uint256);

    // State Variables
    function owner() external view returns (address);
    function minter() external view returns (address);

}
