// ** Imports ** //
import React,{useContext} from 'react'

// * Custom Components * //
import { GlobalContext } from '../context/GlobalContext'
import { providers } from 'ethers';

const Connect = () => {
    const[siteData, setSiteData] = useContext(GlobalContext);
    const get = async()=>{
        if(window.ethereum){
            window.ethereum.enable();
            let provider = new providers.Web3Provider(window.ethereum);

        }
    }
    return (
        <div>
           {siteData.initiated ? <></>:
           <button
            onClick = {() => get()}
           >Connect Wallet</button>} 
        </div>
    )
}

// ** Exports ** //
export { Connect };
