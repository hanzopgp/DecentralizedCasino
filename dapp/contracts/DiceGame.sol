pragma solidity ^0.5.0;

contract DiceGame{

	address public player;
	uint minimumBet = 0.001 ether;
	uint maximumBet = 5 ether;
	uint betValue = 0 ether;

	event HasPaid(address player);
    event Won(address player);
    event Lost(address player);

	constructor() public{
		player = msg.sender;
	}

	modifier payed(){
		require(betValue > 0 ether);
		_;
	}

	function computeDoubleDice() private view returns(uint){
      	uint randNonce = 0;
		uint dice1 = uint(keccak256(abi.encodePacked(now, player, randNonce))) % 6 + 1;
		randNonce++;
		uint dice2 = uint(keccak256(abi.encodePacked(now, player, randNonce))) % 6 + 1;
		uint doubleDice = dice1 + dice2;
		return doubleDice;
	}

	function pay() external payable{
		require(msg.value >= minimumBet);
		require(msg.value < maximumBet);
		emit HasPaid(player);
		betValue = address(this).balance;
  	}

  	function receive() external payable{
  		msg.sender.transfer(betValue*11);
  	}

  	function play(uint betNb) external payed(){
  		uint doubleDice = computeDoubleDice();
  		if(betNb == doubleDice){
  			this.receive();
  			emit Won(player);
  		}else{
  			emit Lost(player);
  		}
  	}

}