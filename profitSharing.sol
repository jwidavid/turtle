pragma solidity ^0.4.16;

contract ProfitSharing {
    
    /**
     * Poll struct creats an class(?) for each member. Which will be stored
     * in an array for future processing
     */
    struct Poll {
        address acct; // user wallet address
        string purpose; // Two options Remove or Add (Future Case?)
        uint startDate; // Must be 10 days (864000) before payout otherwise immediately
        uint endDate; // Poll will close in 10 days (864000) of startDate
        uint yayCount; // Counter for approved votes (True)
        uint nayCount; // Counter for disapproved votes (False)
        bool status; // Check if the Poll is active or not
    }
    
    mapping (address => Poll) polls;  // Maps new Eth address to Poll
    mapping(address => uint) balanceOf;
    mapping(uint => address) accounts;
    
    address[] public createdPolls;  // Stores Poll Created in Array

    uint public accTopIndex = 0; // Global: Counter of active accounts (ISSUE)
    uint public constant originalTotal = 1000000; //
    uint public currentTotal = 950000; //
    uint public payPeriodsLeft = 6; //
    uint public previousPayoutTime; // Last Time Active Accounts Got Paid
    uint public tenDays = 864000; // Ten Days in seconds



    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     * (Struct vs Double Mapping approach to walking the array)
     * 638070 vs 541572 (1 address arg)
     * 641148 vs 543630 (2 address arg)
     * 675233 vs 571090 (3 address arg)
     * 709938 vs 573148 (4 address arg)
     * assignPortion 64699  vs 65339 (1 address arg)
     * assignPortion 116323 vs 76471 (4 address arg)
     */
    function ProfitSharing(address[] addresses_) public payable {
        balanceOf[msg.sender] = 50000;
        addAccounts(addresses_);
        previousPayoutTime = block.timestamp;
    }

    /**
     * Add New Account to Group. First by Checking if the account already exist. 
     * If it hasn't then you'll create a poll so that all parties can vote to
     * either approve or deny new account entry
     */
    function addAccounts(address[] addresses_) public {
        uint x = addresses_.length + accTopIndex;
        uint n = 0;
        for (uint i=accTopIndex;i<x;i++) {
            // Verifying New Account Hasn't Been Added Already
            if (balanceOf[addresses_[n]] < 1) {
                // Creating a Poll for new account
                setPoll(addresses_[n], "add");
            }
            n++;
        }
    }

    /* Return True if it's time for another PayDay! */
    function isPayDay() public constant returns(bool) {
        // Only pays out every two weeks (1209600 seconds)
        if (previousPayoutTime + 20 < block.timestamp) {
            return true;
        }
        return false;
    }

    function getBalance() public constant returns(uint) {
        return balanceOf[msg.sender];
    }

    function getPortionAmount() private constant returns(uint) {
        return (currentTotal / (accTopIndex + 1)) / payPeriodsLeft;
    }

    function assignPortion() public {
        if (isPayDay()) {
            uint portion = getPortionAmount();
            for (uint i=0;i<accTopIndex+1;i++) {
                balanceOf[accounts[i]] += portion;
                currentTotal -= portion;
            }
            payPeriodsLeft--;
        }
    }
    
    /**
     * This creates a Poll for a user new(add) or old(remove). 
     * Start time is based on the DIfference previousPayoutTime + 20 and the
     * block timestamp. If the difference is greater activate poll else
     * activate code on a later date. Once Created it will be in the array.
     */
    function setPoll(address _address, string _purpose) public {
        var poll = polls[_address];

        if ((previousPayoutTime + 20) - block.timestamp >= tenDays){
            poll.startDate = block.timestamp;
            poll.endDate = block.timestamp + tenDays;
        } else{
            poll.startDate = previousPayoutTime + 20;
            poll.endDate = (previousPayoutTime + 20) + tenDays;
        }
    
        poll.acct = _address;
        poll.purpose = _purpose;
        poll.yayCount = 0;
        poll.nayCount = 0;
        poll.status = true;
    
        createdPolls.push(_address) - 1;
        
    }

    /**
     * This is a simple return all address from the array.
     * TODO: More Detailed Return or More Getters
     */
    function getPoll() view public returns (address[]){
        return createdPolls;
    }
    
    /**
     * This allows an active member (TODO) to vote in the poll. Based on the 
     * date and status of the bool. If it is active and the choice (TorF). Which
     * will incrament the counter. Once that is done it will check if the poll 
     * will need to still be active or not.
     * TODO: Audit of Who Voted to prevent revoting and just tracking
     * TODO: Only Active Members\
     */
    function vote(bool choice, address _acct) public returns (bool) {
        var selectPoll = polls[_acct];

        if(!selectPoll.status && block.timestamp < selectPoll.startDate){
            return false;
        }
        
        if (choice){
            selectPoll.yayCount += 1;
        } else {
            selectPoll.nayCount += 1;
        }
        
        checkPoll(_acct);
    }
    
    /**
     * checkPoll will see if a poll should be active or not. This depends on the 
     * date and votes. If the votes are greater than 50% the account will be
     * removed or added depending on the purpose. Then the poll will be closed. 
     * TODO: remove poll?
     * TODO: duplicate account what would happen?
     * TODO: Assume no vote is a no?
     */
    function checkPoll(address _acct) public returns(bool){
        var selectPoll = polls[_acct];
        // If All active members have voted or date is exceeded
        if ((selectPoll.nayCount + selectPoll.yayCount) >= accTopIndex || 
                selectPoll.endDate >= block.timestamp){
            //If Approve Vote is Above 50% it is approved
          if ((selectPoll.yayCount/accTopIndex) * 100 > 50){
              // Solidy Way for String Compare (T/F instead?) add/remove acct
              if (keccak256(selectPoll.purpose) == keccak256("add")){
                  balanceOf[_acct] = 1;
                  accTopIndex++;
                  selectPoll.status = false;
              } else {
                  balanceOf[_acct] = 0;
                  accTopIndex--;
                  selectPoll.status = false;
              }
            }
        }
        return false;
    }
}