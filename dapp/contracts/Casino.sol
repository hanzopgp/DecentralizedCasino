pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";

contract Casino is Ownable{ //Ownable allows use onlyOwner modifier so we can make admin functions



	using SafeMath for uint256; //Using SafeMath lib to avoid overflow erros



	//Variables
	uint public gameType = 0; //0: null, 1: dice, 2: roulette
	uint private contractBalance = 0;
	Game game;



	//Game type setter
	function setGameType(uint type) external{
		gameType = type;
		if(type = 1){
			game = new Dice();
		}
		else if(type == 2){
			game = new Roulette();
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



}