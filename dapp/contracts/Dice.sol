pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Game.sol";
import "./Utility.sol";

contract Dice is Game, Utility{ //Ownable allows use onlyOwner modifier so we can make admin functions

	using SafeMath for uint256; //Using SafeMath lib to avoid overflow errors
	using SafeMath for uint8;

	//Variables
	struct Bet{
		bool isSet; 
		uint256 moneyBet;
		uint8 diceBet;
		uint8 diceResult;
	}
	mapping(address => Bet) private betsMap;
	uint8 diceBetMultiplier = 10;

	//Dice game functions
	function isBetSet() external view returns(bool){
		return betsMap[msg.sender].isSet;
	}
	function bet(string calldata empty, uint8 playerBet) external payable isEnoughMoney currentBetIsNotSet(betsMap[msg.sender].isSet) returns(uint8, bool, uint256){
		require(playerBet >= 2, "Bet must be between 2 and 12");
		require(playerBet <= 12, "Bet must be between 2 and 12");
		betsMap[msg.sender].diceBet = playerBet;
		betsMap[msg.sender].isSet = true;
		betsMap[msg.sender].moneyBet = msg.value;
		return (betsMap[msg.sender].diceBet, betsMap[msg.sender].isSet, betsMap[msg.sender].moneyBet);
	}
	function cancelBet() external currentBetIsSet(betsMap[msg.sender].isSet) returns(uint256){
		betsMap[msg.sender].diceBet = 0;
		betsMap[msg.sender].isSet = false;
		betsMap[msg.sender].diceResult = 0;
		uint256 moneyBetSave = betsMap[msg.sender].moneyBet;
		betsMap[msg.sender].moneyBet = 0;
		return moneyBetSave;
	}
	function play() external currentBetIsSet(betsMap[msg.sender].isSet) returns(uint8 , uint8){																
		betsMap[msg.sender].diceResult = randomDoubleDice();															
		betsMap[msg.sender].isSet = false;
		if(betsMap[msg.sender].diceResult == betsMap[msg.sender].diceBet){	
			this.playerMoneyWin();
		}
		return (betsMap[msg.sender].diceBet , betsMap[msg.sender].diceResult);
	}
    function playerMoneyWin() external returns(uint256){
    	uint256 amount = betsMap[msg.sender].moneyBet.mul(diceBetMultiplier);	
    	betsMap[msg.sender].moneyBet = 0;
		return amount;
	}
	function randomDoubleDice() internal returns (uint8){
		return uint8(randomUintBetween(1, 6).add(randomUintBetween(1, 6)));
    }
	
}