contract Token  {
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 decimalFactor;
    uint256 public maxValue = 10000000000000000;
    uint256 public totalSupply;
    bool mintAllowed = true;
    
    address public adminAddress = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
    
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isBlacklisted;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Burn(address indexed _from, uint256 _value);
    
    constructor(string memory _name, string memory _symbol, uint256 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        decimalFactor = 10 ** decimals;
        maxValue = maxValue * decimalFactor;
        mint(owner, 10000 * decimalFactor);
    }
    
    
    // Used to mint or create new tokens on to the contract
    function mint(address _to, uint256 _value) public returns (bool success) {
        require(maxValue >= (totalSupply + _value), "Value cannot be greater than Max Value");
        require(mintAllowed, "Minting needs to be allowed");
        
        if(maxValue == (totalSupply + _value)) {
            mintAllowed = false;
        }
        
        totalSupply += _value;
        balanceOf[_to] += _value;
        
        require(balanceOf[_to] >= _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }
    
    
    // Transfer tokens from one account to other
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success){
        require(balanceOf[_from] >= _value, "User doesn't have balance");
        require(_to != address(0), "Recipient address cannot be zero");
        require(balanceOf[_to] + _value >= balanceOf[_to], "Value cannot be negative");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(_from, _to, _value);
        return true;
    }

    
    // Transfer tokens from one account, on behalf of the main address to another address
    // using allowance
    function transferFrom(address _from, address _to, uint256 _value) public blacklistCheck(_from, _to) returns (bool success) {
       require(_value <= allowance[_from][msg.sender], "Allowance Error");
       allowance[_from][msg.sender] -= _value;
       
       uint256 _amount = sendTokens(_value, _from);
        _transfer(_from, _to, _amount);
        return true;
    }
    
    
    // Used when the main address is the msg.sender and wants to send tokens
    function transfer(address _recipient, uint256 _value) public blacklistCheck(msg.sender, _recipient) {
        uint256 _amount = sendTokens(_value, msg.sender);
        _transfer(msg.sender, _recipient, _amount);
    }
    
    
    // Deployer approves an address to spend tokens
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }
    
    
    // Used to burn the tokens and reduce the total supply and max token in the contract
    function burn(uint256 _value) public onlyOwner returns (bool success) {
        require(_value <= balanceOf[msg.sender], "Value is greater than the supply left");
        balanceOf[msg.sender] -= _value;
        maxValue -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        
        return true;
    }
}    
