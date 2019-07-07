pragma solidity ^0.4.18;

contract HelloWorld {
  string message;

  constructor() public{
    message = "123";
  }

  function setMessage(string myMessage) public{
    message = myMessage;
  }

  function getMessage() public view returns(string) {
    return message;
  }

  function say() public view returns (string) {
         return "Hello World!";
     }
}
