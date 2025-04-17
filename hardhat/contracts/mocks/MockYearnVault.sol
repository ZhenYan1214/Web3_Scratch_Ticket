// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MockYearnVault {
    using SafeERC20 for IERC20;

    IERC20 public token;
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function deposit(uint256 amount) external returns (uint256) {
        token.safeTransferFrom(msg.sender, address(this), amount);
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        return amount;
    }

    function withdraw(uint256 amount) external returns (uint256) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        token.safeTransfer(msg.sender, amount);
        return amount;
    }

    function pricePerShare() external pure returns (uint256) {
        return 1e18; // 1:1 ratio for testing
    }
} 