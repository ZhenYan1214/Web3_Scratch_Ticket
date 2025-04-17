// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./YearnConnector.sol";

contract PiggyVault is ERC4626, Ownable {
    using SafeERC20 for IERC20;

    YearnConnector public yearnConnector;
    IERC20 public immutable underlying;

    constructor(
        IERC20 _underlying,
        string memory name,
        string memory symbol
    ) ERC4626(_underlying) ERC20(name, symbol) Ownable(msg.sender) {
        underlying = _underlying;
    }

    function setYearnConnector(address _yearnConnector) external onlyOwner {
        yearnConnector = YearnConnector(_yearnConnector);
    }

    function totalAssets() public view virtual override returns (uint256) {
        if (address(yearnConnector) == address(0)) {
            return underlying.balanceOf(address(this));
        }
        return underlying.balanceOf(address(this)) + yearnConnector.balanceOf(address(this));
    }

    function _deposit(
        address caller,
        address receiver,
        uint256 assets,
        uint256 shares
    ) internal virtual override {
        // Transfer assets from caller to this contract
        super._deposit(caller, receiver, assets, shares);
        
        // Deposit assets into Yearn if connector is set
        if (address(yearnConnector) != address(0)) {
            underlying.safeApprove(address(yearnConnector), assets);
            yearnConnector.deposit(assets);
        }
    }

    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal virtual override {
        // Withdraw assets from Yearn if needed
        if (address(yearnConnector) != address(0)) {
            uint256 vaultBalance = underlying.balanceOf(address(this));
            if (vaultBalance < assets) {
                yearnConnector.withdraw(assets - vaultBalance);
            }
        }
        
        // Transfer assets to receiver
        super._withdraw(caller, receiver, owner, assets, shares);
    }
} 