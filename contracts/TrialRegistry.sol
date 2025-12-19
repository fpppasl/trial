// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";
import {euint32} from "@fhevm/solidity/lib/FHE.sol";

// clinical trials registry
contract TrialRegistry is ZamaEthereumConfig {
    struct Trial {
        address researcher;
        string name;
        string description;
        uint256 startDate;
        uint256 endDate;
        bool active;
    }
    
    struct Participant {
        address participant;
        euint32 data;  // encrypted participant data
        uint256 enrolledAt;
        bool active;
    }
    
    mapping(uint256 => Trial) public trials;
    mapping(uint256 => mapping(address => Participant)) public participants;
    mapping(uint256 => address[]) public trialParticipants;
    uint256 public trialCounter;
    
    event TrialCreated(uint256 indexed trialId, address researcher);
    event ParticipantEnrolled(uint256 indexed trialId, address participant);
    
    function createTrial(
        string memory name,
        string memory description,
        uint256 duration
    ) external returns (uint256 trialId) {
        trialId = trialCounter++;
        trials[trialId] = Trial({
            researcher: msg.sender,
            name: name,
            description: description,
            startDate: block.timestamp,
            endDate: block.timestamp + duration,
            active: true
        });
        emit TrialCreated(trialId, msg.sender);
    }
    
    function enroll(
        uint256 trialId,
        euint32 encryptedData
    ) external {
        Trial storage trial = trials[trialId];
        require(trial.active, "Trial not active");
        require(block.timestamp < trial.endDate, "Trial ended");
        
        participants[trialId][msg.sender] = Participant({
            participant: msg.sender,
            data: encryptedData,
            enrolledAt: block.timestamp,
            active: true
        });
        
        trialParticipants[trialId].push(msg.sender);
        emit ParticipantEnrolled(trialId, msg.sender);
    }
}

