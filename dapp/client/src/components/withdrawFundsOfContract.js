import React, { createRef } from 'react';
import TextField from '@material-ui/core/TextField';
import { Button } from "@material-ui/core";

function WithdrawFundsOfContract({web3, instance, nextStep}) {
  let address = createRef("");
  let amount = createRef(0);

  const withdrawCasinoBalance = async() => {
    try {
      const initialCasinoBalance = await instance.methods.getCasinoBalance().call({
        from: address.current.value
      });
      const res = await instance.methods.withdrawCasinoBalance(web3.utils.toWei(amount.current.value, 'ether')).send({
        from: address.current.value,
      });
      const newCasinoBalance = await instance.methods.getCasinoBalance().call({
        from: address.current.value
      });
      let amountReceived = (initialCasinoBalance - newCasinoBalance).toString();
      alert("Transaction state : " + res.status + "\n"
            + "You received from casino : " + web3.utils.fromWei(amountReceived, 'ether') + " ether");
      nextStep();
    } catch(err) {
      console.error(err);
      alert("The address isn't the Owner's address !");
    }
  }

  return (
      <form>

        <h1>Withdraw funds</h1>
        <p>Account address</p>
        <div>
          <TextField inputRef={address}/>
        </div>
        <p>Amount wanted</p>
        <div>
          <TextField inputRef={amount}/>
        </div>
    
        <Button onClick={withdrawCasinoBalance}>WITHDRAW</Button>

      </form>
  );
}

export default WithdrawFundsOfContract;
