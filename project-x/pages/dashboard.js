// ** Imports ** //

// * React * //
import React, { useState , useEffect, useContext} from 'react'

// * Custom Components * //
import { GlobalContext } from '../context/GlobalContext'
import { abi, addresses } from '../components/abis/abis.js';
import { Contract } from "ethers";

const Dash = () => {
    const [siteData] = useContext(GlobalContext);
    const [eventList, setEventList] = useState([]);
    const [ticketList, setTicketList] = useState([]);
    const [initiated, setState] = useState(false);

    const getEventData = async() =>{
        let instance = new Contract(addresses.factory[5777], abi.factoryGet, siteData.provider);
        let list = await instance.getUserEvents(siteData.theAccount);
        setEventList(list);
    }
    const getTicketData = async()=>{
        let instance = new Contract(addresses.factory[5777], abi.factoryGet, siteData.provider);
        let list = await instance.getBuyerTickets(siteData.theAccount);
        setTicketList(list);

    }

    useEffect(() => {
        if(siteData.initiated){
            getEventData();
            getTicketData();
            setState(true);
        }else{
            setState(false);
        }
    }, [siteData])
    
    return (
        <div>
            <h1>Dash Board</h1>
            {initiated?<></>:
            <h2>Connect to wallet to view data</h2>}
        </div>
    )
}

// ** Exports ** //
// exported as default so the router can identify the page
export default Dash;
