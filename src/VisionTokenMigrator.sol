// SPDX-License-Identifier: GPL-3.0
// slither-disable-next-line solc-version
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Contract for migrating from the old (original) single-chain to
 * the new multi-chain Vision token on Ethereum
 */
contract VisionTokenMigrator {
    address private immutable _oldTokenAddress;

    address private immutable _newTokenAddress;

    bool private _tokenMigrationStarted;

    /**
     * @param oldTokenAddress The address of the old Vision token
     * contract.
     * @param newTokenAddress The address of the new Vision token
     * contract.
     *
     * @dev The token migration is halted until explicitly started in a
     * separate transaction.
     */
    constructor(address oldTokenAddress, address newTokenAddress) {
        require(
            oldTokenAddress != address(0),
            "VisionTokenMigrator: old token address must not be zero"
        );
        require(
            newTokenAddress != address(0),
            "VisionTokenMigrator: new token address must not be zero"
        );
        require(
            IERC20(oldTokenAddress).totalSupply() ==
                IERC20(newTokenAddress).totalSupply(),
            "VisionTokenMigrator: total supplies of tokens do not match"
        );
        _oldTokenAddress = oldTokenAddress;
        _newTokenAddress = newTokenAddress;
        _tokenMigrationStarted = false;
    }

    /**
     * @notice Event that is emitted when the token migration starts.
     */
    event TokenMigrationStarted();

    /**
     * @notice Event that is emitted when an account has migrated its
     * tokens.
     *
     * @param accountAddress The address of the token holder account.
     * @param tokenAmount The amount of tokens that has been migrated.
     */
    event TokensMigrated(address accountAddress, uint256 tokenAmount);

    /**
     * @notice Start the token migration by transferring the total
     * supply of the new Vision token to the contract.
     *
     * @dev There must be an allowance of the total token supply for the
     * contract when invoking this function. After the transaction is
     * included in the blockchain, all accounts are able to migrate
     * their own tokens.
     */
    function startTokenMigration() external {
        require(
            !_tokenMigrationStarted,
            "VisionTokenMigrator: token migration already started"
        );
        uint256 tokenAmount = IERC20(_oldTokenAddress).totalSupply();
        _tokenMigrationStarted = true;
        emit TokenMigrationStarted();
        require(
            IERC20(_newTokenAddress).transferFrom(
                msg.sender,
                address(this),
                tokenAmount
            ),
            "VisionTokenMigrator: transfer of new tokens failed"
        );
    }

    /**
     * @notice Migrate the tokens held by the sender of the transaction.
     *
     * @dev There must be an allowance of the sender account's total
     * token balance for the contract when invoking this function.
     */
    function migrateTokens() external {
        require(
            _tokenMigrationStarted,
            "VisionTokenMigrator: token migration not yet started"
        );
        uint256 tokenAmount = IERC20(_oldTokenAddress).balanceOf(msg.sender);
        require(
            tokenAmount > 0,
            "VisionTokenMigrator: sender does not own any tokens"
        );
        emit TokensMigrated(msg.sender, tokenAmount);
        require(
            IERC20(_oldTokenAddress).transferFrom(
                msg.sender,
                address(this),
                tokenAmount
            ),
            "VisionTokenMigrator: transfer of old tokens failed"
        );
        require(
            IERC20(_newTokenAddress).transfer(msg.sender, tokenAmount),
            "VisionTokenMigrator: transfer of new tokens failed"
        );
    }

    /**
     * @return The address of the old Vision token contract.
     */
    function getOldTokenAddress() external view returns (address) {
        return _oldTokenAddress;
    }

    /**
     * @return The address of the new Vision token contract.
     */
    function getNewTokenAddress() external view returns (address) {
        return _newTokenAddress;
    }

    /**
     * @return True if the token migration has already started.
     */
    function isTokenMigrationStarted() external view returns (bool) {
        return _tokenMigrationStarted;
    }
}
