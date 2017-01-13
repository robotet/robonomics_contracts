pragma solidity ^0.4.2;
import 'common/Mortal.sol';
import 'lib/SecurityRings.sol';

contract Proxy is Mortal {
    SecurityRings.Data rings;
    using SecurityRings for SecurityRings.Data;

    /**
     * @dev Authorization node info
     * @param _ring Ring index
     * @param _gate Gate index
     * @return (Auth node address, Auth node ident (user identificator))
     */
    function authAt(uint _ring, uint _gate) constant returns (address, bytes32)
    { return rings.authAt(_ring, _gate); }

    /**
     * @dev Get user identificator for sender node
     */
    function getIdent() constant returns (bytes32)
    { return rings.identOf[msg.sender]; }

    /**
     * @dev Return true when ready to run
     */
    function isAuthorized(uint _index) constant returns (bool)
    { return rings.isAuthorized(_index); }

    /**
     * @dev Initial setup for a new ring
     * @param _gates List of auth node addresses
     * @param _idents List of user identifiers
     */
    function initRing(address[] _gates, bytes32[] _idents) onlyOwner {
        var ring = rings.auth.length;
        rings.addRing(_gates[0], _idents[0]);
        for (uint i = 1; i < _gates.length; ++i)
            rings.addGate(ring, _gates[i], _idents[i]);
    }

    /**
     * @dev Proxy constructor
     * @param _auth Default auth node
     * @param _ident Default user identifier
     */
    function Proxy(address _auth, bytes32 _ident)
    { rings.addRing(_auth, _ident); }

    struct Call {
        address target;
        uint    value;
        bytes   transaction;
        uint    execBlock;
    }
    Call[] queue;

    /**
     * @dev Get call info by index
     * @param _index Action call index
     */
    function callAt(uint _index) constant returns (address, uint, bytes, uint) {
        var c = queue[_index];
        return (c.target, c.value, c.transaction, c.execBlock);
    }

    /**
     * @dev Get call queue length
     */
    function queueLen() constant returns (uint)
    { return queue.length; }

    /**
     * @dev Transaction request
     * @param _target Transaction destination
     * @param _value Transaction value in wei
     * @param _transaction Transaction data
     */
    function request(address _target, uint _value, bytes _transaction) onlyOwner {
        var rid = rings.newAction();
        rings.authorized[rid][msg.sender] = true;
        queue.push(Call(_target, _value, _transaction, 0));
        CallRequest(rid);
    }

    /**
     * @dev Call request log
     * @param index Position in call queue
     */
    event CallRequest(uint indexed index);

    /**
     * @dev Authorization of transaction
     * @param _index Call in queue position
     */
    function authorize(uint _index) {
        if (_index >= rings.authorized.length) throw;

        rings.authorized[_index][msg.sender] = true;
        CallAuthorized(_index, msg.sender);
    }

    /**
     * @dev Authorized call event
     * @param index Position in call queue
     * @param node Authorization node
     */
    event CallAuthorized(uint indexed index, address indexed node);

    /**
     * @dev Run action when authorized
     * @param _index Call in queue position
     * @notice This can take a lot of gas
     */
    function run(uint _index) onlyOwner {
        if (!rings.isAuthorized(_index)
          || queue[_index].execBlock != 0) throw;

        // Store exec block
        queue[_index].execBlock = block.number;

        // Run transaction
        var c = queue[_index];
        if (!c.target.call.value(c.value)(c.transaction)) throw;
        CallExecuted(_index, block.number);
    }

    /**
     * @dev Executed call event
     * @param index Position in call queue
     * @param block_number Number of call execution block
     */
    event CallExecuted(uint indexed index, uint indexed block_number);

    /**
     * @dev Destroy contract
     * @notice Contract should have empty balance before call it
     */
    function kill() onlyOwner {
        if (this.balance > 0) throw;
        super.kill();
    }

    /**
     * @dev Incoming payment event
     * @param from Payment sender
     * @param value Amount of received wei
     */
    event PaymentReceived(address indexed from, uint indexed value);

    /**
     * @dev Payable fallback method
     */
    function() payable {
        if (msg.value > 0)
            PaymentReceived(msg.sender, msg.value);
    }
}
