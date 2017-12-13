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
        continueTransaction = false;
        if (blockLimit > remainingGas) {
            continueTransaction = false;
        }
        else {
            continueTransaction = true;
        }
        return continueTransaction;
    }
}