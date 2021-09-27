// Sources flattened with hardhat v2.6.4 https://hardhat.org

// File @openzeppelin/contracts/utils/Context.sol@v4.3.2

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v4.3.2

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/util/Manager.sol

// SPDX-License-Identifier: GPL
pragma solidity ^0.8.0;

// allows a manager separate from owner
contract Manager is Ownable {
    address public mgr;         // address allowed to manager

    event ManagerChanged(address indexed from, address indexed to);

    constructor() {
        mgr = owner();
    }

    /**
     * @dev checks that caller is either owner or keeper.
     */
    modifier onlyManager() {
        require(msg.sender == owner() || msg.sender == mgr, "!manager");
        _;
    }

    /**
     * @dev Updates the address of strategy manager.
     * @param _mgr new keeper address.
     */
    function setManager(address _mgr) public onlyManager {
        address current = mgr;
        mgr = _mgr;
        emit ManagerChanged(current, _mgr);
    }
}


// File contracts/util/GasThrottler.sol

// SPDX-License-Identifier: GPL
pragma solidity ^0.8.0;


contract GasThrottler is Manager {

    uint256 public maxGas = 10000000000; // 10 gwei

    constructor(uint256 _max) {
        maxGas = _max;
    }

    /**
     * @dev Updates the gas fee.
     * @param _max new maximum gas price
     */
    function updateGas(uint256 _max) external onlyManager {
        maxGas = _max;
    }

    modifier gasThrottle() {
        require(tx.gasprice <= maxGas, "gas is too high!");
        _;
    }
}