pragma solidity ^0.4.16;

contract ProfitSharing {

    // maps each address to it's current balance
    mapping(address => uint) balanceOf;
    // maps each index to the address stored there to allow for looping
    mapping(uint => address) accounts;

    uint public accTopIndex = 0;
    uint public constant originalTotal = 1000000;
    uint public currentTotal = 950000;
    uint public payPeriodsLeft = 6;
    uint public previousPayoutTime;


    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the contract creator
     * (Struct vs Double Mapping approach [Wei usage] to walking the array)
     */
    function ProfitSharing(address[] addresses_) public payable {
        balanceOf[msg.sender] = 50000;
        accounts[0] = msg.sender;
        addAccounts(addresses_);
        previousPayoutTime = block.timestamp;
    }


    /**
     * Adds a list of addresses to the balanceOf & accounts mappings
     */
    function addAccounts(address[] addresses_) public {
        for (uint i = 0; i < addresses_.length; i++) {
            // Verify that this address hasn't already been added
            if (balanceOf[addresses_[i]] < 1) {
                accTopIndex++;
                balanceOf[addresses_[i]] = 1;
                accounts[accTopIndex] = addresses_[i];
                /* (INSERT STATE CHANGE EVENT...) */
            }
        }
    }


    /**
     * Uses the getPortionAmount() function to determine the payout for the 
     * current pay period, then properly adds the portion to each account 
     * balance in the balanceOf mapping.
     */
    function assignPortion() isPayDayMod public {
        uint portion = getPortionAmount();
        for (uint i = 0; i <= accTopIndex; i++) {
            balanceOf[accounts[i]] += portion;
            /* (INSERT STATE CHANGE EVENT...) */

        }
        currentTotal -= (portion * (accTopIndex + 1) );
        payPeriodsLeft--;
    }
    
    
    /**
     * Returns the current balance of the address that called the contract.
     */
    function getBalance() public constant returns(uint) {
        return balanceOf[msg.sender];
    }


    /**
     * Obtains the payout amount to be given to each employee for the current
     * pay period.
     */
    function getPortionAmount() public constant returns(uint) {
        return (currentTotal / (accTopIndex + 1) ) / payPeriodsLeft;
    }


    /**
     * Fails if it is not payday
     */
    modifier isPayDayMod() {
        if (!(previousPayoutTime + 20 < block.timestamp) && gasCalculation()) {
            revert();
        }
        _;
    }


    /**
     * Completely removes an address from the company by deleting it's 
     * information from both the accounts & balanceOf mappings
     */
    function removeAccount(address toRemove) public {
        bool deleted = false;
        for (uint i=0; i<=accTopIndex; i++) {
            // check if given address is contained at current index
            if (accounts[i] == toRemove) {
                delete(accounts[i]);
                delete(balanceOf[toRemove]);
                deleted = true;
            }
            else if (deleted) {
                accounts[i-1] = accounts[i];
            }
        }
        if (deleted) {
            delete(accounts[accTopIndex]);
            accTopIndex--;
            /* (INSERT STATE CHANGE EVENT...) */
        }
    }
    
    function gasCalculation() public returns (bool continueTransaction) {
        /* both of these variables change with state change */
        uint remainingGas = msg.gas; /* msg.gas is a globally available variable
                                        that provides the uint for the remaining
                                        gas in the contract */
        uint blockLimit = block.gaslimit; /* block.gaslimit is a globally available
                                        	variable  that provides the gas limit of
                                        	the block that the transaction is
                                        	currently is */
        if (blockLimit > remainingGas) {
        /* If the block limit that the transaction is occurring in is greater than the
           gas remaining in the contract. This returns a false to tell the loop that
           it cannot continue without getting locked up because there is not enough
           gas to continue. */    
            continueTransaction = false;
        }
        else {
            continueTransaction = true;
        }
        return continueTransaction;
    }
}