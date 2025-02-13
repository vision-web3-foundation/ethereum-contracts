// SPDX-License-Identifier: GPL-3.0
// slither-disable-next-line solc-version
pragma solidity 0.8.26;

import {VisionBaseToken} from "./VisionBaseToken.sol";

/**
 * @title Vision-compatible simple token
 */
contract VisionSimpleToken is VisionBaseToken {
    /**
     * @dev msg.sender receives all existing tokens.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply,
        address visionForwarder
    ) VisionBaseToken(name_, symbol_, decimals_, msg.sender) {
        _mint(msg.sender, initialSupply);
        _setVisionForwarder(visionForwarder);
    }
}
