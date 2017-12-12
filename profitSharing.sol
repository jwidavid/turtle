pragma solidity ^0.4.16;

contract ProfitSharing {

    mapping(address => uint) balanceOf;
    mapping(uint => address) accounts;

    uint public accTopIndex = 0;
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
}


contract voting{
	//Our code goes here
	
    mapping(address => uint) voted;
    address[] addressesForVotingOn;
    uint votes = 0;
    uint createdTime = block.timestamp;
	
	
	function Voting(address[] addresses_) internal {
	    addressesForVotingOn = addresses_;
	}
	
	
	function vote(bool aVote_) internal {
	    if (aVote_) {
	        votes++;
	    }
	    else {
	        votes--;
	    }
	}
	
	
	function getResult() internal returns(bool) {
	    if (votes >= 0) {
	        return true;
	    }
	    return false;
	}
}
