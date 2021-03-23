import React, { createRef, useEffect } from 'react';
import TextField from '@material-ui/core/TextField';
import { Button } from "@material-ui/core";

function AddFundsToContract({instance, accounts, nextStep}) {
  let amount = createRef(0);
  let address = createRef("");

  const addFundsCasinoBalance = async() => {
    console.log("BUY")
    try {
      const res = await instance.methods.addFundsCasinoBalance().send({
        from: address.current.value,
        value: amount.current.value
      })
      nextStep()
    } catch(err) {
      console.error(err)
      alert("This is not the contract address' owner")
    }
  }
  
  return (
      <form>

        <h1> Add Funds to contract </h1>
        <p>Account onwer address'</p>
        <div>
          <TextField inputRef={address}/>
        </div>
        <p>TIPS: Account Owner: {accounts[0]}</p>

        <p>Amount</p>
        <div>
          <TextField  type="number" inputRef={amount}/>
        </div>
    
        <Button onClick={addFundsCasinoBalance}>BUY</Button>

      </form>
  );
}

export default AddFundsToContract;
