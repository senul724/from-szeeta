// ** Imports ** //

// * React * //
import React, { createContext, useState} from "react";

const GlobalContext = createContext();

const GlobalProvider = (props) => {

  const [siteData, setSiteData] = useState({
    initiated: false,
    theAccount: null,
    provider : null,
    network: null,
    balance: null,
  });

  return (

    <GlobalContext.Provider value={[siteData, setSiteData]}>
      {props.children}
    </GlobalContext.Provider>
  );
};


// ** Exports ** //
export { GlobalContext, GlobalProvider };
