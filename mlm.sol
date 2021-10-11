// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MLM{
    address payable admin;
    mapping (address  => address payable ) registrar ;
    mapping (address => bool) registerd;
    
    constructor( ){
        admin = payable(msg.sender);
        registerd[admin] =  true;
    }
    function register(address payable _to) public{
         require(registerd[msg.sender], 'register yourself first');
        registrar[_to]= payable(msg.sender);
        registerd[_to] = true;
    }
    
    function send() public payable{
        
        require(msg.sender.balance >= msg.value, "insufficent balance");
        require(registerd[msg.sender], 'register yourself first');
        if (registrar[msg.sender] != address(0)){
        registrar[msg.sender].transfer(msg.value/10);
        }
        if (registrar[registrar[msg.sender]] != address(0)){
        registrar[registrar[msg.sender]].transfer(msg.value/20);
        }
        if (registrar[registrar[registrar[msg.sender]]] != address(0)){
        registrar[registrar[registrar[msg.sender]]].transfer(msg.value*3/100);
        }
        if (registrar[registrar[registrar[registrar[msg.sender]]]] != address(0)){
        registrar[registrar[registrar[registrar[msg.sender]]]].transfer(msg.value/50);
        }
        if (registrar[registrar[registrar[registrar[registrar[msg.sender]]]]] != address(0)){
        registrar[registrar[registrar[registrar[registrar[msg.sender]]]]].transfer(msg.value/100);
        }
        
    }
    
}
