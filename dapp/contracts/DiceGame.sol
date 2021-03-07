pragma solidity ^0.5.0;

contract Dice{

	struct Bet{
		uint8  currentBet;
		bool  isBetSet; //default value is false	
		uint8  destiny;
	}

	mapping(address => Bet) private bets;

	uint8 private randomFactor;

	address currentPlayer;

	event NewBetIsSet(address player , uint8 currentBet);
	event GameResult(address player, uint8 currentBet , uint8 destiny);

	constructor() public{
		randomFactor = 10;
		currentPlayer = msg.sender;
	}

	function() external payable{}

	function isBetSet() public view returns(bool){
		return bets[currentPlayer].isBetSet;
	}

	function getNewbet() public returns(uint8){
		require(bets[currentPlayer].isBetSet == false);
		bets[currentPlayer].isBetSet = true;
		bets[currentPlayer].currentBet = random();
		randomFactor += bets[currentPlayer].currentBet;
		emit NewBetIsSet(currentPlayer,bets[currentPlayer].currentBet);
		return bets[currentPlayer].currentBet;
	}

	function roll() public returns(address , uint8 , uint8){
		require(bets[currentPlayer].isBetSet == true);
		bets[currentPlayer].destiny = random();
		randomFactor += bets[currentPlayer].destiny;
		bets[currentPlayer].isBetSet = false;
		if(bets[currentPlayer].destiny == bets[currentPlayer].currentBet){
			msg.sender.transfer(100000000000000);
			emit GameResult(currentPlayer, bets[currentPlayer].currentBet, bets[currentPlayer].destiny);			
		}else{
			emit GameResult(currentPlayer, bets[currentPlayer].currentBet, bets[currentPlayer].destiny);
		}
		return (currentPlayer , bets[currentPlayer].currentBet , bets[currentPlayer].destiny);
	}


    function random() private view returns (uint8) {
       	uint256 blockValue = uint256(blockhash(block.number-1 + block.timestamp));
        blockValue = blockValue + uint256(randomFactor);
        return uint8(blockValue % 5) + 1;
    }
	
}