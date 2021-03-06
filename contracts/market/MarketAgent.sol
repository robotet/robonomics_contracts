pragma solidity ^0.4.18;
import './Lot.sol';

/**
 * @title The market agent interface,
 *        market agent is contract presents a person on the market
 */
contract MarketAgent is Object {
    /**
     * @dev this event emitted for every lot deal
     */
    event LotDeal(address indexed _lot);

    /**
     * @dev Take a deal by given lot
     * @param _lot target lot address
     * @return `true` when deal is ok
     */
    function deal(Lot _lot) public onlyOwner returns (bool);
}
