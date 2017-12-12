pragma solidity ^0.4.16;

library calculateGas {
    function gasCalculation() public returns (bool continueTransaction) {
        /* both of these variables change with state change */
        uint remainingGas = msg.gas; /* msg.gas is a globally available variable
                                        that provides the uint for the remaining
                                        gas in the contract */
        uint costOfTransaction = tx.gasprice; /* tx.gas is a globally available
                                                 variable that provides the uint
                                                 for the cost of a given
                                                 transaction */
        continueTransaction = false;
        if (costOfTransaction > remainingGas) {
            continueTransaction = false;
        }
        else {
            continueTransaction = true;
        }
        return continueTransaction;
    }
}