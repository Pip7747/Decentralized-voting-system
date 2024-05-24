// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PeerReviewVoting {
    struct Candidate {
        uint id;
        string name;
        address candidateAddress;
        uint voteCount;
    }

    struct Review {
        address reviewer;
        uint candidateId;
        string comments;
    }

    address public owner;
    Candidate[] public candidates;
    mapping(address => bool) public isCandidate;
    mapping(uint => Review[]) public candidateReviews;
    mapping(address => bool) public hasVoted;

    modifier ownerOnly() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyCandidates() {
        require(isCandidate[msg.sender], "Only candidates can call this function");
        _;
    }

    event CandidateAdded(uint id, string name, address candidateAddress);
    event VoteCast(address voter, uint candidateId);
    event ReviewSubmitted(address reviewer, uint candidateId, string comments);

    constructor() {
        owner = msg.sender;
    }

    function addCandidate(string memory _name, address _candidateAddress) public ownerOnly {
        require(!isCandidate[_candidateAddress], "Candidate already added");

        uint candidateId = candidates.length;
        candidates.push(Candidate(candidateId, _name, _candidateAddress, 0));
        isCandidate[_candidateAddress] = true;

        emit CandidateAdded(candidateId, _name, _candidateAddress);
    }

    function vote(uint _candidateId) public onlyCandidates {
        require(!hasVoted[msg.sender], "You have already voted");
        require(_candidateId < candidates.length, "Invalid candidate ID");

        candidates[_candidateId].voteCount += 1;
        hasVoted[msg.sender] = true;

        emit VoteCast(msg.sender, _candidateId);
    }

    function submitReview(uint _candidateId, string memory _comments) public onlyCandidates {
        require(_candidateId < candidates.length, "Invalid candidate ID");

        candidateReviews[_candidateId].push(Review(msg.sender, _candidateId, _comments));

        emit ReviewSubmitted(msg.sender, _candidateId, _comments);
    }

    function getNumCandidates() public view returns (uint) {
        return candidates.length;
    }

    function getCandidate(uint _candidateId) public view returns (uint, string memory, address, uint) {
        require(_candidateId < candidates.length, "Invalid candidate ID");

        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.candidateAddress, candidate.voteCount);
    }

    function getReviews(uint _candidateId) public view returns (Review[] memory) {
        require(_candidateId < candidates.length, "Invalid candidate ID");

        return candidateReviews[_candidateId];
    }
}
