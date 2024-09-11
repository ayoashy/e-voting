// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Election {
    string public name;
    address public admin;
    mapping(address => bool) public voters;
    mapping(address => bool) public contestants;
    mapping(address => uint256) public votes;
    
    address[] public contestantList;
    uint256 public votingStart;
    uint256 public votingEnd;
    bool public electionClosed;

    event ContestantAdded(address contestant);
    event VoterRegistered(address voter);
    event Voted(address voter, address contestant);
    event ElectionClosed();

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier electionActive() {
        require(block.timestamp >= votingStart && block.timestamp <= votingEnd, "Election is not active");
        require(!electionClosed, "Election is closed");
        _;
    }

    constructor(string memory _name, address _admin) {
        name = _name;
        admin = _admin;
    }

    function setVotingPeriod(uint256 _startTime, uint256 _endTime) public onlyAdmin {
        require(_startTime < _endTime, "Invalid voting period");
        require(block.timestamp < _startTime, "Start time must be in the future");
        votingStart = _startTime;
        votingEnd = _endTime;
    }

    function addContestant(address _contestant) public onlyAdmin {
        require(!contestants[_contestant], "Contestant already added");
        contestants[_contestant] = true;
        contestantList.push(_contestant);
        emit ContestantAdded(_contestant);
    }

    function registerVoter(address _voter) public onlyAdmin {
        require(!voters[_voter], "Voter already registered");
        voters[_voter] = true;
        emit VoterRegistered(_voter);
    }

    function vote(address _contestant) public electionActive {
        require(voters[msg.sender], "Not registered to vote");
        require(!voters[msg.sender], "Already voted");
        require(contestants[_contestant], "Invalid contestant");
        
        voters[msg.sender] = true;
        votes[_contestant]++;
        emit Voted(msg.sender, _contestant);
    }

    function closeElection() public onlyAdmin {
        require(block.timestamp > votingEnd, "Voting period has not ended");
        require(!electionClosed, "Election already closed");
        electionClosed = true;
        emit ElectionClosed();
    }

    function getContestants() public view returns (address[] memory) {
        return contestantList;
    }

    function getVotes(address _contestant) public view returns (uint256) {
        return votes[_contestant];
    }

    function getWinner() public view returns (address, uint256) {
        require(electionClosed, "Election is not closed yet");
        address winner = address(0);
        uint256 maxVotes = 0;
        
        for (uint i = 0; i < contestantList.length; i++) {
            address contestant = contestantList[i];
            if (votes[contestant] > maxVotes) {
                maxVotes = votes[contestant];
                winner = contestant;
            }
        }
        
        return (winner, maxVotes);
    }
}