const DiceGame = artifacts.require("DiceGame");
const utils = require("./util/utils");
const playerNames = ["Player 1", "Player 2"];
contract("DiceGame", (accounts) => {
    let [a, b, c] = accounts;
    let contractInstance;

    beforeEach(async () => {
        contractInstance = await DiceGame.new();
    });


    it("isBetSet() should return false since there is no bet", async () => {
        const result = await contractInstance.isBetSet({from: accounts[0]});
        assert.equal(result, false);
    })
    it("isBetSet() should return true since there is a new bet", async () => {
    	await contractInstance.getNewBet(6, {from: accounts[0], value: 500000000000000000});
        const result = await contractInstance.isBetSet({from: accounts[0]});
        assert.equal(result, true);
    })


    it("getNewBet() should emit a EventNewBet", async () => {
  		const result = await contractInstance.getNewBet(6, {from: accounts[0], value: 500000000000000000});
        assert.equal(result.logs[0].event, "EventNewBet");
    })
    it("getNewBet() should return the bet value", async () => {
        const result = await contractInstance.getNewBet(6, {from: accounts[0], value: 500000000000000000});
        assert.equal(result.logs[0].args.currentBet, 6);
        
    })
    it("getNewBet() should return isSet as true", async () => {
        const result = await contractInstance.getNewBet(6, {from: accounts[0], value: 500000000000000000});
        assert.equal(result.logs[0].args.isSet, true);
        
    })
    it("getNewBet() should return the money value", async () => {
        const result = await contractInstance.getNewBet(6, {from: accounts[0], value: 500000000000000000});
        assert.equal(result.logs[0].args.moneyBet, 500000000000000000);
    })


    it("playDice() should emit a EventGameResult", async () => {
    	await contractInstance.getNewBet(6, {from: accounts[0], value: 500000000000000000});
        const result = await contractInstance.playDice();
        result.logs[0].event = "EventGameResult";
    })
    it("playDice() should return the player address", async () => {
    	await contractInstance.getNewBet(6, {from: accounts[0], value: 500000000000000000});
        const result = await contractInstance.playDice();
        assert.equal(result.logs[0].args.player, accounts[0]);
    })
    it("playDice() should return the player bet value", async () => {
    	await contractInstance.getNewBet(6, {from: accounts[0], value: 500000000000000000});
        const result = await contractInstance.playDice();
        assert.equal(result.logs[0].args.currentBet, 6);
    })
    it("playDice() should return the result of the dice", async () => {
    	await contractInstance.getNewBet(6, {from: accounts[0], value: 500000000000000000});
        const result = await contractInstance.playDice();
        let test1 = result.logs[0].args.diceResult >= 2;
        let test2 = result.logs[0].args.diceResult <= 12;
        let test = test1 && test2;
        assert.equal(test, true);
    })


})



        