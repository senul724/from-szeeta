// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Ticket.sol";

contract Factory{
    address public owner;
    address reciever;

    uint public eventCounter;
    uint public fee;

    struct eventDetails{
        Ticket Event;
        address admin;
        address eventAddress;
    }

    mapping(uint => eventDetails) eventList;
    mapping(address => uint[]) userEvents;


    // modifiers
    modifier onlyAdmin(){
        require(msg.sender == owner);
        _;
    }

    // events
    event eventAdded(address admin, address eventAddress);
    event ownershipTransfered(address pastOwner, address newOwner);
    event recieverChanged(address pastReciever, address newReciever);
    event priceChanged(uint pastPrice, uint newPrice);

    constructor(address owner_, address reciever_,uint fee_){
        owner = owner_;
        reciever = reciever_;
        fee = fee_;
        eventCounter = 1;
    }

    function addEvent(
        address owner__,
        string[] memory nameandSymbol__, 
        string memory cid__,
        uint supply__,
        uint maxMints__,
        uint priceInWei__,
        uint startTime__,
        uint endTime__
    ) external returns(address){
        Ticket instance = new Ticket(
            owner__,
            reciever,
            nameandSymbol__,
            cid__,
            supply__,
            maxMints__,
            priceInWei__,
            startTime__,
            endTime__,
            fee,
            eventCounter
        );
        eventList[eventCounter].Event = instance;
        eventList[eventCounter].admin = owner__;
        eventList[eventCounter].eventAddress = address(instance);
        userEvents[owner__].push(eventCounter);
        eventCounter ++;

        emit eventAdded(owner__, address(instance));
        return address(instance);
    }

    function addEventCreate2(
        address owner__,
        string[] memory nameandSymbol__, 
        string memory cid__,
        uint supply__,
        uint maxMints__,
        uint priceInWei__,
        uint startTime__,
        uint endTime__,
        uint randomNo
    ) external returns(address contractAddress){
        bytes memory salt = keccak256(abi.encode(msg.sender, randomNo));
        bytes memory code  = abi.encode(
            type(Ticket).creationCode,
            owner__,
            reciever,
            nameandSymbol__,
            cid__,
            supply__,
            maxMints__,
            priceInWei__,
            startTime__,
            endTime__,
            fee,
            eventCounter);
        assembly {
            contractAddress := create2(0, add(code,32), mload(code), salt)
        }
        
        eventList[eventCounter].admin = owner__;
        eventList[eventCounter].eventAddress = contractAddress;
        userEvents[owner__].push(eventCounter);
        eventCounter ++;

        emit eventAdded(owner__, contractAddress);
    }

    function getEventInfo(uint eventId) external view returns(address, address){
        return (eventList[eventId].admin, eventList[eventId].eventAddress);
    }

    function getEventAddresses() external view returns(address[] memory){
        address[] memory list = new address[](eventCounter);
        for(uint i =1; i<=eventCounter; i++){
            list[i-1] = eventList[i].eventAddress;
        } 
        return list;
    }

    function getUserEvents(address user) external view returns(uint[] memory, address[] memory){
        uint len = userEvents[user].length;
        address[] memory list = new address[](len);
        if(len != 0){
            for(uint i ; i<len; i++){
                list[i] = eventList[userEvents[user][i]].eventAddress;
            }
        }
        return(userEvents[user], list);
    }

    function getBuyerTickets(address buyer) external view returns(uint[] memory){
        uint[] memory list = new uint[](eventCounter);

        for(uint i =1; i<=eventCounter; i++){
            address eventAd = eventList[i].eventAddress;
            Ticket instance = Ticket(eventAd);
            list[i-1] = instance.balanceOf(buyer);
        }
        return(list);
    }

    function changeFee(uint fee_) external onlyAdmin{
        uint pastPrice = fee;
        fee = fee_;
        emit priceChanged(pastPrice, fee_);
    }

    function changeOwnership(address newOwner) external onlyAdmin{
        address pastOwner= owner;
        owner = newOwner;
        emit ownershipTransfered(pastOwner, newOwner);
    }

    function changeReciever(address newReciever) external onlyAdmin{
        address pastReciever= reciever;
        reciever = newReciever;
        emit recieverChanged(pastReciever, newReciever);
    }
}
