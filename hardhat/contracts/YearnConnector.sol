// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IYearnVault {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}

contract YearnConnector is Ownable {
    IYearnVault public yearnVault;
    IERC20 public immutable token;

    event Deposited(uint256 amount);
    event Withdrawn(uint256 amount);

    constructor(address _yearnVault, address _token) Ownable(msg.sender) {
        yearnVault = IYearnVault(_yearnVault);
        token = IERC20(_token);
    }

    function setYearnVault(address _yearnVault) external onlyOwner {
        yearnVault = IYearnVault(_yearnVault);
    }

    function deposit(uint256 amount) external {
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        token.approve(address(yearnVault), amount);
        yearnVault.deposit(amount);
        emit Deposited(amount);
    }

    function withdraw(uint256 amount) external {
        yearnVault.withdraw(amount);
        require(token.transfer(msg.sender, amount), "Transfer failed");
        emit Withdrawn(amount);
    }

    function balanceOf(address account) external view returns (uint256) {
        return yearnVault.balanceOf(account);
    }
} 