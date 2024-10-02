// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error NotAuthorized();

contract CreatorPoints is ERC20 {
    address public platformAddress;
    address public creatorAddress;

    constructor(
        address _platformAddress,
        address _creatorAddress
    ) ERC20("CreatorPoints", "CPT") {
        platformAddress = _platformAddress;
        creatorAddress = _creatorAddress;
    }

    function rewardUser(address user, uint256 amount) external {
        // Only the platform or creator can reward points
        require(
            msg.sender == platformAddress || msg.sender == creatorAddress,
            NotAuthorized()
        );

        _mint(user, amount);
    }

    function burnPoints(address user, uint256 amount) external {
        // Points can be burned by the platform/creator (e.g., when points are redeemed)
        require(
            msg.sender == platformAddress || msg.sender == creatorAddress,
            NotAuthorized()
        );

        _burn(user, amount);
    }
}
