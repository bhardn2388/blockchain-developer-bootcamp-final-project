# Design patterns

## Access Control Design Patterns

- `Role-based` design pattern used. The Security.sol contract inherits from the OpenZeppplins' AccessControl.sol. Security.sol is in inturn inherited by Farmshop.sol.This makes sure:
  - registerSeller is only called by admins
  - AddProduce is only called by seller role
  - Purchase produce is only called by customer role

## Inheritance and Interfaces

- `Security.sol` contract inherits the OpenZeppelin `AccessControl` contract to enable role based security.
- `Farmshop.sol` inherits from Security.sol.