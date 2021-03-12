pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Game.sol";
import "./Utility.sol";

contract Dice is Game, Utility{ //Ownable allows use onlyOwner modifier so we can make admin functions



	using SafeMath for uint256; //Using SafeMath lib to avoid overflow erros



	//Variables
	struct Bet{
		bool isSet; 
		uint moneyBet;
		uint diceBet;
		uint diceResult;
	}
	mapping(address => Bet) private betsMap;
	uint diceBetMultiplier = 10;



	//Dice game functions
	function isBetSet() public view returns(bool){
		return betsMap[msg.sender].isSet;
	}
	function bet(string memory empty, uint playerBet) public payable isEnoughMoney currentBetIsNotSet(betsMap[msg.sender].isSet) returns(uint, bool, uint){
		require(playerBet >= 2, "Bet must be between 2 and 12");
		require(playerBet <= 12, "Bet must be between 2 and 12");
		empty = "";
		betsMap[msg.sender].isSet = true;
		betsMap[msg.sender].diceBet = playerBet;
		betsMap[msg.sender].moneyBet = msg.value;
		return (betsMap[msg.sender].diceBet, betsMap[msg.sender].isSet, betsMap[msg.sender].moneyBet);
	}
	function cancelBet() external currentBetIsSet(betsMap[msg.sender].isSet) returns(bool){
		betsMap[msg.sender].diceBet = 0;
		betsMap[msg.sender].isSet = false;
		betsMap[msg.sender].diceResult = 0;
		msg.sender.transfer(betsMap[msg.sender].moneyBet);
		betsMap[msg.sender].moneyBet = 0;
		return true;
	}
	function play() public currentBetIsSet(betsMap[msg.sender].isSet) returns(uint , uint){																
		betsMap[msg.sender].diceResult = randomDoubleDice();															
		betsMap[msg.sender].isSet = false;
		if(betsMap[msg.sender].diceResult == betsMap[msg.sender].diceBet){	
			this.playerReceivesMoney();
		}
		return (betsMap[msg.sender].diceBet , betsMap[msg.sender].diceResult);
	}
    function playerReceivesMoney() external returns(uint){
    	uint amount = betsMap[msg.sender].moneyBet * diceBetMultiplier;
		msg.sender.transfer(amount);		
		return betsMap[msg.sender].moneyBet * diceBetMultiplier;
	}
	function randomDoubleDice() private returns (uint){
		return randomUintBetween(1, 6) + randomUintBetween(1, 6);
    }


	
}