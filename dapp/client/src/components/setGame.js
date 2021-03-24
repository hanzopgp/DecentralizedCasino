import React, { createRef } from 'react';
import TextField from '@material-ui/core/TextField';
import { Button } from "@material-ui/core";

function setGame({nextStep, instance}) {
  let address = createRef("");

  const setGameType = async(gameType) => {
    try {
      const res = await instance.methods
        .setGameType(gameType)
        .call({
          from: address.current.value
      });
      console.log(res)
      alert("Transaction state : "
            + res
            + "\n"
            + "You chosed : "
            + (gameType ===  1 ? "Dice" : "Roulette")
            + " game");
      nextStep();
    } catch(err) {
      console.error(err);
      alert("Can't set game type ! Open console for infos.");
    }
  }

  return (
  <form>
    <h1>Set game</h1>
    <p>Account address</p>
    <div>
      <TextField inputRef={address}/>
    </div>
    <p>Wich game ?</p>
    <div>
      <Button onClick={() => setGameType(1)}>SET DICE GAME</Button>
    </div>
    <div>
      <Button onClick={() => setGameType(2)}>SET ROULETTE GAME</Button>
    </div>
  </form>
  );
}

export default setGame;
