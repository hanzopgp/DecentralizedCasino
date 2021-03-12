const Casino = artifacts.require("Casino");
const utils = require("./util/utils");
const playerNames = ["Player 1", "Player 2"];
contract("Casino", (accounts) => {
    let [a, b, c] = accounts;
    let casino;

    beforeEach(async () => {
        casino = await Casino.new();
    });


    it("setGameType() test", async () => {
        const result = await casino.setGameType(1, {from: accounts[1]});
        //assert.equal(String(result.receipt.from), String(accounts[0]));
        assert.equal(result.logs[0].event, "EventGameSet");
        assert.equal(result.logs[0].args.gameSet, true);
    })
    it("isBetSet() test", async () => {
        const result = await casino.isBetSet({from: accounts[1]});
        assert.equal(result, false);
    })


    // it("isBetSet() should return false since there is no bet", async () => {
    //     const result = await casino.isBetSet({from: accounts[0]});
    //     assert.equal(result, false);
    // })
    // it("isBetSet() should return true since there is a new bet", async () => {
    // 	await casino.getNewBet(6, {from: accounts[0], value: 500000000000000000});
    //     const result = await casino.isBetSet({from: accounts[0]});
    //     assert.equal(result, true);
    // })


    // it("getNewBet() should emit a EventNewBet", async () => {
  		// const result = await casino.getNewBet(6, {from: accounts[0], value: 500000000000000000});
    //     assert.equal(result.logs[0].event, "EventNewBet");
    // })
    // it("getNewBet() should return the bet value", async () => {
    //     const result = await casino.getNewBet(6, {from: accounts[0], value: 500000000000000000});
    //     assert.equal(result.logs[0].args.currentBet, 6);
        
    // })
    // it("getNewBet() should return isSet as true", async () => {
    //     const result = await casino.getNewBet(6, {from: accounts[0], value: 500000000000000000});
    //     assert.equal(result.logs[0].args.isSet, true);
        
    // })
    // it("getNewBet() should return the money value", async () => {
    //     const result = await casino.getNewBet(6, {from: accounts[0], value: 500000000000000000});
    //     assert.equal(result.logs[0].args.moneyBet, 500000000000000000);
    // })


    // it("cancelBet() should emit a EventCancelBet", async () => {
  		// const result = await casino.cancelBet();
    //     assert.equal(result.logs[0].event, "EventCancelBet");
    // })
    // it("cancelBet() should return the bet value", async () => {
  		// const result = await contractInstance.cancelBet();
    //     assert.equal(result.logs[0].args.currentBet, 6);
        
    // })
    // it("cancelBet() should return isSet as true", async () => {
  		// const result = await casino.cancelBet();
    //     assert.equal(result.logs[0].args.isSet, true);
        
    // })
    // it("cancelBet() should return the money value", async () => {
  		// const result = await casino.cancelBet();
    //     assert.equal(result.logs[0].args.moneyBet, 500000000000000000);
    // })


    // it("playDice() should emit a EventGameResult", async () => {
    // 	await casino.getNewBet(6, {from: accounts[0], value: 500000000000000000});
    //     const result = await casino.playDice();
    //     result.logs[0].event = "EventGameResult";
    // })
    // it("playDice() should return the player address", async () => {
    // 	await casino.getNewBet(6, {from: accounts[0], value: 500000000000000000});
    //     const result = await casino.playDice();
    //     assert.equal(result.logs[0].args.player, accounts[0]);
    // })
    // it("playDice() should return the player bet value", async () => {
    // 	await casino.getNewBet(6, {from: accounts[0], value: 500000000000000000});
    //     const result = await casino.playDice();
    //     assert.equal(result.logs[0].args.currentBet, 6);
    // })
    // it("playDice() should return the result of the dice", async () => {
    // 	await casino.getNewBet(6, {from: accounts[0], value: 500000000000000000});
    //     const result = await casino.playDice();
    //     let test1 = result.logs[0].args.diceResult >= 2;
    //     let test2 = result.logs[0].args.diceResult <= 12;
    //     let test = test1 && test2;
    //     assert.equal(test, true);
    // })


})



        