pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";

contract Casino is Ownable{ //Ownable allows use onlyOwner modifier so we can make admin functions



	using SafeMath for uint256; //Using SafeMath lib to avoid overflow erros



	//Variables
	uint private contractBalance = 0;
	mapping (address => Game) public playerGame; //address : currentPlayer ; Game : Dice or Roulette


	//Game type setter
	function setGameType(uint gameType) external{
		if(gameType == 1){
			playerGame[msg.sender] = new Dice();
		}
		else if(gameType == 2){
			//playerGame[msg.sender] = new Roulette();
		}	
	}



	//Playing game
	function isBetSet() public view returns(bool){
		return playerGame[msg.sender].isBetSet();
	}
	function bet(string empty, uint playerBet) public payable isEnoughMoney currentBetIsNotSet returns(uint, bool, uint){
		return playerGame[msg.sender].bet(empty, playerBet);
	}
	function cancelBet() currentBetIsSet external returns(bool){
		return playerGame[msg.sender].cancelBet();
	}	
	function play() public currentBetIsSet returns(address , uint , uint){
		return playerGame[msg.sender].play();
	}
	function playerReceivesMoney() external{
		return playerGame[msg.sender].playerReceivesMoney();
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



}