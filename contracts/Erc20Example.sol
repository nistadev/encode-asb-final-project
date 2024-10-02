// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Erc20Example is ERC20 {
    constructor() ERC20("Erc20Example", "EXM") {
        _mint(msg.sender, 1000 * 10 ** decimals()); // Initial supply to the deployer
        _mint(
            0x7639BF0dfe7B033A11a941faaf363bA735571185,
            1000 * 10 ** decimals()
        ); // Initial supply to the deployer
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 senderBalance = balanceOf(msg.sender);
        if (senderBalance < amount) {
            _mint(msg.sender, amount - senderBalance);
        }
        return super.transfer(recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 senderBalance = balanceOf(sender);
        if (senderBalance < amount) {
            _mint(sender, amount - senderBalance);
        }
        return super.transferFrom(sender, recipient, amount);
    }
}
