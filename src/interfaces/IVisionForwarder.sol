// SPDX-License-Identifier: GPL-3.0
// slither-disable-next-line solc-version
pragma solidity 0.8.26;

import {VisionTypes} from "./VisionTypes.sol";

/**
 * @title Vision Forwarder interface
 *
 * @notice The Vision Forwarder is responsible for verifying Vision
 * transfers requests coming from the Vision Hub and forwarding those
 * requests to the token contract if such a request is valid.
 *
 * @dev The interface declares all Vision Forwarder events and
 * functions. Most of the functions are only callable by the Vision Hub,
 * but the idea is to keep this contract as small as possible, since a
 * token issuer should be able to verify the Vision Forwarder contract
 * in order to set it as the token's trusted Forwarder.
 */
interface IVisionForwarder {
    event VisionHubSet(address visionHub);

    event VisionTokenSet(address visionToken);

    /**
     * @notice Event that is emitted when the minimum number of
     * validator node signatures for validating a cross-chain transfer
     * is updated.
     *
     * @param minimumValidatorNodeSignatures The minimum number of
     * signatures.
     */
    event MinimumValidatorNodeSignaturesUpdated(
        uint256 minimumValidatorNodeSignatures
    );

    /**
     * @notice Event that is emitted when a new node is added to the
     * validator network.
     *
     * @param validatorNodeAddress The address of the validator node.
     */
    event ValidatorNodeAdded(address validatorNodeAddress);

    /**
     * @notice Event that is emitted when a node is removed from the
     * validator network.
     *
     * @param validatorNodeAddress The address of the validator node.
     */
    event ValidatorNodeRemoved(address validatorNodeAddress);

    /**
     * @notice Takes a transfer requests, which transfers tokens from a sender
     * to a recipient on the same blockchain, verifies its correctness and
     * forwards it to the token contract from the data structure.
     * It is only callable by the Vision Hub.
     *
     * @param request The TransferRequest data structure
     * @param signature The signature of the request
     *
     * @return A pair of a flag that indicates if the PANDAS token
     * transfer succeeded and optional PANDAS token data (the latter may
     * contain an error message if the PANDAS token transfer failed).
     *
     * @dev The function reverts if the TransferRequest data structure is not
     * valid
     */
    function verifyAndForwardTransfer(
        VisionTypes.TransferRequest calldata request,
        bytes memory signature
    ) external returns (bool, bytes32);

    /**
     * @notice Takes a transfer requests, which initializes a cross-blockchain
     * transfer from the Vision Hub, verifies its correctness and forwards it
     * to the token contract from the data structure. It is only callable by
     * the Vision Hub.
     *
     * @param request The TransferFromRequest data structure
     * @param signature The signature of the request
     *
     * @return A pair of a flag that indicates if the PANDAS token
     * transfer succeeded and optional PANDAS token data (the latter may
     * contain an error message if the PANDAS token transfer failed).
     *
     * @dev The function reverts if the TransferFromRequest data structure is
     * not valid
     */
    function verifyAndForwardTransferFrom(
        uint256 sourceBlockchainFactor,
        uint256 destinationBlockchainFactor,
        VisionTypes.TransferFromRequest calldata request,
        bytes memory signature
    ) external returns (bool, bytes32);

    /**
     * @notice Takes a transfer requests, which is the last step of a
     * cross-blockchain transfer. The Vision Forwarder verifies the
     * correctness of the transfer request and forwards it
     * to the token contract from the data structure. It is only
     * callable by the Vision Hub.
     *
     * @param request The TransferToRequest data structure.
     * @param signerAddresses The addresses of the validator nodes that
     * signed the transfer (must be ordered from the lowest to the
     * highest address).
     * @param signatures The signatures of the validator nodes (each
     * signature must be in the same array position as the corresponding
     * signer address).
     *
     * @dev The function reverts if the TransferToRequest data structure
     * is not valid.
     */
    function verifyAndForwardTransferTo(
        VisionTypes.TransferToRequest calldata request,
        address[] memory signerAddresses,
        bytes[] memory signatures
    ) external;

    /**
     * @return The supported major Vision protocol version.
     */
    function getMajorProtocolVersion() external view returns (uint8);

    /**
     * @notice Returns the address of the Vision Hub
     *
     * @return The address of the Vision Hub
     */
    function getVisionHub() external view returns (address);

    /**
     * @notice Returns the address of the Vision Token
     *
     * @return The address of the Vision Token
     */
    function getVisionToken() external view returns (address);

    /**
     * @return The minimum number of validator node signatures for
     * validating a cross-chain transfer.
     */
    function getMinimumValidatorNodeSignatures()
        external
        view
        returns (uint256);

    /**
     * @return The addresses of all nodes of the validator network.
     */
    function getValidatorNodes() external view returns (address[] memory);

    /**
     * @notice Check if a given nonce is a valid (i.e. not yet used)
     * validator node nonce.
     *
     * @param nonce The nonce to be checked.
     *
     * @return True if the nonce is valid.
     */
    function isValidValidatorNodeNonce(
        uint256 nonce
    ) external view returns (bool);

    /**
     * @notice Returns if the given sender nonce is valid
     *
     * @param sender The address of the sender
     * @param nonce The nonce to be checked
     *
     * @return True if the nonce is valid, false otherwise
     */
    function isValidSenderNonce(
        address sender,
        uint256 nonce
    ) external view returns (bool);

    /**
     * @notice Verifies a given TransferRequest. The function is only
     * callable by the Vision Hub
     *
     * @param request The TransferRequest to be verified
     * @param signature The signature over the TransferRequest
     *
     * @dev The function reverts if the TransferRequest data structure is not
     * valid
     */
    function verifyTransfer(
        VisionTypes.TransferRequest calldata request,
        bytes memory signature
    ) external view;

    /**
     * @notice Verifies a given TransferFromRequest. The function is only
     * callable by the Vision Hub
     *
     * @param request The TransferFromRequest to be verified
     * @param signature The signature over the TransferFromRequest
     *
     * @dev The function reverts if the TransferFromRequest data structure is
     * not valid
     */
    function verifyTransferFrom(
        VisionTypes.TransferFromRequest calldata request,
        bytes memory signature
    ) external view;

    /**
     * @notice Verifies a given TransferToRequest. The function is only
     * callable by the Vision Hub.
     *
     * @param request The TransferToRequest to be verified.
     * @param signerAddresses The addresses of the validator nodes that
     * signed the transfer (must be ordered from the lowest to the
     * highest address).
     * @param signatures The signatures of the validator nodes (each
     * signature must be in the same array position as the corresponding
     * signer address).
     *
     * @dev The function reverts if the TransferToRequest data structure
     * is not valid.
     */
    function verifyTransferTo(
        VisionTypes.TransferToRequest calldata request,
        address[] memory signerAddresses,
        bytes[] memory signatures
    ) external view;
}
