// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FHE, ebool, euint64, externalEuint64} from "@fhevm/solidity/lib/FHE.sol";

import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title PrivateP2PLoanLimit
 */
contract PrivateP2PLoanLimit is ZamaEthereumConfig {
    /* -------- Ownable -------- */
    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero owner");
        owner = newOwner;
    }

    /* -------- Reentrancy Guard -------- */
    uint256 private _locked = 1;
    modifier nonReentrant() {
        require(_locked == 1, "reentrancy");
        _locked = 2;
        _;
        _locked = 1;
    }

    /* -------- Encrypted Policy -------- */
    euint64 private eMinIncome;

    event MinIncomeUpdated(bytes32 minIncomeHandle);

    function setMinIncome(externalEuint64 _minIncome, bytes calldata proof) external onlyOwner {
        eMinIncome = FHE.fromExternal(_minIncome, proof);
        FHE.allowThis(eMinIncome);
        FHE.makePubliclyDecryptable(eMinIncome);

        emit MinIncomeUpdated(FHE.toBytes32(eMinIncome));
    }

    /* -------- Loan Applications -------- */
    struct Application {
        euint64 eIncome;
        ebool eApproved;
        bool decided;
    }

    mapping(address => Application) private applications;

    event LoanChecked(address indexed user, bytes32 decisionHandle);

    /**
     * @notice Submit encrypted income (public or user encryption)
     * @param encIncome - ciphertext handle (userEncrypted or publicEncrypted)
     */
    function submitIncome(externalEuint64 encIncome, bytes calldata proof) external nonReentrant {
        Application storage A = applications[msg.sender];

        // Import encrypted income
        euint64 eInc = FHE.fromExternal(encIncome, proof);

        // Grant access
        FHE.allowThis(eInc);
        FHE.allow(eInc, msg.sender); // 🟢 user decryption allowed

        // Private check: income >= minimum
        ebool approved = FHE.ge(eInc, eMinIncome);

        // Store
        A.eIncome = eInc;
        A.eApproved = approved;
        A.decided = true;

        // Grant contract scope
        FHE.allowThis(A.eIncome);
        FHE.allowThis(A.eApproved);

        // Make decision publicly decryptable
        FHE.makePubliclyDecryptable(A.eApproved);

        emit LoanChecked(msg.sender, FHE.toBytes32(A.eApproved));
    }

    /* -------- Getters (handles only) -------- */

    /**
     * @notice Public handle for approval decision
     */
    function getDecisionHandle(address user) external view returns (bytes32) {
        Application storage A = applications[user];
        if (!A.decided) return bytes32(0);
        return FHE.toBytes32(A.eApproved);
    }

    /**
     * @notice User can decrypt their encrypted income via userDecrypt
     */
    function getMyIncomeHandle() external view returns (bytes32) {
        Application storage A = applications[msg.sender];
        return FHE.toBytes32(A.eIncome);
    }

    /**
     * @notice For UI convenience: check whether user has submitted
     */
    function hasSubmitted(address user) external view returns (bool) {
        return applications[user].decided;
    }
}
