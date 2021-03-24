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
    if(actualStepIndex + 1 > stepComponents.length){
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
        alert(
          `Failed to load web3, accounts, or contract ! Check console for details.`,
        );
        console.error(error);
      }
    })()
  }, [])

  if (!instance) {
    return <div>Loading Web3, accounts, and contract...</div>;
  }
  return (
    <div className="App h-full w-full flex justify-center align-center bg-green-200">

      <div className="w-2/3 h-full">
        {stepComponents[stepNames[actualStepIndex]]()}
        <Button onClick={stepBack}>Back</Button>
      </div>

      <div className="bg-gray-400 w-1/3 max-h-full overflow-y-auto"> 
        {/* {navigateToAllSteps} */}
        {
        stepNames.map((name, index) => {
          return (
            <div className="bg-blue-400 w-full" key={index}>
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
