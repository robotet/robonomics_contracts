pragma solidity ^0.4.18;
import './MarketRule.sol';
import 'common/Object.sol';

/**
 * @title The constant market rule, return constant emission value for every deal
 */
contract MarketRuleConstant is Object, MarketRule {
    uint public emission;

    function MarketRuleConstant(uint _emission) public
    { emission = _emission; }

    /**
     * @dev How amount of token emission needed when given lot is deal
     * @param _deal lot address
     * @return count of emission token value
     */
    function getEmission(Lot _deal) public returns (uint)
    { return emission; }
}
