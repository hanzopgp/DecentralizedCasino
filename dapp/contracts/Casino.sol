pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./Game.sol";
import "./Dice.sol";
import "./Roulette.sol";
import "./Utility.sol";

contract Casino is Ownable{ //Ownable allows using onlyOwner modifier so we can make admin functions



	using SafeMath for uint256; //Using SafeMath lib to avoid overflow errors



	//Variables
	uint casinoBalance = 0;
	// Game game;
	Game[] games;
	bool gameSet = false;
	struct PlayerInfo{
		string name;
		bool gameSet;
	}
	mapping (address => Game) public gamesMap; //address : currentPlayer ; Game : Dice or Roulette contract
	mapping (address => PlayerInfo) public playerInfoMap; //address : currentPlayer ; PlayerInfo : player infos structure



	//Events
	event EventGameSet(address player, bool gameSet);
	event EventBet(address player , uint bet);
	event EventResult(address player, uint bet , uint result);
	event EventCancelBet(address player);
	event EventPlayerReceives(address player, uint amount);



	//Constructor
	constructor() public{
		games.push(new Dice());
		games.push(new Roulette());
	}



	//Modifiers
	modifier isGameSet(){
		require(playerInfoMap[msg.sender].gameSet == true, "There is no current game set");
		_;
	}



	//Game type setter
	function setGameType(uint gameType) external returns(bool){
		bool _success = false;
		gamesMap[msg.sender] = games[gameType-1];
		playerInfoMap[msg.sender].gameSet = true;
		_success = true;
		emit EventGameSet(msg.sender, playerInfoMap[msg.sender].gameSet);
		return playerInfoMap[msg.sender].gameSet;
	}



	//Playing game
	function isBetSetGame() external view isGameSet returns(bool){
		return gamesMap[msg.sender].isBetSet();
	}
	function betGame(string calldata empty, uint playerBet) external payable isGameSet returns(uint, bool, uint){
		(uint betValue, bool isSet, uint moneyBet) = gamesMap[msg.sender].bet(empty, playerBet);
		increaseCasinoBalance(moneyBet);
		emit EventBet(msg.sender, playerBet);
		return (betValue, isSet, moneyBet);
	}
	function cancelBetGame() external isGameSet returns(uint){
		uint moneyBack = gamesMap[msg.sender].cancelBet();
		msg.sender.transfer(moneyBack);
		emit EventCancelBet(msg.sender);
		return moneyBack;
	}	
	function playGame() external isGameSet returns(uint , uint){
		(uint betValue, uint result) = gamesMap[msg.sender].play();
		emit EventResult(msg.sender, betValue, result);
		return (betValue, result);
	}
	function playerWithdrawMoney() isGameSet external returns(uint){
		uint moneyWin = gamesMap[msg.sender].playerMoneyWin();
		decreaseCasinoBalance(moneyWin);
		msg.sender.transfer(moneyWin);
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
	function decreaseCasinoBalance(uint amount) internal{
		casinoBalance -= amount;
	}

}
