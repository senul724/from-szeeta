// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IPreMintTickets{
    function checkIn(uint id) external;
    function Withdraw() external;
    function changeStartTime(uint time) external;
    function changeEndTime(uint time) external;
    function addContributors(address person) external;
    function dropContributors(address person) external;
    function changeState() external;
}