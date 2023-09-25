// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Election {

    struct Vote {                      // structure vote wala
        uint timestamp;
        uint blockHeight;
        address voter;
        bytes32 candidate;
    }

  
    struct Candidate {                 // candidate ka naam 
        bytes32 name;
        uint voteCount;
    }

Vote[] public votes;

 address public admin;
 // SECURITY ENSURED HERE  only the admin executes imp fns
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can call this function");
        _;
    }

    mapping(address => bool) public authorizedVoters;   // vote storing
    mapping(address => bool) public hasVoted;
    mapping(address => bytes32) public votedFor;

   

  
    Candidate[] public candidates;  // storing candidates
 
      bool public electionStarted;
      bool public electionEnded;


    //election start/end//

    modifier electionIsStarted() {
        require(electionStarted, "Election has not started yet");
        _;
    }

    modifier electionIsNotEnded() {
        require(!electionEnded, "Election has already ended");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // fns to add a candidate to the election
    function addCandidate(bytes32 _name) external onlyAdmin {
        require(!electionStarted, "Election has already started");
        candidates.push(Candidate(_name, 0));
    }

    // fns to start/end elecn.{WINNER DETERMINED}
        function startElection() external onlyAdmin {
        require(candidates.length > 0, "No candidates added");
        electionStarted = true;
    }

       function endElection() external onlyAdmin electionIsStarted electionIsNotEnded {
        electionEnded = true;
        announceWinner();
    }

    //(WINNER ANNOUNCEMENT)
    function announceWinner() internal {
        uint winningVoteCount = 0;
        bytes32 winnerName;

        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winnerName = candidates[i].name;
            }
        }

        emit winnerannounced(winnerName, winningVoteCount);
    }

    // (VOTE CASTING)
    function vote(bytes32 _candidate) external electionIsStarted {
        require(authorizedVoters[msg.sender], "You are not authorized to vote");
        require(!hasVoted[msg.sender], "You have already voted");

        // timestamp and block height, VOTE recoded (ADDITIONAL MODIFICATIONS)
        uint timestamp = block.timestamp;
        uint blockHeight = block.number;

        votes.push(Vote(timestamp, blockHeight, msg.sender, _candidate));

    //MARED AS VOTED
        hasVoted[msg.sender] = true;
        votedFor[msg.sender] = _candidate;

        // Update the candidate's vote count
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].name == _candidate) {
                candidates[i].voteCount++;
                break;
            }
        }
    }

    // fns to view election results
    function viewResults() external view returns (Candidate[] memory) {
        return candidates;
    }

    // Event to announce the winner
    event winnerannounced(bytes32 indexed winnerName, uint winningVoteCount);
}
