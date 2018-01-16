pragma solidity ^0.4.16;

contract ProfitSharing {
    
    //Poll strut to add or rmv acct
    struct Poll {
        string acct; // acct of usr to rmv or add
        string purpose; // Remove or Add
        string options; // this is going to be yes or no mostly for event
        uint votelimit; //max number should be total number of members
        uint deadline; // Vote Deadline (ex. 24hrs)
        bool status; // If Vote is active or not
        uint numVotes; // num of votes submited
    }
    
    mapping (address => Poll) polls;  // Mapped New Eth address to Poll conducted
    address[] public createdPolls;  // Stores all new accounts as poll addrs
   
    // event tracking of all votes
    event NewVote(string votechoice);
    
    mapping(address => uint) balanceOf;
    mapping(uint => address) accounts;

    uint public accTopIndex = 0; //keeps track of accts added (count)
    uint public constant originalTotal = 1000000;
    uint public currentTotal = 950000;
    uint public payPeriodsLeft = 6;
    uint public previousPayoutTime;



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

    //Question from Eddy: why  x = , n=, and i? lots of memory used cost? why not 
    // (for (uint i=0; i < (addresses_.length + accTopIndex(or 'x' possible computatial cost doing addtion); i++)
    // Go Through array of address if address is not found then call for Voting
    // else break
    function addAccounts(address[] addresses_) public {
        uint x = addresses_.length + accTopIndex;
        uint n = 0;
        for (uint i=accTopIndex;i<x;i++) {
            // Verify that this address hasn't already been added
            if (balanceOf[addresses_[n]] < 1) {
                balanceOf[addresses_[n]] = 1;
                accTopIndex++;
            }
            n++;
        }
        //Voting
        //TODO: Add Voting so they are in the queue
        //Timer to add or remove  +- of days of payout day
        
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
    
    // Create a Poll for a user  
    function setPoll(address _address, string _purpose, string _acct, uint _votelimit, 
                     string _options, uint _deadline) public {
                         
        var poll = polls[_address];
        
        // poll details
        poll.acct = _acct;
        poll.purpose = _purpose;
        poll.votelimit = _votelimit;
        poll.options = _options;
        poll.deadline = _deadline;
        poll.status = true;
        poll.numVotes = 0;
        
        // Adding Poll Addrs to newAcctPolls array
        createdPolls.push(_address) - 1;
        
    }

    // Get All Poll 
    // (TODO: Need to Orginize data maybe seperate between 
    //   approved, not, ative, inactive, ect.)
    function getPoll() view public returns (address[]){
        return createdPolls;
    }
    
    // get address of poll and then set vote option
    function vote(string choice, address _acct) public returns (bool) {
        var selectPoll = polls[_acct];
        if (selectPoll.status != true) {
            return false;
        }
        
        selectPoll.numVotes += 1;
        NewVote(choice);
        
        //if limit or date have been reached, end poll
        //TODO: Not just close but preform action to add or remove depending on majority 51%
        if(selectPoll.votelimit > 0){
            if(selectPoll.numVotes >= selectPoll.votelimit){
                selectPoll.status = false;
            }
        }
    }
    
    // Need a way to check if vote has based based on # votes or length of vote
    


}