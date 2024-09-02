// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract votingSmartContract {
    struct Voter {
        string name;
        uint age;
        uint voterId;
        uint votedCandidateId;
        address voterAddress;
        string gender;
    }

    struct Candidate {
        string name;
        string party;
        string gender;
        uint age;
        uint candidateId;
        address candidateAddress;
        uint totalVotes;
    }

    address public electionComission;
    address public electionWinner;

    uint private currVoterId = 1;
    uint private currCandidateId = 1;

    uint private startTime;
    uint private endTime;
    bool private stopVoting;
    bool private resultDeclared;

    mapping(uint => Voter) public voters;
    mapping(uint => Candidate) public candidates;

    constructor() {
        electionComission = msg.sender;
    }

    modifier isElectionComission() {
        require(electionComission == msg.sender, "You are not election comission!");
        _;
    }

    modifier isElectionOngoing() {
        require(block.timestamp >= startTime && block.timestamp <= endTime && !stopVoting, "Voting is over or not started!");
        _;
    }

    function candidateRegister(string calldata _name, string calldata _gender, uint _age, string calldata _party) external {
        require(_age >= 18, "You are under 18 and not allowed for becoming a candidate");
        require(candidateVerification(msg.sender), "You have already registered as a candidate!");
        candidates[currCandidateId] = Candidate({
            name: _name,
            gender: _gender,
            age: _age,
            party: _party,
            candidateId: currCandidateId,
            candidateAddress: msg.sender,
            totalVotes: 0
        });
        currCandidateId++;
    }

}
