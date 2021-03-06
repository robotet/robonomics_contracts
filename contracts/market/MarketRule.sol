pragma solidity ^0.4.18;
import './Lot.sol';

/**
 * @title The market rule interface 
 */
contract MarketRule {
    /**
     * @dev How amount of token emission needed when given lot is deal
     * @param _deal lot address
     * @return count of emission token value
     */
    function getEmission(Lot _deal) public returns (uint);
}
