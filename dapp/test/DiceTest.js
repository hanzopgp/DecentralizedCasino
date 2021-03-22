const Casino = artifacts.require("Casino");
const utils = require("./util/utils");

contract("Dice", (accounts) => {
    let [a, b, c] = accounts;
    let casino;
    let amount = 10;
    let nBenchmark = 50;
    let oneToken = 1;
    let maxTokenAmount = 100;
    let moneyForMaxTokenAmount = (web3.utils.toWei("1", "ether")/10) * maxTokenAmount + 10;

    beforeEach(async () => {
        casino = await Casino.new({from: a});
        await casino.setGameType(1, {from: a});
        await casino.setGameType(1, {from: b});
        await casino.buyCasitokens(maxTokenAmount, {from: a, value : moneyForMaxTokenAmount});
    });

    //Dice game test
    it("should return that there's no bet", async () => {
        const result = await casino.isBetSetGame({from: a});
        assert.equal(result, false);
    })
    it("should set a bet", async () => {
        const result = await casino.betGame(" ", "6", oneToken, {from: a});
        const result2 = await casino.isBetSetGame({from: a});
        assert.equal(result2, true);
        assert.equal(result.logs[0].event, "EventBet");
        //assert.equal(result.logs[0].args.betValue, 6);
        //assert.equal(result.logs[0].args.isSet, true);
        //assert.equal(result.logs[0].args.tokenAmount, amount);
    })
    it("should cancel the bet", async () => {
        await casino.betGame(" ", "6", oneToken, {from: a});
        const result = await casino.isBetSetGame({from: a});
        assert.equal(result, true);
        const result2 = await casino.cancelBetGame({from: a});
        assert.equal(result2.logs[0].event, "EventCancelBet");
        const result3 = await casino.isBetSetGame({from: a});
        assert.equal(result3, false);
    })
    it("should play a game, return the result and the money earned and send the money to the player", async () => {
        await casino.addFundsCasinoBalance({from: a, value: 20*amount});
        // for(var bet = 2 ; bet <= 12 ; bet++){
            // var events = casino.allEvents({fromBlock: 0, toBlock: 'latest'});

            var nWin = 0;
            // var nEventWin = 0;
            // var nEvent = 0;
            // events.watch(function(err, res){
            //     if(err){
            //         console.log(err)
            //         return;
            //     }else{
            //         if(res == "EventResult"){
            //             nEvent++;
            //         }else if(res == "EventPlayerReceives"){
            //             nEventWin++
            //         }
            //     }
            // })
            for(var i = 0 ; i < nBenchmark ; i++){
                await casino.betGame(" ", 7, oneToken, {from: a});
                const result = await casino.playGame({from: a});
                //assert.equal(result.logs[0].event, "EventResult");
                if(amount != 0){ //C'est pas si amount != 0 mais si result.log[0].args.tokenWon
                    nWin++;
                    //assert.equal(result.logs[0].event, "EventPlayerReceives");
                }
            }
            //assert((nBenchmark - nBenchmark/20)/6 <= nWin && nWin <= (nBenchmark + nBenchmark/20)/6);
            const result2 = await casino.getCasinoBalance({from: a});
            //assert(result2 == (20-nWin*7+nBenchmark)*amount);
            // assert.equal(nWin, nEventWin);
            // assert.equal(nBenchmark, nEvent);
        // }
    })
    // it("playerReceivesMoney() test", async () => {
    //     await casino.bet(" ", "6", tokenAmount-1);
    //     await casino.play({from: a});
    //     const result = await casino.playerReceivesMoney({from: a});
    //     assert.equal(result.logs[0].event, "EventPlayerReceives");
        //assert.equal(result.logs[0].args.moneyWin, 60);
    // })
})



        
