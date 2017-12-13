pragma solidity ^0.4.16;

library calculateGas {
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