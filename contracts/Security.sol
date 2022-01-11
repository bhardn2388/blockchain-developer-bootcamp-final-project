// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "@openzeppelin/contracts/access/AccessControl.sol";
/// @title Security
/// @author Nishant Bhardwaj
/// @notice This contract allows to implement the openzepplin access control contract 
/// @dev The contract inherits openzepplin AccessControl.sol
contract Security is AccessControl {
    /// @dev Define a Seller Role
    bytes32 public constant SELLER_ROLE = keccak256("Seller");
    /// @dev Define a Customer Role
    bytes32 public constant CUSTOMER_ROLE = keccak256("Customer");
    
    /// @notice Constrcutor Assigns Admin role to the deployer of the contract
    /// @dev DEFAULT_ADMIN_ROLE is role inherited from AccessControl.sol
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "Restricted only to admins");
        _;
    }
    modifier onlySeller() {
        require(isSeller(msg.sender), "Restricted only to Seller");
        _;
    }
    modifier onlyCustomer() {
        require(isCustomer(msg.sender), "Restricted only to Customer");
        _;
    }
    /// @notice Checks if an account is an Admin
    /// @param account which is the public address
    /// @dev makes a call to the inherited function hasRole in AccessControl.sol
    /// @return true or false
    function isAdmin(address account) public view virtual returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }
    /// @notice Checks if an account is a Seller
    /// @param account which is the public address
    /// @dev makes a call to the inherited function hasRole in AccessControl.sol
    /// @return true or false
    function isSeller(address account) public view virtual returns (bool) {
        return hasRole(SELLER_ROLE, account);
    }
    /// @notice Checks if an account is a Customer
    /// @param account which is the public address
    /// @dev makes a call to the inherited function hasRole in AccessControl.sol
    /// @return true or false
    function isCustomer(address account) public view virtual returns (bool) {
        return hasRole(CUSTOMER_ROLE, account);
    }
    /// @notice Grants an account the Seller Role
    /// @param account which is the public address
    /// @dev makes a call to the inherited function grantRole in AccessControl.sol
    /// @dev can only be called by admin
    function addSeller(address account) public virtual onlyAdmin {
        grantRole(SELLER_ROLE, account);
    }
    /// @notice Revokes Seller role from an account
    /// @param account which is the public address
    /// @dev makes a call to the inherited function revokeRole in AccessControl.sol
    /// @dev can only be called by admin
    function removeSeller(address account) public virtual onlyAdmin {
        revokeRole(SELLER_ROLE, account);
    }
    /// @notice Grants an account the Customer Role
    /// @param account which is the public address
    /// @dev makes a call to the inherited function _grantRole in AccessControl.sol
    /// @dev _grantRole does not require to be called by admins
    function addCustomer(address account) public virtual {
        _grantRole(CUSTOMER_ROLE, account);
    }
    /// @notice Revokes Customer role from an account
    /// @param account which is the public address
    /// @dev makes a call to the inherited function revokeRole in AccessControl.sol
    /// @dev can only be called by admin
    function removeCustomer(address account) public virtual onlyAdmin {
        revokeRole(CUSTOMER_ROLE, account);
    }

}
