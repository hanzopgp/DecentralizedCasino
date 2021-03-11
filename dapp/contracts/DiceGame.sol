pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Casino.sol";

contract Dice is Casino{ //Ownable allows use onlyOwner modifier so we can make admin functions



	using SafeMath for uint256; //Using SafeMath lib to avoid overflow erros



	//Variables
	struct Bet{
		bool isSet; 
		uint moneyBet;
		uint diceBet;
		uint diceResult;
	}
	mapping(address => Bet) private betsMap;
	uint public diceBetMultiplier = 10;



	//Events
	event EventDiceBet(address player , uint diceBet);
	event EventDiceResult(address player, uint diceBet , uint diceResult);



	//Dice game functions
	function bet(string empty, uint playerBet) public payable isEnoughMoney currentBetIsNotSet returns(uint, bool, uint){
		require(playerBet >= 2, "Bet must be between 2 and 12");
		require(playerBet <= 12, "Bet must be between 2 and 12");
		contractBalance += msg.value;
		betsMap[currentPlayer].isSet = true;
		betsMap[currentPlayer].diceBet = playerBet;
		emit EventDiceBet(currentPlayer, betsMap[currentPlayer].diceBet);
		return (betsMap[currentPlayer].diceBet, betsMap[currentPlayer].isSet, betsMap[currentPlayer].moneyBet);
	}
	function play() public currentBetIsSet returns(address , uint , uint){
		gameType = 1;																
		betsMap[currentPlayer].diceResult = randomDoubleDice();															
		betsMap[currentPlayer].isSet = false;
		if(betsMap[currentPlayer].diceResult == betsMap[currentPlayer].diceBet){	
			this.playerReceivesMoney();
		}
		emit EventDiceResult(currentPlayer, betsMap[currentPlayer].diceBet, betsMap[currentPlayer].diceResult);
		return (currentPlayer , betsMap[currentPlayer].diceBet , betsMap[currentPlayer].diceResult);
	}
    function randomDoubleDice() private returns (uint){
		return randomUintBetween(1, 6) + randomUintBetween(1, 6);
    }


	
}