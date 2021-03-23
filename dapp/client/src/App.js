import React, { useState, useEffect } from 'react';
import Casino from "./contracts/Casino.json";
import getWeb3 from "./getWeb3";
import AddFundsToContract from './components/addFundsToContract';
import "./App.css";

function App() {
  const stepNames = [
    'ADD_FUNDS',
    'WITHDRAW_FUNDS',
    'SET_GAME',
    'BUY_TOKEN',
    'BET',
    'PLAY',
  ]

  const stepComponents = {
    'ADD_FUNDS': () => (<AddFundsToContract { ...{instance, accounts, nextStep} } />),
    'WITHDRAW_FUNDS': () => {},
    'SET_GAME': () => {},
    'BUY_TOKEN': () => {},
    'BET': () => {},
    'PLAY': () => {},
  }

  const [web3, setWeb3] = useState(null);
  const [accounts, setAccounts] = useState(null);
  const [instance, setInstance] = useState(null);
  const [actualStepIndex, setActualStepIndex] = useState(0);

  const nextStep = () => {
    setActualStepIndex(actualStepIndex++)
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
      } catch (error) {
        alert(
          `Failed to load web3, accounts, or contract. Check console for details.`,
        );
        console.error(error);
      }
    })()
  }, [])

  if (!instance) {
    return <div>Loading Web3, accounts, and contract...</div>;
  }
  return (
    <div className="App">
      {stepComponents[stepNames[actualStepIndex]]()}
    </div>
  );
}

export default App;
