const Casino = artifacts.require("Casino");
const utils = require("./util/utils");

contract("Roulette", (accounts) => {
    let [a, b, c] = accounts;
    let casino;
    let amount = 10;
    let nBenchmark = 100;

    beforeEach(async () => {
        casino = await Casino.new({from: a});
        await casino.setGameType(2, {from: a});
        await casino.setGameType(2, {from: b});
    });

    //Dice game test
    it("should return that there's no bet", async () => {
        const result = await casino.isBetSetGame({from: a});
        assert.equal(result, false);
    })
    it("should set a bet", async () => {
        const result = await casino.betGame("Single", 6, {from: a, value: amount});
        const result2 = await casino.isBetSetGame({from: a});
        assert.equal(result2, true);
        assert.equal(result.logs[0].event, "EventBet");
    })
    it("should cancel the bet", async () => {
        await casino.betGame("Single", 6, {from: a, value: amount});
        const result = await casino.isBetSetGame({from: a});
        assert.equal(result, true);
        const result2 = await casino.cancelBetGame({from: a});
        assert.equal(result2.logs[0].event, "EventCancelBet");
        const result3 = await casino.isBetSetGame({from: a});
        assert.equal(result3, false);
    })
    it("should play a game, return the result and the money earned and send the money to the player", async () => {
        await casino.addFundsCasinoBalance({from: a, value: 70*amount});
        // for(var bet = 2 ; bet <= 12 ; bet++){
            var nWin = 0;
            for(var i = 0 ; i < nBenchmark ; i++){
                await casino.betGame("Single", 7, {from: a, value: amount});
                const result = await casino.playGame({from: a});
                if(amount != 0){
                    nWin++;
                    assert.equal(result.logs[0].event, "EventPlayerReceives");
                }
            }
            assert((nBenchmark - nBenchmark/20)/6 <= nWin && nWin <= (nBenchmark + nBenchmark/20)/6);
            const result = await casino.getCasinoBalance({from: a});
            assert(result == (20-nWin*37+nBenchmark)*amount);
        // }
    })
    // it("playerReceivesMoney() test", async () => {
    //     await casino.bet(" ", "6", {from: a, value: amount});
    //     await casino.play({from: a});
    //     const result = await casino.playerReceivesMoney({from: a});
    //     assert.equal(result.logs[0].event, "EventPlayerReceives");
        //assert.equal(result.logs[0].args.moneyWin, 60);
    // })
})



        
