import React, { useState, useEffect } from 'react';

import Casino from "./contracts/Casino.json";
import getWeb3 from "./getWeb3";

import AddFundsToContract from './components/addFundsToContract';
import SetGame from './components/setGame';
import BuyCasitoken from './components/buyCasitoken';
import BetGame from './components/betGame';
import PlayGame from './components/playGame';
import WithdrawFundsOfContract from './components/withdrawFundsOfContract';

import "./App.css";
import "./tailwind.output.css";

import { Button, Divider } from '@material-ui/core';

function App() {
  const stepNames = [
    'ADD_FUNDS',
    'SET_GAME',
    'BUY_TOKEN',
    'BET',
    'PLAY',
    'WITHDRAW_FUNDS',
  ]

  const stepComponents = {
    'ADD_FUNDS': () => (<AddFundsToContract { ...{web3, instance, accounts, nextStep} } />),
    'SET_GAME': () => (<SetGame { ...{web3, instance, accounts, nextStep} } />),
    'BUY_TOKEN': () => (<BuyCasitoken { ...{web3, instance, accounts, nextStep} } />),
    'BET': () => (<BetGame { ...{web3, instance, accounts, nextStep} } />),
    'PLAY': () => (<PlayGame { ...{web3, instance, accounts, nextStep} } />),
    'WITHDRAW_FUNDS': () => (<WithdrawFundsOfContract { ...{web3, instance, accounts, nextStep} } />),
  }

  const [web3, setWeb3] = useState(null);
  const [accounts, setAccounts] = useState(null);
  const [instance, setInstance] = useState(null);
  const [actualStepIndex, setActualStepIndex] = useState(0);
  const [accountsInfo, setAccountsInfo] = useState(null);

  const nextStep = () => {
    if(actualStepIndex + 1 >= stepComponents.length){
      setActualStepIndex(actualStepIndex + 1);
    }else{
      setActualStepIndex(0);
    }
  }

  const stepBack = () => {
    if (actualStepIndex > 0) {
      setActualStepIndex(actualStepIndex - 1);
    }
  }

  const goToStep = (ind) => {
    setActualStepIndex(ind);
  }

  useEffect(() => {
    (async () => {
      try {

        let web3 = await getWeb3();
        setWeb3(web3);

        let accounts = await web3.eth.getAccounts();
        setAccounts(accounts);

        const networkId = await web3.eth.net.getId();
        const deployedNetwork = Casino.networks[networkId];
       
        setInstance(new web3.eth.Contract(
          Casino.abi,
          deployedNetwork && deployedNetwork.address,
        ));

        let accountsInfo = await Promise.all(accounts.map(async (account) => {
          return {
            account,
            balance: web3.utils.fromWei((await web3.eth.getBalance(account)), 'ether')
          }
        }))
        setAccountsInfo(accountsInfo)

      } catch (error) {
        alert("Failed to load web3, accounts, or contract ! Check console for details.");
        console.error(error);
      }
    })()
  }, [])

  if (!instance) {
        return <div className="text-5xl h-screen flex justify-center align-center m-auto items-center bg-red-400">Loading Web3, accounts, and contract...</div>;
  }
  return (
    <div className="App h-full w-full flex justify-center align-center bg-gray-100">

      <div className="w-2/3 h-full">
        <div className="font-bold p-4 text-3xl">
          CASINO
          <svg height="210" width="100" id="ethereum_logo">    
            <polygon points="50,10 0,110 50,130 100,110" id="base_left"/>
            <polygon points="50,10 50,130 50,130 100,110" id="base_right"/>
            <polygon points="50,130 0,110 50,70 100,110" id="base_bottom_left"/>
            <polygon points="50,130 50,110 50,70 100,110" id="base_bottom_right"/>
            
            <polygon points="50,170 0,120 50,140 100,120" id="bottom_left"/>
            <polygon points="50,170 50,120 50,140 100,120" id="bottom_right"/>
          </svg>
        </div>
        <div className="bg-white w-2/4 p-3 rounded-lg form">
          {stepComponents[stepNames[actualStepIndex]]()}
          <Button onClick={stepBack}>Back</Button>
        </div>
      </div>

      <div className="bg-black text-white w-1/3 h-full overflow-y-auto"> 
        {/* {navigateToAllSteps} */}
        {
        stepNames.map((name, index) => {
          return (
            <div className="bg-white w-full" key={index}>
              {index !== 0 && <Divider/>}
              <Button onClick={() => goToStep(index)}>{name}</Button>
            </div>
          )})
        }
        {accountsInfo &&
        accountsInfo.map(({account, balance}, index) => {
          return (
            <div key={index}>
              {index !== 0 && <Divider/>}
              <p>{index === 0 ? "Owner address" : "Account " + index}</p>
              <p>{account}</p>
              <p>Wallet balance: {Number.parseFloat(balance).toFixed(4)} ether</p>
            </div>
          )})
        }
      </div>

    </div>
  );
}

export default App;
