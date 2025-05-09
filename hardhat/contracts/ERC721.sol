// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IERC4626 {
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares);
    
    function asset() external view returns (address);
    function totalAssets() external view returns (uint256);
    function convertToShares(uint256 assets) external view returns (uint256);
    function convertToAssets(uint256 shares) external view returns (uint256);
    function maxDeposit(address receiver) external view returns (uint256);
    function maxMint(address receiver) external view returns (uint256);
    function maxWithdraw(address owner) external view returns (uint256);
    function maxRedeem(address owner) external view returns (uint256);
    function previewDeposit(uint256 assets) external view returns (uint256);
    function previewMint(uint256 shares) external view returns (uint256);
    function previewWithdraw(uint256 assets) external view returns (uint256);
    function previewRedeem(uint256 shares) external view returns (uint256);
    function deposit(uint256 assets, address receiver) external returns (uint256);
    function mint(uint256 shares, address receiver) external returns (uint256);
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256);
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256);
}

interface IPool {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
    function getReserveData(address asset) external view returns (
        uint256 configuration,
        uint128 liquidityIndex,
        uint128 currentLiquidityRate,
        uint128 variableBorrowIndex,
        uint128 currentVariableBorrowRate,
        uint128 currentStableBorrowRate,
        uint40 lastUpdateTimestamp,
        uint16 id,
        address aTokenAddress,
        address stableDebtTokenAddress,
        address variableDebtTokenAddress,
        address interestRateStrategyAddress,
        uint8 accruedToTreasury,
        uint128 unbacked,
        uint128 isolationModeTotalDebt
    );
}

interface IAToken {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract ERC4626 is IERC4626 {
    // 事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Harvest(uint256 amount);

    // 狀態變量
    IERC20 private immutable _asset;
    IPool public immutable pool;
    IAToken public immutable aToken;
    string public name;
    string public symbol;
    uint8 public decimals;
    
    // 模擬收益相關變量（僅用於演示，實際收益來自 Aave）
    uint256 private _lastUpdateTime;
    uint256 private _accumulatedRewards;
    uint256 private _lastRewardPerShare;
    mapping(address => uint256) private _rewardDebt;
    
    // 模擬年化收益率（基點，1 基點 = 0.01%）
    uint256 public constant REWARD_RATE = 500; // 5% 模擬年化收益率
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    
    // Sepolia 測試網配置
    // Aave V3 Pool: 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951
    // 測試代幣地址:
    // USDC: 0xda9dfa130df4de4673b89022ee50ff26f6ea73cf
    // DAI: 0x68194a729c2450ad26072b3d33adacbcef39d574
    // WETH: 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9
    // 對應的 aToken 地址:
    // aUSDC: 0x3355df6D4c9C3035724Fd0e3914dE96A5a83aaf4
    // aDAI: 0x0c7cF94f2A98C577cbfd1f0E7C87CA60bA9CF881
    // aWETH: 0x5b071b590a59395fE4025A0C5D8B247Fc549f9e5

    constructor(
        address asset_,
        address pool_,
        address aToken_,
        string memory name_,
        string memory symbol_
    ) {
        require(pool_ == 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951, "Invalid pool address");
        _asset = IERC20(asset_);
        pool = IPool(pool_);
        aToken = IAToken(aToken_);
        name = name_;
        symbol = symbol_;
        decimals = 18;
        _lastUpdateTime = block.timestamp;
        
        // 授權 Aave Pool 使用資產
        _asset.approve(address(pool), type(uint256).max);
    }

    // 計算收益份額
    function _calculateRewardShare(uint256 assets, uint256 timeElapsed) internal pure returns (uint256) {
        return (assets * REWARD_RATE * timeElapsed) / (365 days * 10000);
    }

    // 更新模擬收益（僅用於演示）
    function _updateRewards() internal {
        if (block.timestamp <= _lastUpdateTime) return;
        
        uint256 timeElapsed = block.timestamp - _lastUpdateTime;
        uint256 currentAssets = aToken.balanceOf(address(this));
        
        if (currentAssets > 0 && totalSupply() > 0) {
            uint256 newRewards = _calculateRewardShare(currentAssets, timeElapsed);
            _accumulatedRewards += newRewards;
            _lastRewardPerShare += (newRewards * 1e18) / totalSupply();
        }
        
        _lastUpdateTime = block.timestamp;
    }
    
    // 計算待領取模擬收益（僅用於演示）
    function pendingRewards(address account) public view returns (uint256) {
        if (totalSupply() == 0) return 0;
        
        uint256 currentRewardPerShare = _lastRewardPerShare;
        if (block.timestamp > _lastUpdateTime) {
            uint256 timeElapsed = block.timestamp - _lastUpdateTime;
            uint256 currentAssets = aToken.balanceOf(address(this));
            if (currentAssets > 0) {
                uint256 newRewards = _calculateRewardShare(currentAssets, timeElapsed);
                currentRewardPerShare += (newRewards * 1e18) / totalSupply();
            }
        }
        
        return (balanceOf(account) * currentRewardPerShare / 1e18) - _rewardDebt[account];
    }
    
    // 領取模擬收益（僅用於演示）
    function harvest() public {
        _updateRewards();
        uint256 pending = pendingRewards(msg.sender);
        require(pending > 0, "No rewards to harvest");
        
        _rewardDebt[msg.sender] = (balanceOf(msg.sender) * _lastRewardPerShare) / 1e18;
        require(_asset.transfer(msg.sender, pending), "Reward transfer failed");
        
        emit Harvest(pending);
    }

    // 實現 IERC4626 的 asset() 函數
    function asset() public view override returns (address) {
        return address(_asset);
    }
    
    // ERC20 基本功能
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transfer(address to, uint256 amount) public returns (bool) {
        if (amount == 0) return true;
        
        _updateRewards();
        _rewardDebt[msg.sender] = (balanceOf(msg.sender) * _lastRewardPerShare) / 1e18;
        _rewardDebt[to] = (balanceOf(to) * _lastRewardPerShare) / 1e18;
        
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        if (amount == 0) return true;
        
        _updateRewards();
        _rewardDebt[from] = (balanceOf(from) * _lastRewardPerShare) / 1e18;
        _rewardDebt[to] = (balanceOf(to) * _lastRewardPerShare) / 1e18;
        
        require(_allowances[from][msg.sender] >= amount, "ERC4626: transfer amount exceeds allowance");
        _allowances[from][msg.sender] -= amount;
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
    
    // ERC4626 核心功能
    function totalAssets() public view override returns (uint256) {
        return aToken.balanceOf(address(this));
    }
    
    function convertToShares(uint256 assets) public view override returns (uint256) {
        uint256 supply = totalSupply();
        return supply == 0 ? assets : assets * supply / totalAssets();
    }
    
    function convertToAssets(uint256 shares) public view override returns (uint256) {
        uint256 supply = totalSupply();
        return supply == 0 ? shares : shares * totalAssets() / supply;
    }
    
    function deposit(uint256 assets, address receiver) public override returns (uint256) {
        _updateRewards();
        uint256 shares = convertToShares(assets);
        require(_asset.transferFrom(msg.sender, address(this), assets), "Transfer failed");
        
        // 存入 Aave
        pool.supply(address(_asset), assets, address(this), 0);
        
        _mint(receiver, shares);
        _rewardDebt[receiver] = (balanceOf(receiver) * _lastRewardPerShare) / 1e18;
        emit Deposit(msg.sender, receiver, assets, shares);
        return shares;
    }
    
    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256) {
        _updateRewards();
        uint256 shares = convertToShares(assets);
        if (msg.sender != owner) {
            require(_allowances[owner][msg.sender] >= shares, "ERC4626: withdraw amount exceeds allowance");
            _allowances[owner][msg.sender] -= shares;
        }
        _burn(owner, shares);
        
        // 從 Aave 提取
        pool.withdraw(address(_asset), assets, receiver);
        
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        return shares;
    }
    
    function _mint(address account, uint256 amount) internal {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    
    function _burn(address account, uint256 amount) internal {
        require(_balances[account] >= amount, "ERC4626: burn amount exceeds balance");
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    
    // ERC4626 輔助功能
    function mint(uint256 shares, address receiver) public override returns (uint256) {
        _updateRewards();
        uint256 assets = convertToAssets(shares);
        require(_asset.transferFrom(msg.sender, address(this), assets), "Transfer failed");
        
        // 存入 Aave
        pool.supply(address(_asset), assets, address(this), 0);
        
        _mint(receiver, shares);
        _rewardDebt[receiver] = (balanceOf(receiver) * _lastRewardPerShare) / 1e18;
        emit Deposit(msg.sender, receiver, assets, shares);
        return assets;
    }
    
    function redeem(uint256 shares, address receiver, address owner) public override returns (uint256) {
        _updateRewards();
        uint256 assets = convertToAssets(shares);
        if (msg.sender != owner) {
            require(_allowances[owner][msg.sender] >= shares, "ERC4626: redeem amount exceeds allowance");
            _allowances[owner][msg.sender] -= shares;
        }
        _burn(owner, shares);
        
        // 從 Aave 提取
        pool.withdraw(address(_asset), assets, receiver);
        
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        return assets;
    }
    
    function maxDeposit(address) public pure override returns (uint256) {
        return type(uint256).max;
    }
    
    function maxMint(address) public pure override returns (uint256) {
        return type(uint256).max;
    }
    
    function maxWithdraw(address owner) public view override returns (uint256) {
        return convertToAssets(balanceOf(owner));
    }
    
    function maxRedeem(address owner) public view override returns (uint256) {
        return balanceOf(owner);
    }
    
    function previewDeposit(uint256 assets) public view override returns (uint256) {
        return convertToShares(assets);
    }
    
    function previewMint(uint256 shares) public view override returns (uint256) {
        return convertToAssets(shares);
    }
    
    function previewWithdraw(uint256 assets) public view override returns (uint256) {
        return convertToShares(assets);
    }
    
    function previewRedeem(uint256 shares) public view override returns (uint256) {
        return convertToAssets(shares);
    }
    
    // 獲取 Aave 當前估算年化收益率（僅供參考，實際收益可能有所不同）
    function getCurrentAPY() public view returns (uint256) {
        (, , uint128 rate,,,,,,,,,,,,) = pool.getReserveData(address(_asset));
        return uint256(rate) / 1e9; // 轉換為百分比，此為估算值
    }
}
