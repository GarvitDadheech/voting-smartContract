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

    function candidateVerification(address _candidateAddress) internal view returns(bool) {
        for(uint i = 1; i < currCandidateId; i++) {
            if(candidates[i].candidateAddress == _candidateAddress) {
                return false;
            }
        }
        return true;
    }

    function candidateList() public view isElectionOngoing() returns(Candidate[] memory) {
        Candidate[] memory temp = new Candidate[](currCandidateId - 1);
        for(uint i = 1; i < currCandidateId; i++) {
            temp[i - 1] = candidates[i];
        }
        return temp;
    }

    function voterRegister(string calldata _name, string calldata _gender, uint _age) external isElectionOngoing() {
        require(_age >= 18, "You are under 18 and not allowed to vote!");
        require(voterVerification(msg.sender), "You have already registered as a voter!");
        voters[currVoterId] = Voter({
            name: _name,
            gender: _gender,
            age: _age,
            voterAddress: msg.sender,
            voterId: currVoterId,
            votedCandidateId: 0
        });
        currVoterId++;
    }

    function voterVerification(address _voterAddress) internal view returns(bool) {
        for(uint i = 1; i < currVoterId; i++) {
            if(voters[i].voterAddress == _voterAddress) {
                return false;
            }
        }
        return true;
    }

    function voterList() public view returns(Voter[] memory) {
        Voter[] memory temp = new Voter[](currVoterId - 1);
        for(uint i = 1; i < currVoterId; i++) {
            temp[i - 1] = voters[i];
        }
        return temp;
    }

    function vote(uint _candidateId) external isElectionOngoing() {
        Voter storage voter = voters[currVoterId - 1];
        require(voter.voterAddress == msg.sender, "You are not registered to vote!");
        require(_candidateId > 0 && _candidateId < currCandidateId, "Candidate is not valid!");
        require(voter.votedCandidateId == 0, "You have already voted!");
        
        voter.votedCandidateId = _candidateId;
        candidates[_candidateId].totalVotes++;
    }

    function voteTime(uint _startTime, uint duration) external isElectionComission() {
        require(startTime == 0, "Voting time has already been set!");
        startTime = _startTime;
        endTime = _startTime + duration;
    }

    function votingStatus() public view returns(string memory) {
        if(startTime == 0) {
            return "Voting has not started!";
        } else if(block.timestamp <= endTime && !stopVoting) {
            return "Voting has started!";
        } else {
            return "Voting has ended!";
        }
    }

    function result() external isElectionComission() {
        require(!resultDeclared, "Result has already been declared!");
        uint max = 0;
        for(uint i = 1; i < currCandidateId; i++) {
            if(candidates[i].totalVotes > max) {
                max = candidates[i].totalVotes;
                electionWinner = candidates[i].candidateAddress;
            }
        }
        resultDeclared = true;
    }

    function emergency() public isElectionComission() {
        stopVoting = true;
    }

    function resetElection() external isElectionComission() {
        require(block.timestamp > endTime, "Cannot reset during an ongoing election!");
        for(uint i = 1; i < currCandidateId; i++) {
            delete candidates[i];
        }
        for(uint i = 1; i < currVoterId; i++) {
            delete voters[i];
        }
        currVoterId = 1;
        currCandidateId = 1;
        startTime = 0;
        endTime = 0;
        stopVoting = false;
        electionWinner = address(0);
        resultDeclared = false;
    }

}
