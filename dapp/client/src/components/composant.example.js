import React, { createRef, useEffect } from 'react';
import TextField from '@material-ui/core/TextField';
import { Button } from "@material-ui/core";

function example( { nextStep } ) {

  return (
      <form>
        {nextStep}
      </form>
  );
}

export default example;
