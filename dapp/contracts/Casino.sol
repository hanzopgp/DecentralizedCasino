pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./Game.sol";
import "./Dice.sol";
import "./Utility.sol";

contract Casino is Ownable{ //Ownable allows use onlyOwner modifier so we can make admin functions



	using SafeMath for uint256; //Using SafeMath lib to avoid overflow erros



	//Variables
	uint casinoBalance = 0;
	Game game;
	bool gameSet = false;
	struct PlayerInfo{
		string name;
		bool gameSet;
	}
	mapping (address => Game) public gamesMap; //address : currentPlayer ; Game : Dice or Roulette contract
	mapping (address => PlayerInfo) playerInfoMap; //address : currentPlayer ; PlayerInfo : player infos structure




	//Events
	event EventGameSet(address player, bool gameSet);
	event EventBet(address player , uint bet);
	event EventResult(address player, uint bet , uint result);
	event EventCancelBet(address player);
	event EventPlayerReceives(address player, uint amount);




	//Modifiers
	modifier isGameSet(){
		require(playerInfoMap[msg.sender].gameSet == true);
		_;
	}




	//Game type setter
	function setGameType(uint gameType) external returns(bool){
		if(gameType == 1){
			gamesMap[msg.sender] = new Dice();
			playerInfoMap[msg.sender].gameSet = true;
			emit EventGameSet(msg.sender, playerInfoMap[msg.sender].gameSet);
			return playerInfoMap[msg.sender].gameSet;
		}
		else if(gameType == 2){
			//gamesMap[msg.sender] = new Roulette();
			//playerInfoMap[msg.sender].gameSet = true;
			//emit EventGameSet(msg.sender, playerInfoMap[msg.sender].gameSet);
			//return playerInfoMap[msg.sender].gameSet;
		}
		return playerInfoMap[msg.sender].gameSet;
	}



	//Playing game
	function isBetSet() public view isGameSet returns(bool){
		return gamesMap[msg.sender].isBetSet();
	}
	function bet(string memory empty, uint playerBet) public payable isGameSet returns(uint, bool, uint){
		emit EventBet(msg.sender, playerBet);
		(uint betValue, bool isSet, uint moneyBet) = gamesMap[msg.sender].bet(empty, playerBet);
		casinoBalance += moneyBet; 
		return (betValue, isSet, moneyBet);
	}
	function cancelBet() external isGameSet returns(bool){
		emit EventCancelBet(msg.sender);
		return gamesMap[msg.sender].cancelBet();
	}	
	function play() public isGameSet returns(uint , uint){
		(uint betValue, uint result) = gamesMap[msg.sender].play();
		emit EventResult(msg.sender, betValue, result);
		return (betValue, result);
	}
	function playerReceivesMoney() isGameSet external returns(uint){
		uint moneyWin = gamesMap[msg.sender].playerReceivesMoney();
		casinoBalance -= moneyWin;
		emit EventPlayerReceives(msg.sender, moneyWin);
		return moneyWin;
	}



    //Admin functions with onlyOwner
    function addFundsCasinoBalance() external payable onlyOwner{
    	require(msg.value > 0, "No funds transfered");
		casinoBalance += msg.value;
	}
    function withdrawCasinoBalance() external onlyOwner{
    	require(casinoBalance > 0, "Not enough balance");
		msg.sender.transfer(casinoBalance);
	}
	function getCasinoBalance() external view onlyOwner returns(uint){
		return casinoBalance;
	}
	function increaseCasinoBalance(uint amount) internal{
		casinoBalance += amount;
	}



}