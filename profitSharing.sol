pragma solidity ^0.4.16;

contract ProfitSharing {

    struct accountStruct {
        address accountAddress;
        uint balance;
    }

    mapping(uint256 => accountStruct) accounts;

    uint public accTopIndex = 0;
    uint public constant originalTotal = 1000000;
    uint public currentTotal = 950000;
    uint public payPeriodsLeft = 6;
    uint public previousPayoutTime;


    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     *
     * (with 1 address as argument)
     * 638070 1 address (every additional address costs about 32,000 wei)
     * 641148 2 address
     * 675233 3 address
     * 709938 4 address
     * 64699 assignPortion
     */
    function ProfitSharing(address[] addresses_) public payable {
        accounts[0] = accountStruct({accountAddress:msg.sender, balance:50000});
        addAccounts(addresses_);
        previousPayoutTime = block.timestamp;
    }


    function addAccounts(address[] addresses_) public {
        uint x = addresses_.length + accTopIndex;
        for (uint i=accTopIndex;i<x;i++) {
            uint n = (i-accTopIndex);
            uint accountIndex = getAccountIndexByAddress(addresses_[n]);
            if (accountIndex == uint(-1)) {
                accounts[i+1] = accountStruct({accountAddress:addresses_[n], balance:0});
                accTopIndex++;
            }
        }
    }


    function getAccountIndexByAddress(address someAddress) private constant returns(uint) {
        for (uint i=0;i<accTopIndex+1;i++) {
            if (accounts[i].accountAddress == someAddress) {
                return i;
            }
        }
        return uint(-1);
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
        uint accountIndex = getAccountIndexByAddress(msg.sender);
        if (accountIndex != uint(-1)) {
            return accounts[accountIndex].balance;
        }
        return 0;
    }


    function getPortionAmount() private constant returns(uint) {
        return (currentTotal / (accTopIndex + 1)) / payPeriodsLeft;
    }


    function assignPortion() public {
        if (isPayDay()) {
            uint portion = getPortionAmount();
            for (uint i=0;i<accTopIndex+1;i++) {
                accounts[i].balance += portion;
                currentTotal -= portion;
            }
            payPeriodsLeft--;
        }
    }
}
