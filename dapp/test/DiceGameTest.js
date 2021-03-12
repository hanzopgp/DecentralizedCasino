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
        const result = await casino.setGameType(1, {from: accounts[0]});
        //assert.equal(String(result.receipt.from), String(accounts[0]));
        assert.equal(result.logs[0].event, "EventGameSet");
        assert.equal(result.logs[0].args.gameSet, true);
    })
    it("isBetSet() test", async () => {
        await casino.setGameType(1, {from: accounts[0]});
        const result = await casino.isBetSet({from: accounts[0]});
        assert.equal(result, false);
    })
    it("cancelBet() test", async () => {
        await casino.setGameType(1, {from: accounts[0]});
        await casino.bet(" ", "6", {from: accounts[0], value: 1000000});
        const result = await casino.isBetSet({from: accounts[0]});
        assert.equal(result, true);
        const result2 = await casino.cancelBet({from: accounts[0]});
        assert.equal(result2.logs[0].event, "EventCancelBet");
        const result3 = await casino.isBetSet({from: accounts[0]});
        assert.equal(result3, false);
    })
    it("bet() test", async () => {
        await casino.setGameType(1, {from: accounts[0]});
        const result = await casino.bet(" ", "6", {from: accounts[0], value: 1000000});
        const result2 = await casino.isBetSet({from: accounts[0]});
        assert.equal(result2, true);
        assert.equal(result.logs[0].event, "EventBet");
        //assert.equal(result.logs[0].args.betValue, 6);
        //assert.equal(result.logs[0].args.isSet, true);
        //assert.equal(result.logs[0].args.moneyBet, 1000000);
    })
    it("play() test", async () => {
        await casino.setGameType(1, {from: accounts[0]});
        await casino.bet(" ", "6", {from: accounts[0], value: 1000000});
        const result = await casino.play({from: accounts[0]});
        assert.equal(result.logs[0].event, "EventResult");
        //assert.equal(result.logs[0].args.betValue, 6);
    })
    it("playerReceivesMoney() test", async () => {
        await casino.setGameType(1, {from: accounts[0]});
        await casino.bet(" ", "6", {from: accounts[0], value: 1000000});
        await casino.play({from: accounts[0]});
        const result = await casino.playerReceivesMoney({from: accounts[0]});
        assert.equal(result.logs[0].event, "EventPlayerReceives");
        //assert.equal(result.logs[0].args.moneyWin, 60);
    })
})



        