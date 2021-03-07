App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',
  hasVoted: false,

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    // TODO: refactor conditional
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("Dice.json", function(dice) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.Dice = TruffleContract(dice);
      // Connect provider to interact with contract
      App.contracts.Dice.setProvider(App.web3Provider);

      App.listenForEvents();

      return App.render();
    });
  },

  // Listen for events emitted from the contract
  listenForEvents: function() {
    App.contracts.Dice.deployed().then(function(instance) {
      // Restart Chrome if you are unable to receive this event
      // This is a known issue with Metamask
      // https://github.com/MetaMask/metamask-extension/issues/2393
      instance.GameResult({}, {}).watch(function(error, event) {
        console.log("event triggered", event)
        // Reload when a new vote is recorded
        App.render(event);
      });

      instance.NewBetIsSet({}, {}).watch(function(error, event) {
        console.log("event triggered", event)
        // Reload when a new vote is recorded
        App.render(event);
      });

    });
  },

  render: function(event) {
    var gameInstance;
    // Load account data
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account : " + account );
      }
    });

    if(event.event == "NewBetIsSet"){
    $("#newBet")
      .text("Your target is : " + event.args.currentBet.toNumber());
    }

    if(event.event == "GameResult") {
        var destiny = event.args.destiny.toNumber();
      var currentBet = event.args.currentBet.toNumber();
      var doWeHaveAWinner = (destiny == currentBet);
      if(doWeHaveAWinner){
          $("#result").text("we have a winner");
      }else{
          $("#result").text("Sorry bad luck, your got " + destiny);
      }
    }

    // Load contract data
    App.contracts.Dice.deployed().then(function(instance) {
      gameInstance = instance;
      return gameInstance.isBetSet();
    }).then(function(isBetSet) {
      var message = $("#message");
      if(isBetSet){
        message.text('Bet is Set, Roll the Dice')
      }else{
      message.text('Set New Bet');
    }
    }).catch(function(error) {
      console.warn(error);
    });
  },

   roll : function(){
    App.contracts.Dice.deployed().then(function(instance) {
      return instance.roll({ from: App.account });
    }).then(function(result) {
      //set bet value

      // var destiny = result.logs[0].args.destiny.toNumber();
      // var currentBet = result.logs[0].args.currentBet.toNumber();
      // var doWeHaveAWinner = (destiny == currentBet);
      // if(doWeHaveAWinner){
      //     $("#result").text("we have a winner");
      // }else{
      //     $("#result").text("Sorry bad luck, your got " + destiny);
      // }
    }).catch(function(err) {
      console.error(err);
    });
  },

   getNewBet: function() {
    $("#result").text("");
    App.contracts.Dice.deployed().then(function(instance) {
      return instance.getNewbet({ from: App.account });
    }).then(function(result) {
      //set bet value
      $("#newBet").text("Your target is : " + result.logs[0].args.currentBet.toNumber());//make it visible
    }).catch(function(err) {
      console.error(err);
    });
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});