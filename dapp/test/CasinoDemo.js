const Casino = artifacts.require("Casino");
const utils = require("./util/utils");

contract("Casino", (accounts) => {
    let [a, b, c] = accounts;
    let casino;
    let amount = 10;
    let oneToken = 1;
    let maxTokenAmount = 100;
    let moneyForMaxTokenAmount = (web3.utils.toWei("1", "ether")/10) * maxTokenAmount + 10;

    console.log("hello");

});
