const Casino = artifacts.require("Casino");
const utils = require("./util/utils");

contract("Casino", (accounts) => {
    let [Alice, Bob, Administrator] = accounts;
    let casino;

    let amount = 10;
    let oneToken = 1;
    let maxTokenAmount = 100;
    let moneyForMaxTokenAmount = (web3.utils.toWei("1", "ether")/10) * maxTokenAmount + 10;

    let dice = 1;
    let roulette = 2;

    let currentUser = "Null";

    async function demo(){
    	console.log("===Debut de la demonstration===");

    	console.log("1) Administration :")
	    currentUser = "Administrator";
	    console.log(formatOutput("-->Vous deployez votre casino sur la blockchain", currentUser));
	    console.log(await Casino.new({from : Administrator})); //Creation du casino par l'administrateur
	    console.log(formatOutput("-->Vous voulez ajouter des fonds sur votre casino", currentUser));
	    const fundsReceivedFromAdmin = await casino.addFundsCasinoBalance({from: Administrator, value: amount*100});
        console.log(formatOutput("-->Le casino vient de recevoir " + fundsReceives, currentUser));
        console.log(formatOutput("-->Vous voulez recuperer l'argent qu'il y a sur le casino ", currentUser));
        const fundsReceivedFromCasino = await casino.withdrawCasinoBalance(amount*50, {from: Administrator});
        console.log(formatOutput("-->Vous avez recuperer " + fundsReceivedFromCasino, currentUser));

        console.log("2) Alice joue a la roulette :");
        currentUser = "Alice";
        console.log(formatOutput("-->Vous achetez 50 jetons", currentUser));
        const numberOfTokensBought = await casino.buyCasitokens(maxTokenAmount, {from: Alice, value : moneyForMaxTokenAmount});
        console.log(formatOutput("-->Vous avez recu " + numberOfTokensBought + " jetons", currentUser));
        console.log(formatOutput("-->Vous choisissez le jeu de la roulette", currentUser));
        const gameTypeSet = await casino.setGameType(roulette, {from: Alice});
        console.log(formatOutput("-->Vous avez choisit le jeu numero " + gameTypeSet, currentUser));
        console.log(formatOutput("-->Vous voulez jouer 10 jetons sur le numero 6 ", currentUser));
        const bet = await casino.betGame("Single", 6, oneToken*10, {from: Alice});
        console.log(formatOutput("-->Vous avez fait le paris suivant : " + bet, currentUser));
        console.log(formatOutput("-->Vous lancez donc la partie", currentUser));
        const result = await casino.playGame({from: Alice});
        console.log(formatOutput("-->Le resultat de la partie est " + result, currentUser));
        console.log(formatOutput("-->Vous avez gagne " + result, currentUser));

        console.log("3) Bob joue aux des :");

        console.log("===Fin de la demonstration===");
    }

    demo();
    
    function formatOutput(msg, user){
    	return msg + getCurrentUserString(user);
    }

    function getCurrentUserString(currentUser){
    	return " | Vous êtes : [" + currentUser + "]";
    }

});
