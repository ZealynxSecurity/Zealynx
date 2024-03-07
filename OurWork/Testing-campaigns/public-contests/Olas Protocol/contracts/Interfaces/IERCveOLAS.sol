// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

/// @dev Interface of the ERC20 standard as defined in the EIP.
/// @dev This includes the optional name, symbol, and decimals metadata.
interface IERCveOLAS {
    /// @dev Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Emitted when the allowance of a `spender` for an `owner` is set, where `value`
    /// is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Returns the amount of tokens in existence.


    /// @notice Returns the name of the token.
    function name() external view returns (string memory);

    /// @notice Returns the symbol of the token.
    function symbol() external view returns (string memory);

    /// @notice Returns the decimals places of the token.
    function decimals() external view returns (uint8);

// OLAS
    // Define los errores
    error ManagerOnly(address sender, address manager);
    error ZeroAddress();

    // Define las funciones
    function changeOwner(address newOwner) external;
    function changeMinter(address newMinter) external;
    function mint(address account, uint256 amount) external;
    function inflationControl(uint256 amount) external view returns (bool);
    function inflationRemainder() external view returns (uint256 remainder);
    function burn(uint256 amount) external;
    function decreaseAllowance(address spender, uint256 amount) external returns (bool);
    function increaseAllowance(address spender, uint256 amount) external returns (bool);

    // Como hereda de ERC20, también puedes incluir las funciones ERC20 relevantes

//VEOLAS


    struct LockedBalance {
        uint128 amount;
        uint64 endTime;
    }

    struct PointVoting {
        int128 bias;
        int128 slope;
        uint64 ts;
        uint64 blockNumber;
        uint128 balance;
    }

    enum DepositType {
        DEPOSIT_FOR_TYPE,
        CREATE_LOCK_TYPE,
        INCREASE_LOCK_AMOUNT,
        INCREASE_UNLOCK_TIME
    }

    // Funciones externas
    function getLastUserPoint(address account) external view returns (PointVoting memory pv);
    function getNumUserPoints(address account) external view returns (uint256 accountNumPoints);
    function getUserPoint(address account, uint256 idx) external view returns (PointVoting memory);
    function checkpoint() external;
    function depositFor(address account, uint256 amount) external;
    function createLock(uint256 amount, uint256 unlockTime) external;
    function createLockFor(address account, uint256 amount, uint256 unlockTime) external;
    function increaseAmount(uint256 amount) external;
    function increaseUnlockTime(uint256 unlockTime) external;
    function withdraw() external;
    function balanceOf(address account) external view returns (uint256 balance);
    function lockedEnd(address account) external view returns (uint256 unlockTime);
    function balanceOfAt(address account, uint256 blockNumber) external view returns (uint256 balance);
    function getVotes(address account) external view returns (uint256);
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256 balance);
    function totalSupply() external view returns (uint256);
    function totalSupplyAt(uint256 blockNumber) external view returns (uint256 supplyAt);
    function totalSupplyLocked() external view returns (uint256);
    function getPastTotalSupply(uint256 blockNumber) external view returns (uint256);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function delegates(address account) external view returns (address);
    function delegate(address delegatee) external;
    function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) external;
}



