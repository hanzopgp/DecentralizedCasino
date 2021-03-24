import React, { createRef } from 'react';
import TextField from '@material-ui/core/TextField';
import { Button } from "@material-ui/core";

function PlayGame({web3, instance, nextStep}) {
  let address = createRef("");

  const playGame = async() => {
    try {
      const res = await instance.methods.playGame().call({
        from: address.current.value
      });
      alert("Transaction state : " + res.status + "\n"
            + "Result : " + res + " number"
            + "You won : " + res + " casitokens");
      nextStep();
    } catch(err) {
      console.error(err);
      alert("Couldn't play ! Open console for infos.");
    }
  }

  return (
      <form>

        <h1>Bet game</h1>
        <p>Account address</p>
        <div>
          <TextField inputRef={address}/>
        </div>
    
        <Button onClick={playGame}>PLAY THE GAME</Button>

      </form>
  );
}

export default PlayGame;
