pragma solidity ^0.5.0;

import "./lib/SafeMath.sol";
import "./lib/Ownable.sol";
import "./games/Game.sol";
import "./games/Dice.sol";
import "./games/Roulette.sol";
import "./Utility.sol";

contract Casino is Utility, Ownable{ //Ownable allows using onlyOwner modifier so we can make admin functions

	using SafeMath for uint256; //Using SafeMath lib to avoid overflow errors
	using SafeMath for uint8;

	Game[] games;
	mapping (address => Game) public gamesMap; //address : currentPlayer ; Game : Dice or Roulette contract

	uint tokenId;
	uint tokenPrice = 0.1 ether;
	mapping (address => uint) public ownerTokenCount; //address : currentPlayer ; uint : nb tokens
	mapping (uint => address) public tokensToOwner; // uint : tokenID ; address : currentPlayer
	uint[] public tokens;
	event EventTokenBought(address player, uint tokenBought);
	uint gasFee = 0.001 ether;

	//the player has set the game
	event EventGameSet(address player, uint gameType);
	//the player has bet
	event EventBet(address player , string betInfo, uint8 bet, uint256 money);
	//the player has played and got this result
	event EventResult(address player, uint8 result);
	//current player's bet has been canceled, this amount of money has been sent back
	event EventCancelBet(address player, uint256 amount);
	//player won money
	event EventPlayerReceives(address player, uint256 amount);

	//Constructor
	constructor() public{
		games.push(new Dice());
		games.push(new Roulette());
	}

	//Modifiers
	modifier isGameSet(){
		require(address(gamesMap[msg.sender]) != address(0), "There is no current game set");
		_;
	}

	//Get number of tokens of the user
	function getNbTokensOf() external view returns(uint){
		return ownerTokenCount[msg.sender];
	}

	//Get casino custom tokens
	function buyCasitokens(uint nbtok) external payable isEnoughMoneyAndToken(msg.value, nbtok, tokenPrice) returns(uint){
		//Checks if the user bought minimum one token and the amount he paid is enough
		require(nbtok > 1 && (msg.value >= (tokenPrice * nbtok)), "Invalid ether or token number"); 
		if(msg.value > (tokenPrice * nbtok)){					   
			msg.sender.transfer(((tokenPrice * nbtok) - msg.value) - gasFee); //Refund in case user paid too much for the tokens in input
		}
		for(uint i = 0; i < nbtok; i++){
			uint id = tokens.push(tokenId++);
			tokensToOwner[id] = msg.sender;						   //Save the tokens for the current user
			ownerTokenCount[msg.sender]++;						   //Keeps track of the users balance
		}		
		emit EventTokenBought(msg.sender, ownerTokenCount[msg.sender]);					   
		return ownerTokenCount[msg.sender];
	}

	//Game type setter
	function setGameType(uint8 gameType) external returns(bool){
		require(uint(gameType) <= games.length, "This game doesn't exist");
		gamesMap[msg.sender] = games[gameType.sub(1)];
		emit EventGameSet(msg.sender, gameType);
		return (true);
	}

	//Playing game
	function isBetSetGame() external view isGameSet returns(bool){
		return gamesMap[msg.sender].isBetSet(msg.sender);
	}

	function betGame(string calldata betInfo, 
					 uint8 betData, 
					 uint tokenAmount) external enoughTokenBalance(tokenAmount, ownerTokenCount[msg.sender]) 
										        isGameSet 
												returns(bool){
		bool _success = gamesMap[msg.sender].bet(msg.sender, betInfo, betData, tokenAmount);
		if(_success){
			emit EventBet(msg.sender, betInfo, betData, tokenAmount);
			return _success;
		}else{
			revert("Incorrect bet");
		}
	}

	function cancelBetGame() external isGameSet returns(bool){
		uint256 tokenRefund = gamesMap[msg.sender].cancelBet(msg.sender);
		if(tokenRefund > 0){
			msg.sender.transfer((tokenRefund * tokenPrice) - gasFee);
			emit EventCancelBet(msg.sender, tokenRefund);
			return true;
		}else{
			return false;		
		}		
	}	

	function playGame() external isGameSet returns(uint8 , uint256){
		(uint8 result, uint256 tokenEarned) = gamesMap[msg.sender].play(msg.sender);
		emit EventResult(msg.sender, result);
		if(tokenEarned > 0){
			msg.sender.transfer(tokenEarned * tokenPrice - gasFee);
			emit EventPlayerReceives(msg.sender, tokenEarned);
		}
		return (result, tokenEarned);
	}

    //Admin functions with onlyOwner
    function addFundsCasinoBalance() external payable onlyOwner{
    	require(msg.value > 0, "No funds transfered");
	}

    function withdrawCasinoBalance(uint amount) external onlyOwner{
    	address payable casino = address(uint160(address(this))); //conversion trick
    	require(casino.balance >= amount, "Not enough balance");
		msg.sender.transfer(amount);
	}

	function getCasinoBalance() external view onlyOwner returns(uint){
		address payable casino = address(uint160(address(this))); //conversion trick
		return casino.balance;
	}

}
