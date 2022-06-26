// ** Imports ** //
import React,{useContext, useState, useEffect} from 'react'

// * Ethers * //
import { Contract } from 'ethers'

// * Custom Imports * //
import { GlobalContext } from '../context/GlobalContext'
import { Card } from "./utils/Card";
import { abi, addresses } from './abis/abis';

const Events = () => {

    const [siteData] = useContext(GlobalContext);
    const [list, setList] = useState([]);

    const redirect =()=>{
        // add the page of the specific event here
    }
    let provider = siteData.provider;
    
    let instance = new Contract(addresses.factory, abi.factoryGet, provider);
   
    useEffect(async() => {
        let list_ = await instance.getEventAddresses();
        setList(list_)
    }, [siteData]);

    return (
        <div>
            {list!=[]?
            list.map(async(address) =>{
                let subInstance = new Contract(address, abi.ticketGet, provider);
                let name = await subInstance.name();
                let uri = await subInstance.tokenURI();
                let url = uri //add the gateway for the ipfs uri here
                return(<Card Src = {url} Name = {name} Alt ={`event ${name}`} Func = {redirect()}/>);
            }):<></>} 
        </div>
    )
}


// ** Exports ** //
export { Events };
