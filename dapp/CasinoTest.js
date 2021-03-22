const Casino = artifacts.require("Casino");
const utils = require("./util/utils");
console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");console.log("test");
console.log("test");
contract("Casino", (accounts) => {
    let [a, b, c] = accounts;
    let casino;
    let amount = 10;
    let oneToken = 1;
    let maxTokenAmount = 100;
    let moneyForMaxTokenAmount = (web3.utils.toWei("1", "ether")/10) * maxTokenAmount + 10;

    beforeEach(async () => {
        casino = await Casino.new({from: a});
    });
    
    it("should initialize with no game", async () => {
        utils.shouldThrow(casino.betGame("", 7, oneToken));
        utils.shouldThrow(casino.betGame("", 7, oneToken));
    })
    it("should set the game", async () => {
        const result = await casino.setGameType(1, {from: a});
        assert.equal(result.logs[0].event, "EventGameSet");
        utils.shouldThrow(casino.betGame("", 7, 1, {from: b}));
        const result2 = await casino.setGameType(1, {from: b});
        assert.equal(result2.logs[0].event, "EventGameSet");
    })
    it("should buy tokens", async () => {
        const result = await casino.buyCasitokens(maxTokenAmount, {from: a, value: moneyForMaxTokenAmount});
        //assert.equal(result, maxTokenAmount);
        assert.equal(result.logs[0].event, "EventTokenBought");
    })
    //Admin function test
    it("should add funds to casino balance", async () => {
        const result = await casino.addFundsCasinoBalance({from: a, value: amount});
        assert(result.receipt.status);
        const result2 = await casino.getCasinoBalance({from: a});
        assert.equal(result2, amount);
    })
    it("should return casino balance", async () => {
        const result = await casino.getCasinoBalance({from: a});
        assert.equal(result, 0);
        await casino.addFundsCasinoBalance({from: a, value: amount});
        const result2 = await casino.getCasinoBalance({from: a});
        assert.equal(result2, amount);
    })
    it("should withdraw casino balance", async () => {
        await casino.addFundsCasinoBalance({from: a, value: amount});
        const result = await casino.withdrawCasinoBalance(amount, {from: a});
        assert(result.receipt.status);
        const result2 = await casino.getCasinoBalance({from: a});
        assert.equal(result2, 0);
    })
    it("should allow only the owner to add, withdraw or get casino balance", async () => {
        utils.shouldThrow(casino.addFundsCasinoBalance({from: b, value: amount}));
        await casino.addFundsCasinoBalance({from: a, value: amount});
        utils.shouldThrow(casino.withdrawCasinoBalance(amount, {from: b}));
        utils.shouldThrow(casino.getCasinoBalance({from: b}));
        const result = await casino.getCasinoBalance({from: a});
        assert.equal(result, amount);
    })

});
