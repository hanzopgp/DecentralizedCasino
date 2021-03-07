pragma solidity ^0.5.0;

contract HelloWorld {

    string public sentence;

    constructor() public {
        sentence = "HelloWorld !";
    }

    function saySomething() public view returns(string memory){
        return (sentence);
    }
}
