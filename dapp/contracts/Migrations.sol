pragma solidity ^0.5.0;

contract Migrations {
  address public owner;
  uint public lastMigration;

  modifier restricted() {
    require(msg.sender == owner); 
    _;
  }

  constructor() public {
    owner = msg.sender;
  }

  function setCompleted(uint completed) public restricted {
    lastMigration = completed;
  }

  function upgrade(address newAddress) public restricted {
    Migrations upgraded = Migrations(newAddress);
    upgraded.setCompleted(lastMigration);
  }
}