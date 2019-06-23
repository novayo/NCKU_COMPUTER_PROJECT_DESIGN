pragma solidity ^0.4.18;

contract HelloWorld {
  string message;

  function HelloWorld() public{
    message = "123";
  }

  function setMessage(string myMessage) public{
    message = myMessage;
  }

  function getMessage() constant public returns(string) {
    return message;
  }

  function say() constant public returns (string) {
         return "Hello World!";
     }
}
