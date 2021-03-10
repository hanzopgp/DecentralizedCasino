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
	event EventRouletteResult(address player, string rouletteBet , string[] rouletteResult);



	//Constructor
	constructor() public{
		currentPlayer = msg.sender;
	}



	//Modifiers
	modifier isRightPlayer(address player){
		require(msg.sender == player);
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
	function playerReceivesMoney() external isRightPlayer(currentPlayer){
		if(gameType == 1){ //1: dice
			msg.sender.transfer(betsMap[currentPlayer].moneyBet * diceBetMultiplier);
		}else if(gameType == 2){ //2: roulette
			msg.sender.transfer(betsMap[currentPlayer].moneyBet * betsMap[currentPlayer].rouletteBetMultiplier);
		}
	}
	function isBetSet() public view returns(bool){
		return betsMap[currentPlayer].isSet;
	}
	function cancelBet() external isRightPlayer(currentPlayer) returns(bool){
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
	function getDiceBet(uint playerBet) public payable isRightPlayer(currentPlayer) isEnoughMoney currentBetIsNotSet returns(uint, bool, uint){
		require(playerBet >= minDiceValue, "Bet must be between " + minDiceValue + " and " + maxDiceValue);
		require(playerBet <= maxDiceValue, "Bet must be between " + minDiceValue + " and " + maxDiceValue);
		contractBalance += msg.value;
		betsMap[currentPlayer].isSet = true;
		betsMap[currentPlayer].diceBet = playerBet;
		emit EventDiceBet(currentPlayer, betsMap[currentPlayer].diceBet);
		return (betsMap[currentPlayer].diceBet, betsMap[currentPlayer].isSet, betsMap[currentPlayer].moneyBet);
	}
	function playDice() public isRightPlayer(currentPlayer) currentBetIsSet returns(address , uint , uint){
		gameType = 1;																
		betsMap[currentPlayer].diceResult = randomDoubleDice();															
		betsMap[currentPlayer].isSet = false;
		if(betsMap[currentPlayer].diceResult == betsMap[currentPlayer].diceBet){	
			this.playerReceivesMoney();
		}
		emit EventDiceResult(currentPlayer, betsMap[currentPlayer].diceBet, betsMap[currentPlayer].diceResult);
		return (currentPlayer , betsMap[currentPlayer].diceBet , betsMap[currentPlayer].diceResult);
	}
    function randomDoubleDice() private view returns (uint){
		return randomUintBetween(1, 6) + randomUintBetween(1, 6);
    }



    //Roulette game functions
	function getRouletteBet(string storage playerBet) public payable isRightPlayer(currentPlayer) isEnoughMoney currentBetIsNotSet returns(string storage, bool, uint){
		require(checkRouletteBet(playerBet));
		contractBalance += msg.value;
		betsMap[currentPlayer].isSet = true;
		betsMap[currentPlayer].rouletteBet = playerBet;
		emit EventRouletteBet(currentPlayer, betsMap[currentPlayer].rouletteBet);
		return (betsMap[currentPlayer].rouletteBet, betsMap[currentPlayer].isSet, betsMap[currentPlayer].moneyBet);
	}
	function playRoulette() public isRightPlayer(currentPlayer) currentBetIsSet returns(address, string storage, string[] storage){	
		gameType = 2;	
		rouletteGame();	
		betsMap[currentPlayer].isSet = false;
		isPlayerWinning();
		this.playerReceivesMoney();
		emit EventRouletteResult(currentPlayer, betsMap[currentPlayer].rouletteBet, betsMap[currentPlayer].rouletteResult);
		return (currentPlayer, betsMap[currentPlayer].rouletteBet, betsMap[currentPlayer].rouletteResult);
	}
	function isPlayerWinning() private view returns(bool){
		if((betsMap[currentPlayer].rouletteBet == betsMap[currentPlayer].rouletteResult.number)
		|| (betsMap[currentPlayer].rouletteBet == betsMap[currentPlayer].rouletteResult.isGreen)
		|| (betsMap[currentPlayer].rouletteBet == betsMap[currentPlayer].rouletteResult.color)
		|| (betsMap[currentPlayer].rouletteBet == betsMap[currentPlayer].rouletteResult.thirdNumber)){
			return true;
		}
		return false;
	}
	function rouletteGame() private view{
		uint rouletteNumberResult = randomUintBetween(0, 36);
		//Number
		RouletteResult.number = uintToString(rouletteNumberResult);
		//Color
		if(rouletteNumberResult % 2 == 0 && rouletteNumberResult != 0){
			RouletteResult.color = "black";
		}else{
			RouletteResult.color = "white";
		}
		//Third
		if(rouletteNumberResult > 0 && rouletteNumberResult <= 12){
			RouletteResult.thirdNumber = "firstThird";
		}else if(rouletteNumberResult > 12 && rouletteNumberResult <= 24){
			RouletteResult.thirdNumber = "secondThird";
		}else{
			RouletteResult.thirdNumber = "thirdNumber";
		}
		//Green
		if(rouletteNumberResult == 0){
			RouletteResult.isGreen = "true";
		}else{
			RouletteResult.isGreen = "false";
		}
	}
	function checkRouletteBet(string storage playerBet) private view returns(bool){
		if(playerBet == "black" 
		|| playerBet == "white"){
			betsMap[currentPlayer].rouletteBetMultiplier == 2;
			return true;
		}else if(playerBet == "green"){
			betsMap[currentPlayer].rouletteBetMultiplier == 36;
			return true;
		}else if(playerBet == "firstThird" 
			  || playerBet == "secondThird" 
			  || playerBet == "thirdThird"){
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
	function randomUintBetween(uint min, uint max) private view returns(uint){
		randomId++;
		return uint(keccak256(abi.encodePacked(now, currentPlayer, randomId))) % max + min;
	}
	function tableContains(string[] storage table, string storage element) private view returns(bool){
		for(uint i = 0; i < table.length; i++){
			if(table[i] == element){
				return true;
			}
		}
		return false;
	}
	function stringToUint(string storage str) private view returns (uint res){
		res = 0;
        bytes storage b = bytes(str);    
        for (uint i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                res = res * 10 + (c - 48);
            }
        	return res;
    	}
    }
    function uintToString(uint v) private view returns (string storage str) {
        uint maxlength = 100;
        bytes storage reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes storage s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }
	
}