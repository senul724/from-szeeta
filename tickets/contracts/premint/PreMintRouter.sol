// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./PreMintTickets.sol";

contract PreMintRouter{

    address organization;
    uint public fee;

    constructor(address org){
        organization = org;
    }

    // modifiers

    modifier onlyOrg(){
        require(msg.sender == organization);
        _;
    }
    
    // only for contributors of Events

    // to check if the person has the right amount of tokens and the tokens are not used
    function Check(address person, uint amount, address contract_) public view returns(bool, uint[] memory){
        PreMintTickets instance = new PreMintTickets(contract_);

        uint[] memory list = instance.walletOfOwner(person);
        bool state = true;
        require(amount > 0);
        require(list.length >= amount);
        require(instance.contributor(msg.sender));
        
        for (uint i; i <list.length; i++){
            if(instance.used(list[i])){
                state = false;
            }
        }
        return (state, list);
    }

    // to check in users
    function Mark(address person,uint amount, address contract_) external returns(uint[] memory){
        (bool state, uint[] memory list) = Check(person, amount, contract_);
        PreMintTickets instance = PreMintTickets(contract_);

        require(state);
        require(instance.contributor(msg.sender));

        uint[] memory usedTokens = new uint[](amount);
        for(uint i; i < amount; i++){
            instance.checkIn(list[i]);
            usedTokens[i] = list[i];
        }

        return(usedTokens);
    }

    // only Owners of Events

    function AddContributors(address[] memory list, address contract_) external{
        PreMintTickets instance = PreMintTickets(contract_);
        address owner = instance.owner();
        require(msg.sender == owner);
        require(isValid(contract_));

        for(uint i; i < list.length; i++){
            instance.addContributors(list[i]);
        }
    }

    function DropContributors(address[] memory list, address contract_) external{
        PreMintTickets instance = PreMintTickets(contract_);
        address owner = instance.owner();
        require(msg.sender == owner);
        require(isValid(contract_));

        for(uint i; i < list.length; i++){
            instance.dropContributors(list[i]);
        }
    }
    // internal functions

    function isUsed(address contract_, uint id) internal view returns(bool){
        PreMintTickets instance = PreMintTickets(contract_);
        return instance.used(id);
    }

    function isValid(address contract_) internal view returns(bool){
        PreMintTickets instance = PreMintTickets(contract_);
        bool state;
        bool contractState = instance.State();
        uint timeNow = block.timestamp;
        uint start = instance.startTime();
        uint end = instance.endTime();

        state = (timeNow < end) && (timeNow > start);
        return state && contractState;

    }

    // for organization purposes only

    function changeAdministration(address newOrg) external onlyOrg{
        organization = newOrg;
    }

    function changeFee(uint newFee) external onlyOrg{
        fee = newFee;
    }
    
}