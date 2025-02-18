// SPDX-License-Identifier: GPL-3.0
// slither-disable-next-line solc-version
pragma solidity 0.8.26;

import {VisionCoinWrapper} from "../VisionCoinWrapper.sol";

/**
 * @title Vision-compatible token contract that wraps the Polygon
 * blockchain network's POL coin
 */
contract VisionPolWrapper is VisionCoinWrapper {
    string private constant _NAME = "POL (Vision)";

    string private constant _SYMBOL = "vsnPOL";

    uint8 private constant _DECIMALS = 18;

    constructor(
        bool native,
        address accessControllerAddress
    )
        VisionCoinWrapper(
            _NAME,
            _SYMBOL,
            _DECIMALS,
            native,
            accessControllerAddress
        )
    {}
}
