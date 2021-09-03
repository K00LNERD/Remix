pragma solidity ^0.8.5;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol';

contract MyToken is ERC20{
    uint256 private immutable cap = 1000000 * 10 ** 18;
    address public admin;
    constructor() ERC20('Phooti Cowrie', 'PCR') {
        _mint(msg.sender, 100000 * 10 ** 18);
        admin == msg.sender;
    }
    function mint(address to, uint amount) external {
        require(ERC20.totalSupply() + amount <= cap, "ERC20Capped: cap exceeded");
        require(msg.sender == admin, 'only admin');
        _mint(to, amount);
    } 
    function burn(uint amount) external {
        _burn(msg.sender, amount);
    }
    
}