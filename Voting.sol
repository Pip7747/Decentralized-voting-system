// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool authorized;
        bool voted;
        uint vote;
    }

    address public owner;
    string public electionName;
    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    uint public totalVotes;

    modifier ownerOnly() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    event ElectionResult(string candidateName, uint voteCount);

    constructor(string memory _name) {
        owner = msg.sender;
        electionName = _name;
    }

    function addCandidate(string memory _name) public ownerOnly {
        candidates.push(Candidate(candidates.length, _name, 0));
    }

    function authorizeVoter(address _person) public ownerOnly {
        voters[_person].authorized = true;
    }

    function vote(uint _candidateId) public {
        require(!voters[msg.sender].voted, "You have already voted");
        require(voters[msg.sender].authorized, "You are not authorized to vote");
        require(_candidateId < candidates.length && _candidateId >= 0, "Invalid candidate ID");

        voters[msg.sender].vote = _candidateId;
        voters[msg.sender].voted = true;
        candidates[_candidateId].voteCount += 1;
        totalVotes += 1;
    }

    function endElection() public ownerOnly {
        for (uint i = 0; i < candidates.length; i++) {
            emit ElectionResult(candidates[i].name, candidates[i].voteCount);
        }
    }

    function getNumCandidates() public view returns (uint) {
        return candidates.length;
    }

    function getCandidate(uint index) public view returns (uint, string memory, uint) {
        require(index < candidates.length, "Invalid candidate index");
        Candidate memory candidate = candidates[index];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
}
