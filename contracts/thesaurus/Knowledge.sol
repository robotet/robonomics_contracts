pragma solidity ^0.4.18;
import 'common/Object.sol';

/**
 * Knowledge is a generic declaration of object or process
 */
contract Knowledge is Object {
    /* Knowledge can have a type described below */
    int8 constant OBJECT  = 1;
    int8 constant PROCESS = 2;

    /* Knowledge type is a int value */
    int public knowledgeType;

    function Knowledge(int8 _type) public
    { knowledgeType = _type; }

    /**
     * Generic Knowledge comparation procedure
     * @param _to compared knowledge address
     * @return `true` when knowledges is equal
     */
    function isEqual(Knowledge _to) public view returns (bool);
}
