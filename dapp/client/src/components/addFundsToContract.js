import React, { useState, createRef, useEffect } from 'react';
import TextField from '@material-ui/core/TextField';
import { Button } from "@material-ui/core";

function AddFundsToContract({web3, instance, accounts, nextStep}) {
  let amount = createRef(0);
  let address = createRef("");

  const [balanceOwner, setBalanceOwner] = useState(0);
  const [balanceAlice, setBalanceAlice] = useState(0);
  const [balanceBob, setBalanceBob] = useState(0);

  useEffect(() => {
    (async () => {
      const balanceOwner = web3.utils.fromWei((await web3.eth.getBalance(accounts[0])), 'ether');
      setBalanceOwner(balanceOwner);
      const balanceAlice = web3.utils.fromWei((await web3.eth.getBalance(accounts[1])), 'ether');
      setBalanceAlice(balanceAlice);
      const balanceBob = web3.utils.fromWei((await web3.eth.getBalance(accounts[2])), 'ether'); 
      setBalanceBob(balanceBob);
    })()
  }, [])

  const addFundsCasinoBalance = async() => {
    try {
      const res = await instance.methods.addFundsCasinoBalance().send({
        from: address.current.value,
        value: web3.utils.toWei(amount.current.value, 'ether')
      });
      const newCasinoBalance = await instance.methods.getCasinoBalance().call({
        from: address.current.value
      });
      alert("Etat de la transaction : " + res.status + "\n"
            + "Montant sur le contract Casino : " + web3.utils.fromWei(newCasinoBalance, 'ether'));
      nextStep();
    } catch(err) {
      console.error(err);
      alert("The address isn't the Owner's address !");
    }
  }
  
  return (
      <form>

        <h1> Add Funds to contract </h1>
        <p>Account address</p>
        <div>
          <TextField inputRef={address}/>
        </div>
          <p>Owner address: {accounts[0]}, Wallet balance: {Number.parseFloat(balanceOwner).toFixed(4)} ether</p>
          <p>Alice address: {accounts[1]}, Wallet balance: {Number.parseFloat(balanceAlice).toFixed(4)} ether</p>
          <p>Bob address: {accounts[2]}, Wallet balance: {Number.parseFloat(balanceBob).toFixed(4)} ether</p>

        <p>Amount sent to fill contract</p>
        <div>
          <TextField  type="number" inputRef={amount}/>
        </div>
    
        <Button onClick={addFundsCasinoBalance}>Add funds to Casino balance</Button>

      </form>
  );
}

export default AddFundsToContract;
