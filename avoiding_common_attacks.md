# Contract security measures

## SWC-103 (Floating pragma)

Specific compiler pragma `0.8.11` used in contracts to avoid accidental bug inclusion through outdated compiler versions.

## Proper Use of Require, Assert and Revert 
Require statements are used within functions to make sure passed in parameters meet the requirements, and to make sure only relevant roles are able to call the functions

## Modifiers used only for validation

All modifiers in contract(s) only validate data with `require` statements.

## Pull over push

All functions that modify state are based on receiving calls rather than making contract calls.