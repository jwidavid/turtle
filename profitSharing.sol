pragma solidity ^0.4.16;

contract ProfitSharing {

    struct accountStruct {
        address accountAddress;
        uint balance;
    }

    // maps each index to an account struct containing its address & balance
    mapping(uint256 => accountStruct) accounts;

    uint public accTopIndex = 0;
    uint public constant originalTotal = 1000000;
    uint public currentTotal = 950000;
    uint public payPeriodsLeft = 6;
    uint public previousPayoutTime;


    /* Constructor function
     *
     * Initializes contract with initial supply tokens to the contract creator
     * (Struct vs Double Mapping approach [Wei usage] to walking the array)
     *
     * 638070 vs 541572 (1 address arg)
     * 641148 vs 543630 (2 address arg)
     * 675233 vs 571090 (3 address arg)
     * 709938 vs 573148 (4 address arg)
     * assignPortion 64699  vs 65339 (1 address arg)
     * assignPortion 116323 vs 76471 (4 address arg)
     */
    function ProfitSharing(address[] addresses_) public payable {
        accounts[0] = 
            accountStruct({
                accountAddress: msg.sender,
                balance: 50000
            });
        /* (INSERT STATE CHANGE EVENT...) */

        accTopIndex++;
        /* (INSERT STATE CHANGE EVENT...) */

        addAccounts(addresses_);
        previousPayoutTime = block.timestamp;
        /* (INSERT STATE CHANGE EVENT...) */

    }


    /* addAccounts(address[]):
     *
     * Converts addresses passed in from a list to accountStruct objects 
     * & adds them to the accounts mapping.
     */
    function addAccounts(address[] addresses_) public {
        for (uint i = 0; i < addresses_.length; i++) {
            uint accountIndex = getAccountIndexByAddress(addresses_[i]);
            // check if the address hasn't been added yet
            if (accountIndex == uint(-1)) {
                accounts[i+1] = 
                    accountStruct({
                        accountAddress: addresses_[i],
                        balance: 0
                    });
                /* (INSERT STATE CHANGE EVENT...) */

                accTopIndex++;
                /* (INSERT STATE CHANGE EVENT...) */

            }
        }
    }


    /* assignPortion():
     *
     * Uses the getPortionAmount() function to determine the payout for the 
     * current pay period, then properly adds the portion to each account 
     * balance in the balanceOf mapping.
     */
    function assignPortion() public {
        if (isPayDay()) {
            uint portion = getPortionAmount();
            for (uint i = 0; i < accTopIndex + 1; i++) {
                accounts[i].balance += portion;
                /* (INSERT STATE CHANGE EVENT...) */

                currentTotal -= portion;
                /* (INSERT STATE CHANGE EVENT...) */

            }
            payPeriodsLeft--;
            /* (INSERT STATE CHANGE EVENT...) */

        }
    }


    /* getAccountIndexByAddress(address):
     *
     * Returns the index of the specified address in the accounts mapping.
     */
    function getAccountIndexByAddress(address someAddress) 
    public constant returns(uint) {
        for (uint i = 0; i < accTopIndex; i++) {
            if (accounts[i].accountAddress == someAddress) {
                return i;
            }
        }
        return uint(-1);
    }


    /* getBalance():
     *
     * Returns the current balance of the address that called the contract.
     */
    function getBalance() public constant returns(uint) {
        uint accountIndex = getAccountIndexByAddress(msg.sender);
        if (accountIndex != uint(-1)) {
            return accounts[accountIndex].balance;
        }
        return 0;
    }


    /* getPortionAmount():
     *
     * Obtains the payout amount to be given to each employee for the current
     * pay period.
     */
    function getPortionAmount() public constant returns(uint) {
        return (currentTotal / (accTopIndex + 1)) / payPeriodsLeft;
    }


    /* isPayDay():
     *
     * Return true if it's time for another PayDay!
     */
    function isPayDay() public constant returns(bool) {
        // Only pays out every two weeks (1209600 seconds)
        if (previousPayoutTime + 20 < block.timestamp) {
            return true;
        }
        return false;
    }


    /*
    modifier isPayDayMod - to be tested against isPayDay for gas costs
    */


///////////////////////////////////////////////////////////////////////////////
/////////////////////////////Newly added Functions/////////////////////////////
///////////////////////////////////////////////////////////////////////////////

    /* removeAccount(address): 
     *
     * Completely removes an address from the company by deleting it's 
     * information from both the accounts & balanceOf mappings
     */
    function removeAccount(address toRemove) public returns(bool) {
        // checks if acct was removed yet in loop
        bool acctRemoved = false;
        for (uint i = 0; i <= accTopIndex; i++) {
            // check if given address is contained at current index
            if (accounts[i].accountAddress == toRemove) {
                // leave address in for now & note that it will be overwritten
                acctRemoved = true;
            // check if given address has been removed yet
            } else if (acctRemoved) {
                // if so, bump all following indices back one spot
                accounts[i-1] = accounts[i];
                /* (INSERT STATE CHANGE EVENT...) */

            // check if something has been removed & you are at last element
            } else if (acctRemoved && i == accTopIndex) {
                // remove the last item in accounts once all are bumped up
                delete(accounts[i]);
                /* (INSERT STATE CHANGE EVENT...) */

            }
        }
        // decrement accTopIndex to account for change
        accTopIndex--;
        /* (INSERT STATE CHANGE EVENT...) */

    }

    /* Test address list:
    ["0x14723a09acff6d2a60dcdf7aa4aff308fddc160c",
     "0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db",
     "0x583031d1113ad414f02576bd6afabfb302140225",
     "0xdd870fa1b7c4700f2bd7f44238821c26f7392148"]
     */

}
