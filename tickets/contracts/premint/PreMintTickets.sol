// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../interfaces/IPreMintTickets.sol";

contract PreMintTickets is IPreMintTickets{

    address public owner;
    address public collectionAddress;
    address org;

    uint public eventID;
    uint public startTime; //times are in unix timestamp
    uint public endTime;
    uint public fixedFee;

    bool public State = true;

    mapping (address=>bool) public contributor; 
    mapping (uint => bool) public used; //to identify used tokens

    // modifiers
    modifier onlyContributor(){
        require(contributor[msg.sender]);
        _;
    }
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    modifier valid(){
        uint timeNow = block.timestamp;
        require(timeNow > startTime);
        require(timeNow < endTime);
        _;
    }
    modifier notPaused(){
        require(State);
        _;
    }

    constructor(
        address owner_,
        address org_,
        address collection,
        uint startTime_,
        uint endTime_,
        uint eventID_) {

        owner = owner_;
        org = org_;
        collectionAddress = collection;
        contributor[owner] = true;
        startTime = startTime_;
        endTime = endTime_;
        eventID = eventID_;
        
    }

    //only contributors
    function checkIn(uint id) external override onlyContributor{
        bool state = ERC721(collectionAddress)._exists(id);
        require(!used[id]);
        used[id] = true;
    }

    // only Owner

    //to withdraw funds from the smartcontract

    function Withdraw() external override onlyOwner{
        require(address(this).balance > 0);

        uint balance = address(this).balance;
        uint charge = balance/fixedFee;
        uint withdrawableAmount = balance - charge;
        
        sendValue(payable(org), charge); //fee
        sendValue(payable(owner), withdrawableAmount); //totalAmount - fee
    }

    // basic intentional edits by admin/owner
    function changeStartTime(uint time) external override onlyOwner valid{
        startTime = time;
    }

    function changeEndTime(uint time) external override onlyOwner valid{
        endTime = time;
    }

    function addContributors(address person) external override onlyOwner valid{
        require(msg.sender == owner);
        contributor[person] = true;

    }
    function dropContributors(address person) external override onlyOwner valid{
        require(msg.sender == owner);
        contributor[person] = false;

    }
    function changeState() external override valid onlyOwner {
        bool prevState = State;
        State = !prevState;

    }

    // internal

    function sendValue(address payable recipient, uint256 amount) internal {

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}