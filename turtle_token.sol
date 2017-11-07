pragma solidity ^0.4.17;

contract TurtleToken {
    
    /* Array w/ balances of every address */
    mapping(address => uint256) balances;
    
    /* Size of balance mapping */
    uint256 numBalances = 0;
    
    /*  Owner gives permission to spender to spend a specified 
        amount of BubbleCoin. The value located at 
        approved[owner][spender] is the amount that spender is allowed
        to spend. */
    mapping(address => mapping(address => uint)) approved;

    /* Notify user when a transfer has occurred */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /* Notify user when allowance request is approved */
    event Approval(address indexed _owner, 
                   address indexed _spender, uint256 _value);
    
    /* total supply of tokens */
    uint supply;
    
    /* Publically displayed name (Turtle Token) & symbol (TT) */
    bytes32 public constant name = "BubbleCoin";
    bytes32 public constant symbol = "BUBL";

    /* Amount of decimal places associated with  */
    uint public constant decimals = 18;
    
    /* Number of payout periods remaining in contract (24 in total) */
    uint payoutsLeft = 24;
    
///////////////////////////////////////////////////////////////////////////////
///////////////////////// ERC20 Required Functions ////////////////////////////
///////////////////////////////////////////////////////////////////////////////

    /* Returns the total supply of BubbleCoins in circulation */
    function totalSupply() 
    external constant returns (uint totSupply) {
        return supply;
    }

    /* Returns the BubbleCoin balance of specified address */
    function balanceOf(address _owner) 
    external constant returns (uint chkBalance) {
        return balances[_owner];
    }

    /*  Transfers specified amount of BubbleCoin (_value) from 
        address that is calling the contract to a specified 
        address (_to) */
    function transfer(address _to, uint256 _value) 
    external returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            return true;
        } else {
            // failed transaction
            return false;
        }
    }

    /*  Transfers specified amount of BubbleCoin (_value) from one 
        address (_from) to another (_to) */
    function transferFrom(address _from, address _to, uint256 _value)             
    external returns (bool success) {
        if (balances[_from] >= _value &&
           approved[_from][msg.sender] >= _value &&
           _value > 0) {
                
            balances[_from] -= _value;
            approved[_from][msg.sender] -= _value;
            balances[_to] += _value;
            
            return true;
        } else {
            // failed transaction
            return false;
        }
    }

    /* Allows the _spender address to take money out of the msg.sender's
       account up until the specified _value amount */
    function approve(address _spender, uint256 _value) 
    external returns (bool success) {
        if (balances[msg.sender] >= _value) {
            approved[msg.sender][_spender] = _value;
            return true;    
        }
        return false;
    }

    /* Returns the current allowance given to one account */
    function allowance(address _owner, address _spender) 
    external constant returns (uint remaining) {
        return approved[_owner][_spender];
    }

///////////////////////////////////////////////////////////////////////////////
///////////////////////////// Personal Functions //////////////////////////////
///////////////////////////////////////////////////////////////////////////////
    
    /*  Mints new BubbleCoins & adds them to the creator's address
        as well as the total supply in circulation */
    function mint(uint256 numberOfCoins) 
    external {
        balances[msg.sender] += numberOfCoins;
        supply += numberOfCoins;
    }
    
    /* Returns the balance of the address that is calling the contract */
    function getMyBalance() 
    external constant returns (uint256 yourBalance) {
        return balances[msg.sender];
    }
    
/*  Formula for determining token payout per paycheck:
    
    # current employees (balances.length equivalent) *
    # payouts remaining in year (payoutsLeft) * 
    # coins paid out per employee this period, rounded down (payoutAmt)
    --------------------------------
    # coins remaining in pool (balances[msg.sender])

    **After each pay period: 
    
    updated # coins remaining = 
        # coins remaining - (# employees * # coins/employee paid)
        
*/

}
