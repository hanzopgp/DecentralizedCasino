import React, { createRef, useEffect } from 'react';
import TextField from '@material-ui/core/TextField';
import { Button } from "@material-ui/core";

function setGame({nextStep, instance}) {
  let address = createRef("");

  const setGameType = async(gameType) => {
    try {
      const res = await instance.methods
        .setGameType(gameType)
        .call({
          from: address.current.value //Ca sera Alice
      });
      console.log(res)
      alert("Etat de la transaction : "
            + res
            + "\n"
            + "Vous avez choisit le jeu : "
            + (gameType ===  1 ? "Dice" : "Roulette")
            + " game");
      nextStep();
    } catch(err) {
      console.error(err);
      alert(/*alert le game type j'imagine*/);
    }
  }

  return (
  <form>
    <h1> Set game </h1>
    <p>Account address</p>
    <div>
      <TextField inputRef={address}/>
    </div>
    <p>Wich game ?</p>
    <div>
      <Button onClick={() => setGameType(1)}>Dice game</Button>
    </div>
    <div>
      <Button onClick={() => setGameType(2)}>Roulette game</Button>
    </div>
  </form>
  );
}

export default setGame;
