// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ITicket{
    function mintTicket(address to) external payable;
    function checkIn(uint id) external;
    function Withdraw() external;
    function changePrice(uint newPriceInWei) external;
    function changeBase(string memory base_) external;
    function changeStartTime(uint time) external;
    function changeEndTime(uint time) external;
    function changeMintAmount(uint maxMints) external;
    function addContributors(address person) external;
    function dropContributors(address person) external;
    function changeState() external;

}