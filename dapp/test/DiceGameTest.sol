pragma solidity ^0.5.0;

import "../contracts/DiceGame.sol";

contract DiceGameTest {

	function testSend() public {
    	
    	DiceGame diceGameContract = DiceGame(DeployedAddresses.DiceGame());
    	assert.equal(diceGameContract.isBetSet(), false);

  	}

}