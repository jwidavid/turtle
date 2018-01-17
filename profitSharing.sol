pragma solidity ^0.4.16;

contract ProfitSharing {
    
    //Poll strut to add or rmv acct
    struct Poll {
        address acct; // acct of usr to rmv or add
        string purpose; // Remove or Add
        uint startDate; // Must be 10 days (864000) before payout
        uint endDate; // length (864000) set initial
        uint yayCount; // keeps track of yay votes
        uint nayCount; // keeps track of nay votes
        bool status; // is the pool still active
    }
    
    mapping (address => Poll) polls;  // Mapped New Eth address to Poll conducted
    address[] public createdPolls;  // Stores all new accounts as poll addrs
    uint public tenDays = 864000; // this is just a global for 10 days

    
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
    
    // Create a Poll for a user  
    function setPoll(address _address, string _purpose) public {
        
        var poll = polls[_address];

        // Idea: DIfference between LastPP and current is greater than ten days 
        // it will give the start time to now else after the lastPP
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
    //TODO: Audit of who voted?
    function vote(bool choice, address _acct) public returns (bool) {
        var selectPoll = polls[_acct];

        // Is for Active?
        if(!selectPoll.status){
            return false;
        }
        
        // Vote
        if (choice){
            selectPoll.yayCount += 1;
        } else {
            selectPoll.nayCount += 1;
        }
        
        // Check if voting is done now
        checkPoll(_acct);
  
    }
    
    // check if Poll Is Active 
    function checkPoll(address _acct) public returns(bool){
        var selectPoll = polls[_acct];
        // If poll has all active members proceed
        if ((selectPoll.nayCount + selectPoll.yayCount) >= accTopIndex){
            //If All Active members voted yay to preform action >= 50% do it
          if ((selectPoll.yayCount/accTopIndex) * 100 >= 50){
              // add usr
              if (keccak256(selectPoll.purpose) == keccak256("add")){
                  balanceOf[_acct] = 1;
                  accTopIndex++;
                  selectPoll.status = false;
              } else {
                  // rmv usr
                  balanceOf[_acct] = 0;
                  accTopIndex--;
                  selectPoll.status = false;
              }
            }
        }
        return false;
    }


}