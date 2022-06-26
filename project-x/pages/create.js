// ** Imports ** //

// * React * //
import { useState } from 'react';

// * Ethers * //
import { ethers , providers} from 'ethers';

// * Custom Components * //
import { Field } from "../components/utils/Field";
import { abi, addresses } from '../components/abis/abis';


const EventMaker = () => {
    // 2015-03-25T12:00:00Z
    let initialState = {
        owner: "",
        org:"",
        name: "",
        symbol: "",
        ipfsHash: "",
        supply: 0,
        maxMint: 0,
        priceInWei: 0,
        fee: 0,
        id: 0,
        duration:{
            start:{
                date:"",
                time:""
            },
            end:{
                date:"",
                time:""
            }
        }
    }

    const [state, setState] = useState(initialState);
    const addEvent = async () => {
        if(state.owner !== ""){
            // Executing event creation function
            let provider = new providers.Web3Provider(window.ethereum); //add your rpc url here or leave it to join with metamask.
            let signer = provider.signer;
            let instance = new ethers.Contract(addresses.factory['5777'], abi.factorySet, signer);
            await instance.addEvent(
                state.owner,
                state.org,
                [state.name, state.symbol],
                state.ipfsHash,
                state.supply,
                state.maxMint,
                state.priceInWei,
                // startTime,
                // endTime,
                )
        }
    } 

    return (
        <div style = {{textAlign: "center"}}>
            <h1 className='text-center mt-20 font-bold text-5xl'>Create your Events with Project-x</h1>

            <br/><br/>
            <Field Name="owner" Type="text" setState={setState} State={state} stateProp="owner"/>
            <br/><br/>
            <Field Name="name" Type="text" setState={setState} State={state} stateProp="name"/>
            <br/><br/>
            <Field Name="symbol" Type="text" setState={setState} State={state} stateProp="symbol"/>
            <br/><br/>
            <Field Name="Total Supply" Type="number" setState={setState} State={state} stateProp="supply"/>
            <br/><br/>
            <Field Name="Maximum minting amount per Person" Type="number" setState={setState} State={state} stateProp="maxMint"/>
            <br/><br/>
            <Field Name="Price in WEI" Type="number" setState={setState} State={state} stateProp="priceInWei"/>
            <br/><br/>

            <label>Set Duration of the event</label>
            <p>After the event expires, the minting process wll be terminated</p>
            
            <label>Set start time</label>
            <br/><br/>
            <input type = "date" name = "date"
                onChange = {(e) => {
                            let Date = `${e.target.value}T`;
                            setState(prev =>({
                                ...prev,
                                duration:{
                                    ...state.duration,
                                    start:{
                                        ...state.duration.start,
                                        date:Date
                                    }
                                }
                            }))}}/>
            <input type = "time" name = "time"
                onChange = {(e) => {
                            let Time = `${e.target.value}:00Z`;
                            setState(prev =>({
                                ...prev,
                                duration:{
                                    ...state.duration,
                                    start:{
                                        ...state.duration.start,
                                        time:Time
                                    }
                                }
                            }))}}/> 
            <br/><br/>
            <label>Set end time</label>
            <br/><br/>
            <input type = "date" name = "date"
                onChange = {(e) => {
                            let Date = `${e.target.value}T`;
                            setState(prev =>({
                                ...prev,
                                duration:{
                                    ...state.duration,
                                    end:{
                                        ...state.duration.end,
                                        date:Date
                                    }
                                }
                            }))}}/>

            <input type = "time" name = "time" 
                onChange = {(e) => {
                            let Time = `${e.target.value}:00Z`;
                            setState(prev =>({
                                ...prev,
                                duration:{
                                    ...state.duration,
                                    end:{
                                        ...state.duration.end,
                                        time:Time
                                    }
                                }
                            }))}}/>
            <br/><br/>
            <button onClick={() => addEvent()}> Create Event</button>
            <br/>
            <button onClick={() => console.log(addresses.factory)}> Get</button>
            <br/>
            <button onClick={() => {
                let fix = `${state.duration.start.date}${state.duration.start.time}`;
                let d = new Date(fix);
                let unix = d.getTime();
                console.log(unix);
            }}> Get Unix Timestamp</button>
        </div>
    )
}
 
// ** Exports ** //
// exported as default so that the router can find the page
export default EventMaker;
