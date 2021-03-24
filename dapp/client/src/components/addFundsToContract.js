import React, { createRef } from 'react';
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
      alert("Transaction refused ! Open console for infos.");
    }
  }

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
