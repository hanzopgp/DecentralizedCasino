pragma solidity ^0.5.0;

import "./../lib/SafeMath.sol";
import "./../lib/Ownable.sol";
import "./../Utility.sol";
import "./Game.sol";

contract Dice is Game, Utility, Ownable{ //Ownable allows use onlyOwner modifier so we can make admin functions

	using SafeMath for uint256; //Using SafeMath lib to avoid overflow errors
	using SafeMath for uint8;

	//Variables
	struct Bet{
		bool isSet; 
		uint256 tokenAmount;
		uint8 diceBet;
	}
	mapping(address => Bet) private betsMap;
	uint256 diceBetMultiplier = 6;

	//Dice game functions
	function isBetSet(address player) external view onlyOwner returns(bool){
		return betsMap[player].isSet;
	}

	function bet(address player, 
				 string calldata /*betInfo*/, 
				 uint8 betData, 
				 uint tokenAmount) external onlyOwner
									        currentBetIsNotSet(betsMap[player].isSet) 
									        returns(bool){
		require(betData >= 2, "Bet must be between 2 and 12");
		require(betData <= 12, "Bet must be between 2 and 12");
		betsMap[player].diceBet = betData;
		betsMap[player].isSet = true;
		betsMap[player].tokenAmount = tokenAmount;
		return betsMap[player].isSet;
	}

	function cancelBet(address player) external onlyOwner currentBetIsSet(betsMap[player].isSet) returns(uint256){
		betsMap[player].isSet = false;
		return betsMap[player].tokenAmount;
	}

	function play(address player) external onlyOwner currentBetIsSet(betsMap[player].isSet) returns(uint8 , uint256){																
		uint8 diceResult = randomDoubleDice();															
	   	uint256 amount = 0;
		if(diceResult == betsMap[player].diceBet){	
			amount = betsMap[player].tokenAmount.mul(diceBetMultiplier);
		}
		betsMap[player].isSet = false;
		return (diceResult, amount);
	}

	function randomDoubleDice() internal returns (uint8){
		return uint8(randomUintBetween(1, 6).add(randomUintBetween(1, 6)));
    }
	
}
