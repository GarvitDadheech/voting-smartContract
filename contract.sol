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