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
        const result = await casino.isBetSet();
        assert.equal(result, false);
    })
    it("bet() test", async () => {
        await casino.setGameType(1, {from: accounts[0]});
        let result = await casino.bet(" ", "6", {from: accounts[0], value: 1000000});
        assert.equal(result.logs[0].event, "EventBet");
        //assert.equal(result.logs[0].event..diceBet, 6);
        //assert.equal(result.logs[0].args.isSet, true);
        //assert.equal(result.logs[0].args.moneyBet, 1000000);
    })
})



        