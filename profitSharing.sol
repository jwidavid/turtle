pragma solidity ^0.4.16;

contract ProfitSharing {

    /**
     * Poll struct creats an class(?) for each member. Which will be stored
     * in an array for future processing
     */
    struct Poll {
        address [] accts; // user wallet address
        string purpose; // Two options Remove or Add (Future Case?)
        uint startDate; // Must be 10 days (864000) before payout otherwise immediately
        uint endDate; // Poll will close in 10 days (864000) of startDate
        uint vote;  // Default all are for until vote against
        bool status; // Check if the Poll is active or not
    }

    Poll public p;

    //event tracker for poll results
    event PollResults(string pollResultedIn);

    mapping(address => uint) balanceOf;
    // maps each index to the address stored there to allow for looping
    mapping(uint => address) accounts;

    uint public accTopIndex = 0; // Global: Counter of active accounts
    uint public constant originalTotal = 1000000; //
    uint public currentTotal = 950000; //
    uint public payPeriodsLeft = 6; //
    uint public previousPayoutTime; // Last Time Active Accounts Got Paid

    uint public tenDays = 864000; // Ten Days in seconds



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
        if (!(previousPayoutTime + 20 < block.timestamp)) {
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

    /**
     * This creates a Poll to add or remove a user.
     * Start time is based on the DIfference previousPayoutTime + 20 and the
     * block timestamp. If the difference is greater activate poll else
     * activate code on a later date. Once Created it will be in the array.
     */
    function createPoll(address[] _accts, string _purpose) public returns(uint) {
        if ((previousPayoutTime + 20) - block.timestamp >= tenDays){
            p.startDate = block.timestamp;
            p.endDate = block.timestamp + tenDays;
        } else{
            p.startDate = previousPayoutTime + 20;
            p.endDate = (previousPayoutTime + 20) + tenDays;
        }

        p.accts = _accts;
        p.purpose = _purpose;
        p.vote = 1;
        p.status = true;

        return p.vote;
    }

    /**
     * This is a simple return all address from the array.
     * TODO: More Detailed Return or More Getters
     */
    function getPoll() view public returns (bool){
        return p.status;
    }

    /**
     * This allows an active member to vote in the poll. Based on the
     * date and status of the bool. If it is active and the choice (TorF). Which
     * will incrament the counter. Once that is done it will check if the poll
     * will need to still be active or not.
     * TODO: Only Active Members?
     */
     // change to bol
    function vote(bool voteType) public returns (bool) {

        if(p.status != true || block.timestamp < p.startDate){
            return false;
        }

        if (voteType){
            p.vote += 1;
        } else {
            p.vote -= 1;
        }

        p.status = checkPoll();

        return true;
    }

    /**
     * checkPoll will see if a poll should be active or not. This depends on the
     * date and votes. If the votes are greater than 50% the account will be
     * removed or added depending on the purpose. Then the poll will be closed.
     */
    function checkPoll() returns(bool){
        // If All active members have voted or date is exceeded
        if (p.vote == accTopIndex || p.endDate >= block.timestamp){
            //If Approve Vote is Above 50% it is approved
          if (p.vote >= 0){
              // Solidy Way for String Compare (T/F instead?) add/remove acct
              if (keccak256(p.purpose) == keccak256("add")){
                  addAccounts(p.accts);
                  PollResults("add");
                  return false;
              } else {
                  // needs to be an arry to remove
                  removeAccount(p.accts[0]);
                  PollResults("rmv");
                  return false;
              }
            }
        }

        return true;
    }
}
