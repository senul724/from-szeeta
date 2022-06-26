// ** Imports ** //
import React, { useContext, useState } from 'react';

// ** Custom Components ** //
import { Contract } from 'ethers';
import { GlobalContext } from '../context/GlobalContext';
import { abi } from './abis/abis';

const Event = ({address}) => {

    const [siteData] = useContext(GlobalContext);
    const [state, setstate] = useState({});
    const get = async() =>{

        let instance = new Contract(address, abi.ticketGet);
        let Name = await instance.name();
        let Total = await instance.maxSupply();
        let used = await instance.mintCounter();
        let Available = Total-used;
        let Start = await instance.startTime();
        let End = await instance.endTime();
        let bal = await instance.balanceOf(siteData.theAccount);

        setstate({
            name:Name,
            total:Total,
            available:Available,
            start:Start,
            end:End,
            balance:bal
        })
        
    }

    useEffect(() => {
        get();
    }, [siteData]);

    return (
        <>
        {siteData.initiated?
        <div>
            <h1>{state.name}</h1>
            <img alt = {`event banner of ${state.name}`} src = {}/>
            <h2>Start time: {state.start}</h2>
            <h2>End time: {state.end}</h2>
            <h2>Your tickets : {state.balance}</h2>
            <h2>Available tickets : {state.available}</h2>
            <h2>Total tickets : {state.total}</h2>

        </div>:
        <h1>Connect your wallet to veiw data</h1>}
        </>
    )
}

// * Exports * //
export { Event };
