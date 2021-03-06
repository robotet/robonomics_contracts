pragma solidity ^0.4.18;
/** @title Unit test interface */
contract TestCase {
    /* This field is a short test description */
    string public name;

    /** @dev This method contains single check
     *       and returns true when all is OK */
    function run() public returns (bool);
}
