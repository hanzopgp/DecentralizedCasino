pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";

contract Casino is Ownable{ //Ownable allows use onlyOwner modifier so we can make admin functions



	using SafeMath for uint256; //Using SafeMath lib to avoid overflow erros



	//Variables
	uint private contractBalance = 0;
	mapping (address => uint) public playerGameType; //address : currentPlayer ; uint : gameType
	mapping (address => Game) public playerGame; //address : currentPlayer ; Game : Dice or Roulette


	//Game type setter
	function setGameType(uint typef) external{
		playerGame[msg.sender] = typef;
		if(typef == 1){
			playerGame[msg.sender] = new Dice();
		}
		else if(typef == 2){
			//playerGame[msg.sender] = new Roulette();
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