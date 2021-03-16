pragma solidity ^0.5.0;

import "./lib/SafeMath.sol";
import "./lib/Ownable.sol";
import "./games/Game.sol";
import "./games/Dice.sol";
import "./games/Roulette.sol";
import "./Utility.sol";

contract Casino is Ownable{ //Ownable allows using onlyOwner modifier so we can make admin functions

	using SafeMath for uint256; //Using SafeMath lib to avoid overflow errors
	using SafeMath for uint8;

	//Variables
	uint256 casinoBalance = 0;
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
	event EventBet(address player , uint8 bet);
	event EventResult(address player, uint8 bet , uint8 result);
	event EventCancelBet(address player);
	event EventPlayerReceives(address player, uint256 amount);

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
	function setGameType(uint8 gameType) external returns(bool, uint8){
		bool _success = false;
		gamesMap[msg.sender] = games[gameType.sub(1)];
		playerInfoMap[msg.sender].gameSet = true;
		_success = true;
		emit EventGameSet(msg.sender, playerInfoMap[msg.sender].gameSet);
		return (playerInfoMap[msg.sender].gameSet, gameType);
	}

	//Playing game
	function isBetSetGame() external view isGameSet returns(bool){
		return gamesMap[msg.sender].isBetSet();
	}

	function betGame(string calldata empty, uint8 playerBet) external payable isGameSet returns(uint8, bool, uint256){
		(uint8 betValue, bool isSet, uint256 moneyBet) = gamesMap[msg.sender].bet(empty, playerBet);
		increaseCasinoBalance(moneyBet);
		emit EventBet(msg.sender, playerBet);
		return (betValue, isSet, moneyBet);
	}

	function cancelBetGame() external isGameSet returns(uint256){
		uint256 moneyBack = gamesMap[msg.sender].cancelBet();
		msg.sender.transfer(moneyBack);
		emit EventCancelBet(msg.sender);
		return moneyBack;
	}	

	function playGame() external isGameSet returns(uint8 , uint8){
		(uint8 betValue, uint8 result) = gamesMap[msg.sender].play();
		emit EventResult(msg.sender, betValue, result);
		return (betValue, result);
	}

	function playerWithdrawMoney() isGameSet external returns(uint256){
		uint256 moneyWin = gamesMap[msg.sender].playerMoneyWin();
		decreaseCasinoBalance(moneyWin);
		msg.sender.transfer(moneyWin);
		emit EventPlayerReceives(msg.sender, moneyWin);
		return moneyWin;
	}

    //Admin functions with onlyOwner
    function addFundsCasinoBalance() external payable onlyOwner{
    	require(msg.value > 0, "No funds transfered");
		increaseCasinoBalance(msg.value);
	}

    function withdrawCasinoBalance() external onlyOwner{
    	require(casinoBalance > 0, "Not enough balance");
		msg.sender.transfer(casinoBalance);
	}

	function getCasinoBalance() external view onlyOwner returns(uint){
		return casinoBalance;
	}

	function increaseCasinoBalance(uint amount) internal{
		casinoBalance += casinoBalance.sub(amount);
	}

	function decreaseCasinoBalance(uint amount) internal{
		casinoBalance = casinoBalance.sub(amount);
	}

}
