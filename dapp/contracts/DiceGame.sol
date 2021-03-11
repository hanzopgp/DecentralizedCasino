pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";

contract DiceGame is Ownable{ //Ownable allows use onlyOwner modifier so we can make admin functions

	using SafeMath for uint256; //Using SafeMath lib to avoid overflow erros



	//Variables
	struct RouletteResult{
		string number;
		string thirdNumber;
		string isGreen;
		string color;
	}
	struct Bet{
		bool isSet; 
		uint moneyBet;
		uint diceBet;
		uint diceResult;
		string rouletteBet;	
		RouletteResult rouletteResult;
		uint rouletteBetMultiplier;	
	}
	mapping(address => Bet) private betsMap;
	address currentPlayer;
	uint randomId = 0;
	uint public gameType = 0; //0: null, 1: dice, 2: roulette
	uint public maximumBetValue = 1 ether;
	uint public minimumBetValue = 0.001 ether;
	uint private contractBalance = 0;
	uint public minDiceValue = 2;
	uint public maxDiceValue = 12;
	uint public diceBetMultiplier = 10;



	//Events
	event EventCancelBet(address player);
	event EventDiceBet(address player , uint diceBet);
	event EventDiceResult(address player, uint diceBet , uint diceResult);
	event EventRouletteBet(address player , string rouletteBet);
	event EventRouletteResult(address player, string rouletteBet , string rouletteResultNb);



	//Constructor
	constructor() public{
		msg.sender == currentPlayer;
	}



	//Modifiers
	modifier isRightPlayer(){
		//require(msg.sender == currentPlayer, "You are not the current player");
		_;
	}
	modifier isEnoughMoney(){
		require(msg.value >= minimumBetValue, "Too low bet value");
		require(msg.value <= maximumBetValue, "Too high bet value");
		_;
	}
	modifier currentBetIsNotSet(){
		require(betsMap[currentPlayer].isSet == false, "There is already a bet ready");
		_;
	}
	modifier currentBetIsSet(){
		require(betsMap[currentPlayer].isSet == true, "You need to bet before playing"); 
		_;
	}



	//General casino functions
	function playerReceivesMoney() external isRightPlayer{
		if(gameType == 1){ //1: dice
			msg.sender.transfer(betsMap[currentPlayer].moneyBet * diceBetMultiplier);
		}else if(gameType == 2){ //2: roulette
			msg.sender.transfer(betsMap[currentPlayer].moneyBet * betsMap[currentPlayer].rouletteBetMultiplier);
		}
	}
	function isBetSet() public view returns(bool){
		return betsMap[currentPlayer].isSet;
	}
	function cancelBet() external isRightPlayer returns(bool){
		require(betsMap[currentPlayer].isSet == true, "There is no bet currently");
		betsMap[currentPlayer].diceBet = 0;
		betsMap[currentPlayer].rouletteBet = "";
		betsMap[currentPlayer].isSet = false;
		betsMap[currentPlayer].diceResult = 0;
		msg.sender.transfer(betsMap[currentPlayer].moneyBet);
		betsMap[currentPlayer].moneyBet = 0;
		emit EventCancelBet(currentPlayer);
		return true;
	}



	//Dice game functions
	function getDiceBet(uint playerBet) public payable isRightPlayer isEnoughMoney currentBetIsNotSet returns(uint, bool, uint){
		require(playerBet >= minDiceValue, "Bet must be between 2 and 12");
		require(playerBet <= maxDiceValue, "Bet must be between 2 and 12");
		contractBalance += msg.value;
		betsMap[currentPlayer].isSet = true;
		betsMap[currentPlayer].diceBet = playerBet;
		emit EventDiceBet(currentPlayer, betsMap[currentPlayer].diceBet);
		return (betsMap[currentPlayer].diceBet, betsMap[currentPlayer].isSet, betsMap[currentPlayer].moneyBet);
	}
	function playDice() public isRightPlayer currentBetIsSet returns(address , uint , uint){
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



    //Roulette game functions
	function getRouletteBet(string memory playerBet) public payable isRightPlayer isEnoughMoney currentBetIsNotSet returns(string memory, bool, uint){
		require(checkRouletteBet(playerBet));
		contractBalance += msg.value;
		betsMap[currentPlayer].isSet = true;
		betsMap[currentPlayer].rouletteBet = playerBet;
		emit EventRouletteBet(currentPlayer, betsMap[currentPlayer].rouletteBet);
		return (betsMap[currentPlayer].rouletteBet, betsMap[currentPlayer].isSet, betsMap[currentPlayer].moneyBet);
	}
	function playRoulette() public isRightPlayer currentBetIsSet returns(address, string memory, string memory){	
		gameType = 2;	
		rouletteGame();	
		betsMap[currentPlayer].isSet = false;
		if(isPlayerWinning() == true){
			this.playerReceivesMoney();
		}	
		emit EventRouletteResult(currentPlayer, betsMap[currentPlayer].rouletteBet, betsMap[currentPlayer].rouletteResult.number);
		return (currentPlayer, betsMap[currentPlayer].rouletteBet, betsMap[currentPlayer].rouletteResult.number);
	}
	function isPlayerWinning() private view returns(bool){
		if((compareStrings(betsMap[currentPlayer].rouletteBet, betsMap[currentPlayer].rouletteResult.number))
		|| ((compareStrings(betsMap[currentPlayer].rouletteBet, betsMap[currentPlayer].rouletteResult.isGreen)))
		|| ((compareStrings(betsMap[currentPlayer].rouletteBet, betsMap[currentPlayer].rouletteResult.color)))
		|| ((compareStrings(betsMap[currentPlayer].rouletteBet, betsMap[currentPlayer].rouletteResult.thirdNumber)))){
			return true;
		}
		return false;
	}
	function rouletteGame() private {
		uint rouletteNumberResult = randomUintBetween(0, 36);
		//Number
		betsMap[currentPlayer].rouletteResult.number = uintToString(rouletteNumberResult);
		//Color
		if(rouletteNumberResult % 2 == 0 && rouletteNumberResult != 0){
			betsMap[currentPlayer].rouletteResult.color = "black";
		}else{
			betsMap[currentPlayer].rouletteResult.color = "white";
		}
		//Third
		if(rouletteNumberResult > 0 && rouletteNumberResult <= 12){
			betsMap[currentPlayer].rouletteResult.thirdNumber = "firstThird";
		}else if(rouletteNumberResult > 12 && rouletteNumberResult <= 24){
			betsMap[currentPlayer].rouletteResult.thirdNumber = "secondThird";
		}else{
			betsMap[currentPlayer].rouletteResult.thirdNumber = "thirdNumber";
		}
		//Green
		if(rouletteNumberResult == 0){
			betsMap[currentPlayer].rouletteResult.isGreen = "true";
		}else{
			betsMap[currentPlayer].rouletteResult.isGreen = "false";
		}
	}
	function checkRouletteBet(string memory playerBet) private view returns(bool){
		if((compareStrings(playerBet, "black")) 
		|| (compareStrings(playerBet, "white"))){
			betsMap[currentPlayer].rouletteBetMultiplier == 2;
			return true;
		}else if(compareStrings(playerBet, "green")){
			betsMap[currentPlayer].rouletteBetMultiplier == 36;
			return true;
		}else if((compareStrings(playerBet, "firstThird")) 
			  || (compareStrings(playerBet, "secondThird"))
			  || (compareStrings(playerBet, "thirdThird"))){
			betsMap[currentPlayer].rouletteBetMultiplier == 3;
			return true;
		}else if(stringToUint(playerBet) >= 0 && stringToUint(playerBet) <= 36){
			betsMap[currentPlayer].rouletteBetMultiplier == 36;
			return true;
		}else{ //If the bet is not right
			betsMap[currentPlayer].rouletteBetMultiplier == 1;
			return false;
		}
	}



    //Admin functions with onlyOwner
    function addFundsContractBalance() external payable onlyOwner{
    	require(msg.value > 0, "No funds transfered");
		contractBalance += msg.value;
	}
    function withdrawContractBalance() external onlyOwner{
		msg.sender.transfer(contractBalance);
	}
	function getContractBalance() external view onlyOwner returns(uint){
		return contractBalance;
	}



	//Utility functions
	function randomUintBetween(uint min, uint max) private returns(uint){
		randomId++;
		return uint(keccak256(abi.encodePacked(now, currentPlayer, randomId))) % max + min;
	}
	function stringToUint(string memory s) internal pure returns (uint result) {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(uint8(b[i])); //Conversion trick
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }
    function uintToString(uint _i) internal pure returns (string memory _uintAsString) {
        uint number = _i;
        if (number == 0) {
            return "0";
        }
        uint j = number;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (number != 0) {
            bstr[k--] = byte(uint8(48 + number % 10));
            number /= 10;
        }
        return string(bstr);
    }
    function compareStrings(string memory a, string memory b) internal pure returns(bool){
    	return keccak256(bytes(a)) == keccak256(bytes(b));
    }
	
}