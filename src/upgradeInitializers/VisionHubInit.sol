// SPDX-License-Identifier: MIT
// slither-disable-next-line solc-version
pragma solidity 0.8.26;

import {LibDiamond} from "@diamond/libraries/LibDiamond.sol";
import {IDiamondLoupe} from "@diamond/interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "@diamond/interfaces/IDiamondCut.sol";
import {IERC165} from "@diamond/interfaces/IERC165.sol";

import {VisionHubStorage} from "../VisionHubStorage.sol";

/**
 * @title Vision Hub initializer
 *
 * @notice This contract is used for one-off initialization of Vision Hub.
 * It contains a single function `init`, which is intended to be called by
 * Diamond Cut Facet during the initial setup and configuration of Vision Hub
 * with the specified parameters.
 *
 * @dev This is not designed for repeated initializations. It will revert if
 * attempted to call it more than once with subsequent diamond cut.
 * The `init` function should not be called directly. It is meant to be invoked
 * by the diamond cut facet using delegatecall to initialize the state of
 * Vision Hub.
 */
contract VisionHubInit {
    VisionHubStorage internal ps;

    struct Args {
        uint256 blockchainId;
        string blockchainName;
        uint256 minimumServiceNodeDeposit;
        uint256 unbondingPeriodServiceNodeDeposit;
        uint256 validatorFeeFactor;
        uint256 parameterUpdateDelay;
        uint256 nextTransferId;
    }

    /**
     * @dev Initializes the storage with provided arguments.
     *
     * @param args The struct containing initialization arguments.
     */
    function init(Args memory args) external {
        // safety check to ensure, init is only called once
        require(
            ps.initialized == 0,
            "VisionHubInit: contract is already initialized"
        );
        ps.initialized = 1;

        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;

        // initialising VisionHubStorage
        ps.paused = true;
        // Register the current blockchain
        ps.currentBlockchainId = args.blockchainId;
        require(
            bytes(args.blockchainName).length > 0,
            "VisionHubInit: blockchain name must not be empty"
        );

        // Store the blockchain record
        ps.blockchainRecords[args.blockchainId].active = true;
        ps.blockchainRecords[args.blockchainId].name = args.blockchainName;
        ps.numberBlockchains = args.blockchainId + 1;
        ps.numberActiveBlockchains++;
        ps.parameterUpdateDelay.currentValue = args.parameterUpdateDelay;

        require(
            args.validatorFeeFactor >= 1,
            "VisionHubInit: validator fee factor must be >= 1"
        );
        ps.validatorFeeFactors[args.blockchainId].currentValue = args
            .validatorFeeFactor;

        ps.minimumServiceNodeDeposit.currentValue = args
            .minimumServiceNodeDeposit;
        ps.unbondingPeriodServiceNodeDeposit.currentValue = args
            .unbondingPeriodServiceNodeDeposit;
        // Set the next transfer ID (is greater than 0 if there have already
        // been prior Vision transfers initiated on the current blockchain)
        ps.nextTransferId = args.nextTransferId;
    }
}
