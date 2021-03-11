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
	mapping (address => Game) public gamesMap; //address : currentPlayer ; Game : Dice or Roulette


	//Game type setter
	function setGameType(uint gameType) external{
		if(gameType == 1){
			gamesMap[msg.sender] = new Dice();
		}
		else if(gameType == 2){
			//gamesMap[msg.sender] = new Roulette();
		}	
	}



	//Playing game
	function isBetSet() public view returns(bool){
		return gamesMap[msg.sender].isBetSet();
	}
	function bet(string memory empty, uint playerBet) public payable returns(uint, bool, uint){
		(uint a, bool b, uint moneyBet) = gamesMap[msg.sender].bet(empty, playerBet);
		casinoBalance += moneyBet; 
		return (a, b, moneyBet);
	}
	function cancelBet() external returns(bool){
		return gamesMap[msg.sender].cancelBet();
	}	
	function play() public returns(address , uint , uint){
		return gamesMap[msg.sender].play();
	}
	function playerReceivesMoney() external{
		casinoBalance -= gamesMap[msg.sender].playerReceivesMoney();
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