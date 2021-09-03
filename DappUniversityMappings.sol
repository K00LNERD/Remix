pragma solidity ^0.6.0;

contract MyContract {
    //Mappings
    mapping(uint => string) public names;
    mapping(uint => Book) public books;
    mapping(address => mapping(uint => Book)) public myBooks;
    
    struct Book {
        string title;
        string Author;
    }
    
    constructor() public {
        names[1] = "srijan";
        names[2] = "sahil";
        names[3] = "Samridhi";
    }
    function addBooks(uint _id, string memory _title, string memory _author) public {
        books[_id] = Book(_title,_author);
    }
    function addMyBooks(uint _id, string memory _title, string memory )
    
}