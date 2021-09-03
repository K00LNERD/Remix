pragma solidity ^0.6.0;

contract MyContract {
    //State Variables
    string public myString = "Hello World";
    uint public myUint = 1 ; // by default uint is uint256;
    int public myInt = 1 ; // int with sign 
    uint256 public myUint256 = 1; //big uint 
    uint8 public myUint8 =8; //small uint
    address public myAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 ; // no quotation or anything
    
    struct MyStruct {
        uint myInt;
        string myString;
        
    }
    
    MyStruct public mystruct = MyStruct(1,"Hello World");
    //local Variables
    function getValue() public pure returns(uint){
        uint value = 1;
        return value;
    }
}