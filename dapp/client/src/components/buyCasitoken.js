import React, { useState, createRef, useEffect } from 'react';
import TextField from '@material-ui/core/TextField';
import { Button } from "@material-ui/core";
import Casitoken from "../contracts/Casitoken.json";

function BuyCasitoken({web3, instance, accounts, nextStep}) {
  let tokenAmount = createRef(0);
  let money = createRef(0);
  let address = createRef("");

  const buyCasitokens = async() => {
    try {
  		const initialTokenBalance = instance.methods.getNbTokensOf().call({
  				from: address.current.value 
  			});
      console.log(initialTokenBalance);
  		const res = await instance.methods.buyCasitokens(parseInt(tokenAmount.current.value)).send({
  			from: address.current.value, 
  			value: web3.utils.toWei(money.current.value, 'ether')
  		});
  		const newTokenBalance = await instance.methods.getNbTokensOf().call({
  			from: address.current.value 
  		});
  		let tokenReceived = (newTokenBalance - initialTokenBalance).toString();
  		alert("Etat de la transaction : " + res.status + "\n"
  		    + "Vous avez recu : " + res);
  		nextStep();
	} catch(err) {
	console.error(err);
	alert(/*alert pas assez d'argent ou valeur token fausse*/);
	}
  }

  return (
      <form>

        <h1> Add Funds to contract </h1>
        <p>Account address</p>
        <div>
          <TextField inputRef={address}/>
        </div>
        <p>Amount sent to buy tokens (e.g : 10 ether)</p>
        <div>
          <TextField  type="number" inputRef={money}/>
        </div>
        <p>Amount of tokens wanted (e.g : 100 token)</p>
        <div>
          <TextField type="number" inputRef={tokenAmount}/>
        </div>
    
        <Button onClick={buyCasitokens}>Add funds to Casino balance</Button>

      </form>
  );
}

export default BuyCasitoken;
