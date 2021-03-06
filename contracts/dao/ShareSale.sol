pragma solidity ^0.4.18;

import 'common/Object.sol';
import 'token/TokenEther.sol';

/**
 * @title Contract for direct sale shares for cashflow 
 */
contract ShareSale is Object {
    // Assigned shares contract
    Token public shares;

    // Ether fund token 
    TokenEther public etherFund;

    // Target address for funds
    address public target;

    // Price of one share
    uint public priceWei;

    // Time of sale
    uint public closed = 0;

    /**
     * @dev Set price of one share in Wei
     * @param _price_wei is share price
     */
    function setPrice(uint _price_wei) public onlyOwner
    { priceWei = _price_wei; }
    
    /**
     * @dev Create the contract for given cashflow and start price
     * @param _target is a target of funds
     * @param _etherFund is a ether wallet token
     * @param _shares is a shareholders token contract 
     * @param _price_wei is a price of one share
     * @notice After creation you should send shares to contract for sale
     */
    function ShareSale(address _target, address _etherFund,
                       address _shares, uint _price_wei) public {
        target    = _target;
        etherFund = TokenEther(_etherFund);
        shares    = Token(_shares);
        priceWei  = _price_wei;
    }

    /**
     * @dev This fallback method receive ethers and exchange available shares 
     *      by price, setted by owner.
     * @notice only full packet of shares can be saled
     */
    function () public payable {
        var value = shares.balanceOf(this) * priceWei;

        require(closed == 0);
        require(msg.value >= value);
        msg.sender.transfer(msg.value - value);

        require(etherFund.refill.value(value)());
        require(etherFund.transfer(target, value));
        require(shares.transfer(msg.sender, shares.balanceOf(this)));

        closed = now;
    }

    function destroy() public onlyHammer {
        // Save the shares
        require(shares.transfer(owner, shares.balanceOf(this)));

        super.destroy();
    }
}
