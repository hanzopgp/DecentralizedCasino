import React, { useState, createRef, useEffect } from 'react';
import TextField from '@material-ui/core/TextField';
import { Button } from "@material-ui/core";

function AddFundsToContract({web3, instance, nextStep}) {
  let amount = createRef(0);
  let address = createRef("");

  const addFundsCasinoBalance = async() => {
    try {
      const initialCasinoBalance = await instance.methods.getCasinoBalance().call({
        from: address.current.value
      });
      const res = await instance.methods.addFundsCasinoBalance().send({
        from: address.current.value,
        value: web3.utils.toWei(amount.current.value, 'ether')
      });
      const newCasinoBalance = await instance.methods.getCasinoBalance().call({
        from: address.current.value
      });
      let amountSent = (newCasinoBalance - initialCasinoBalance).toString();
      alert("Transaction state : " + res.status + "\n"
            + "You sent to casino : " + web3.utils.fromWei(amountSent, 'ether') + " ether");
      nextStep();
    } catch(err) {
      console.error(err);
      alert("The address isn't the Owner's address !");
    }
  }

  // const withdrawCasinoBalance = async() => {
  //   try {
  //     const initialCasinoBalance = await instance.methods.getCasinoBalance().call({
  //       from: address.current.value
  //     });
  //     const res = await instance.methods.withdrawCasinoBalance(web3.utils.toWei(amount.current.value, 'ether')).send({
  //       from: address.current.value,
  //     });
  //     const newCasinoBalance = await instance.methods.getCasinoBalance().call({
  //       from: address.current.value
  //     });
  //     let amountReceived = (newCasinoBalance - initialCasinoBalance).toString();
  //     alert("Transaction state : " + res.status + "\n"
  //           + "You received from casino : " + web3.utils.fromWei(amountReceived, 'ether') + " ether");
  //     nextStep();
  //   } catch(err) {
  //     console.error(err);
  //     alert("The address isn't the Owner's address !");
  //   }
  // }

  // const buyCasitokens = async() => {
  //   try {
  //     const intialTokenBalance = await instance.methods.balanceOf(address.current.value).call({
  //       from: address.current.value //Ca sera Alice
  //     });
  //     const res = await instance.methods.buyCasitokens(/*nombre de tokens*/).send({
  //       from: address.current.value //Ca sera Alice
  //       value: web3.utils.toWei(amount.current.value, 'ether')
  //     });
  //     const newTokenBalance = await instance.methods.balanceOf(address.current.value).call({
  //       from: address.current.value //Ca sera Alice
  //     });
  //     let tokenReceived = (newTokenBalance - initialTokenBalance).toString();
  //     alert("Etat de la transaction : " + res.status + "\n"
  //           + "Vous avez recu : " + tokenReceived);
  //     nextStep();
  //   } catch(err) {
  //     console.error(err);
  //     alert(/*alert pas assez d'argent ou valeur token fausse*/);
  //   }
  // }

  // const setGameType = async() => {
  //   try {
  //     const res = await instance.methods.setGameType(/*le numero du jeu en entree suivant roulette ou dé*/).call({
  //       from: address.current.value //Ca sera Alice
  //     });
  //     alert("Etat de la transaction : " + res.status + "\n"
  //           + "Vous avez choisit le jeu : " + res);
  //     nextStep();
  //   } catch(err) {
  //     console.error(err);
  //     alert(/*alert le game type j'imagine*/);
  //   }
  // }
  
  // const betGame = async() => {
  //   try {
  //     const res = await instance.methods.betGame(/*le numero joué*/, /*le nombre de token joué*/).call({
  //       from: address.current.value //Ca sera Alice
  //     });
  //     alert("Etat de la transaction : " + res.status + "\n"
  //           + "Vous avez jouez le numero : " + res
  //           + "Vous avez parié : " + res + " casitokens");
  //     nextStep();
  //   } catch(err) {
  //     console.error(err);
  //     alert(/*alert jsp*/);
  //   }
  // }

  //   const playGame = async() => {
  //   try {
  //     const res = await instance.methods.playGame().call({
  //       from: address.current.value //Ca sera Alice
  //     });
  //     alert("Etat de la transaction : " + res.status + "\n"
  //           + "Le resultat est : " + res
  //           + "Vous avez gagne : " + res + " casitokens");
  //     nextStep();
  //   } catch(err) {
  //     console.error(err);
  //     alert(/*alert jsp*/);
  //   }
  // }

  return (
      <form>

        <h1> Add Funds to contract </h1>
        <p>Account address</p>
        <div>
          <TextField inputRef={address}/>
        </div>
        <p>Amount sent to fill contract</p>
        <div>
          <TextField  type="number" inputRef={amount}/>
        </div>
    
        <Button onClick={addFundsCasinoBalance}>Add funds to Casino balance</Button>

      </form>
  );
}

export default AddFundsToContract;
