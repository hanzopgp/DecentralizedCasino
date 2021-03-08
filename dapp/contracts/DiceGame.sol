pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";

contract DiceGame is Ownable{

	using SafeMath for uint256;

	struct Bet{
		uint currentBet;
		bool isSet; 	
		uint diceResult;
		uint moneyBet;
	}

	mapping(address => Bet) private betsMap;
	address currentPlayer;
	uint public maximumBetValue = 1 ether;
	uint public minimumBetValue = 0.001 ether;
	uint private contractBalance = 0;

	event EventNewBet(address player , uint currentBet);
	event EventGameResult(address player, uint currentBet , uint diceResult);

	constructor() public{
		currentPlayer = msg.sender;
	}

	// function() external payable{}

	function playerWin() external payable{
		msg.sender.transfer(betsMap[currentPlayer].moneyBet * 10);
	}

	function isBetSet() public view returns(bool){
		return betsMap[currentPlayer].isSet;
	}

	function getNewBet(uint playerBet) public payable returns(uint){
		require(betsMap[currentPlayer].isSet == false, "There is already a bet ready");
		require(playerBet >= 2, "Bet must be between 2 and 12");
		require(playerBet <= 12, "Bet must be between 2 and 12");
		require(msg.value >= minimumBetValue, "Too low bet value");
		require(msg.value <= maximumBetValue, "Too high bet value");
		contractBalance += msg.value;
		betsMap[currentPlayer].isSet = true;
		betsMap[currentPlayer].currentBet = playerBet;
		emit EventNewBet(currentPlayer, betsMap[currentPlayer].currentBet);
		return betsMap[currentPlayer].currentBet;
	}

	function playDice() public returns(address , uint , uint){
		require(betsMap[currentPlayer].isSet == true, "You need to bet before playing"); 																	
		betsMap[currentPlayer].diceResult = randomDoubleDice();															
		betsMap[currentPlayer].isSet = false;
		if(betsMap[currentPlayer].diceResult == betsMap[currentPlayer].currentBet){
			this.playerWin();
		}
		emit EventGameResult(currentPlayer, betsMap[currentPlayer].currentBet, betsMap[currentPlayer].diceResult);
		return (currentPlayer , betsMap[currentPlayer].currentBet , betsMap[currentPlayer].diceResult);
	}

    function randomDoubleDice() private view returns (uint) {
    	uint randomId = 0;
		uint firstDice = uint(keccak256(abi.encodePacked(now, currentPlayer, randomId))) % 6 + 1;	
		randomId++;
		uint secondDice = uint(keccak256(abi.encodePacked(now, currentPlayer, randomId))) % 6 + 1;
		return firstDice + secondDice;
    }

    function withdrawContractBalance() external onlyOwner{
		msg.sender.transfer(contractBalance);
	}

	function getContractBalance() external view onlyOwner returns(uint){
		return contractBalance;
	}
	
}