// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Election.sol";

contract VotingFactory {
    address public admin;
    Election[] public elections;
    mapping(address => bool) public isElection;
    event ElectionCreated(address electionAddress, string name);
    event AdminChanged(address oldAdmin, address newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createElection(string memory _name, uint256 _startTime, uint256 _endTime) public onlyAdmin {
        Election newElection = new Election(_name, admin);
        elections.push(newElection);
        isElection[address(newElection)] = true;
        newElection.setVotingPeriod(_startTime, _endTime);
        emit ElectionCreated(address(newElection), _name);
    }

    function getElections() public view returns (Election[] memory) {
        return elections;
    }

    function getElectionCount() public view returns (uint256) {
        return elections.length;
    }

    function getElectionAt(uint256 index) public view returns (Election) {
        require(index < elections.length, "Invalid index");
        return elections[index];
    }

    function isValidElection(address _electionAddress) public view returns (bool) {
        return isElection[_electionAddress];
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid admin address");
        address oldAdmin = admin;
        admin = _newAdmin;
        emit AdminChanged(oldAdmin, _newAdmin);
    }

    // Helper functions to interact with elections
    function addContestant(uint256 _electionIndex, address _contestant) public onlyAdmin {
        require(_electionIndex < elections.length, "Invalid election index");
        elections[_electionIndex].addContestant(_contestant);
    }

    function registerVoter(uint256 _electionIndex, address _voter) public onlyAdmin {
        require(_electionIndex < elections.length, "Invalid election index");
        elections[_electionIndex].registerVoter(_voter);
    }

    function closeElection(uint256 _electionIndex) public onlyAdmin {
        require(_electionIndex < elections.length, "Invalid election index");
        elections[_electionIndex].closeElection();
    }
}