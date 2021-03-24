import React, { createRef } from 'react';
import TextField from '@material-ui/core/TextField';
import { Button } from "@material-ui/core";

function BetGame({web3, instance, nextStep}) {
  let address = createRef("");
  let betValue = createRef(0);
  let tokenAmount = createRef(0);

  const betGame = async() => {
    try {
      const res = await instance.methods.betGame("", betValue.current.value, tokenAmount.current.value).call({
        from: address.current.value
      });
      alert("Transaction state : " + res.status + "\n"
            + "Your bet : " + res + " number"
            + "You bet : " + res + " casitokens");
      nextStep();
    } catch(err) {
      console.error(err);
      alert("Bet refused ! Open console for infos.");
    }
  }

  return (
      <form>

        <h1>Bet game</h1>
        <p>Account address</p>
        <div>
          <TextField inputRef={address}/>
        </div>
        <p>Bet you want to do</p>
        <div>
          <TextField  type="number" inputRef={betValue}/>
        </div>
        <p>Amount of token bet</p>
        <div>
          <TextField  type="number" inputRef={tokenAmount}/>
        </div>
    
        <Button onClick={betGame}>PLACE YOUR BET</Button>

      </form>
  );
}

export default BetGame;
