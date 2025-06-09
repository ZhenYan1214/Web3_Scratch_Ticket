const hre = require("hardhat");
const { ethers } = hre;

// 配置
const CONFIG = {
    contractAddress: '0x16E8D265dd429E8592A98188c74FE7ba75648818',
    // 使用 Hardhat 配置的網路，不需要額外設定 RPC
    privateKey: process.env.PRIVATE_KEY, // 請替換成你的私鑰，或使用 Hardhat 帳戶
};

// 合約 ABI (簡化版，包含測試需要的函數)
const CONTRACT_ABI = [
    // 讀取函數
    "function nextTokenId() view returns (uint256)",
    "function poolBalance() view returns (uint256)",
    "function platformFee() view returns (uint256)",
    "function ownerOf(uint256 tokenId) view returns (address)",
    "function tokenIdToRandomNumber(uint256) view returns (uint256)",
    "function tokenIdToPrize(uint256) view returns (uint8)",
    "function isRevealed(uint256) view returns (bool)",
    "function getTokenInfo(uint256 tokenId) view returns (bool revealed, uint256 randomNumber, uint8 prize, uint256 potentialPrize)",    
    // 寫入函數
    "function mint() payable returns (uint256)",
    "function reveal(uint256 tokenId)",
    "function addToPool() payable",
    "function withdrawFee(address payable to, uint256 amount)",
    "function withdrawNative(uint256 amount)",
    
    // 事件
    "event PrizeClaimed(address user, uint256 tokenId, uint8 prize, uint256 amount)",
    "event RequestSent(uint256 requestId, uint32 numWords)",
    "event RequestFulfilled(uint256 requestId, uint256[] randomWords, uint256 payment)"
];

class ContractTester {
    constructor() {
        // 使用 Hardhat 的 provider 和 signers
        this.provider = hre.ethers.provider;
        this.testResults = [];
    }

    async initialize() {
        // 獲取 signers
        const signers = await hre.ethers.getSigners();
        this.signer = signers[0]; // 使用第一個帳戶
        
        // 如果提供了私鑰，使用私鑰創建 wallet
        if (CONFIG.privateKey && CONFIG.privateKey !== 'YOUR_PRIVATE_KEY') {
            this.signer = new hre.ethers.Wallet(CONFIG.privateKey, this.provider);
        }
        
        this.contract = new hre.ethers.Contract(CONFIG.contractAddress, CONTRACT_ABI, this.signer);
        
        // 顯示使用的地址
        await this.log("🔑 使用地址:", await this.signer.getAddress());
    }

    // 工具函數
    formatEther(wei) {
        return hre.ethers.utils ? hre.ethers.utils.formatEther(wei) : hre.ethers.formatEther(wei);
    }

    parseEther(eth) {
        return hre.ethers.utils ? hre.ethers.utils.parseEther(eth) : hre.ethers.parseEther(eth);
    }

    async log(message, data = null) {
        const timestamp = new Date().toLocaleTimeString();
        console.log(`[${timestamp}] ${message}`);
        if (data) console.log(data);
        this.testResults.push({ timestamp, message, data });
    }

    async delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    async testAddToPool() {
        await this.log("💰 測試添加資金到獎池...");
        try {
            const amount = "0.01"; 
            const tx = await this.contract.addToPool({
                value: this.parseEther(amount)
            });
            await this.log("⏳ 等待交易確認...", { txHash: tx.hash });
            
            const receipt = await tx.wait();
            await this.log("✅ 成功添加資金到獎池:", {
                amount: amount + " ETH",
                gasUsed: receipt.gasUsed.toString()
            });
            return true;
        } catch (error) {
            await this.log("❌ 添加資金失敗:", error.message);
            return false;
        }
    }

    async testMint() {
        await this.log("🎫 測試購買刮刮樂...");
        try {
            const tx = await this.contract.mint({
                value: this.parseEther("0.01") // 0.01 ETH
            });
            await this.log("⏳ 等待交易確認...", { txHash: tx.hash });
            
            const receipt = await tx.wait();
            const nextTokenId = await this.contract.nextTokenId();
            const tokenId = nextTokenId.sub ? nextTokenId.sub(1) : nextTokenId - 1n; // 兼容不同版本
            
            await this.log("✅ 成功購買刮刮樂:", {
                tokenId: tokenId.toString(),
                gasUsed: receipt.gasUsed.toString()
            });
            return tokenId;
        } catch (error) {
            await this.log("❌ 購買刮刮樂失敗:", error.message);
            return null;
        }
    }

    async testTokenInfo(tokenId) {
        await this.log(`🔍 測試查詢代幣 #${tokenId} 信息...`);
        try {
            const info = await this.contract.getTokenInfo(tokenId);
            const prizeNames = ["None", "Consolation", "Second", "First", "Grand"];
            
            await this.log("✅ 代幣信息:", {
                tokenId: tokenId.toString(),
                revealed: info[0],
                randomNumber: info[1].toString(),
                prize: prizeNames[info[2]] || "Unknown",
                potentialPrize: this.formatEther(info[3]) + " ETH"
            });
            return info;
        } catch (error) {
            await this.log("❌ 查詢代幣信息失敗:", error.message);
            return null;
        }
    }

    async waitForRandomNumber(tokenId, maxWaitTime = 120000) {
        await this.log(`⏰ 等待 VRF 隨機數生成 (最多等待 ${maxWaitTime/1000} 秒)...`);
        
        const startTime = Date.now();
        while (Date.now() - startTime < maxWaitTime) {
            try {
                const randomNumber = await this.contract.tokenIdToRandomNumber(tokenId);
                const isZero = randomNumber.eq ? randomNumber.eq(0) : randomNumber === 0n;
                
                if (!isZero) {
                    await this.log("✅ VRF 隨機數已生成:", {
                        tokenId: tokenId.toString(),
                        randomNumber: randomNumber.toString()
                    });
                    return true;
                }
                await this.delay(5000); // 每5秒檢查一次
                process.stdout.write(".");
            } catch (error) {
                await this.log("❌ 檢查隨機數時出錯:", error.message);
                break;
            }
        }
        
        await this.log("⏰ 等待隨機數超時");
        return false;
    }

    async testReveal(tokenId) {
        await this.log(`🎁 測試揭曉獎項 #${tokenId}...`);
        try {
            // 檢查是否已經揭曉
            const isRevealed = await this.contract.isRevealed(tokenId);
            if (isRevealed) {
                await this.log("ℹ️ 該代幣已經揭曉過了");
                return false;
            }

            // 檢查隨機數是否準備好
            const randomNumber = await this.contract.tokenIdToRandomNumber(tokenId);
            const isZero = randomNumber.eq ? randomNumber.eq(0) : randomNumber === 0n;
            
            if (isZero) {
                await this.log("⏳ 隨機數尚未準備好，請稍後再試");
                return false;
            }

            const tx = await this.contract.reveal(tokenId);
            await this.log("⏳ 等待揭曉交易確認...", { txHash: tx.hash });
            
            const receipt = await tx.wait();
            
            // 查看事件日誌
            const prizeClaimedEvent = receipt.events ? 
                receipt.events.find(event => event.event === 'PrizeClaimed') :
                receipt.logs.find(log => {
                    try {
                        const parsed = this.contract.interface.parseLog(log);
                        return parsed.name === 'PrizeClaimed';
                    } catch {
                        return false;
                    }
                });

            if (prizeClaimedEvent) {
                const args = prizeClaimedEvent.args || this.contract.interface.parseLog(prizeClaimedEvent).args;
                const prizeNames = ["None", "Consolation", "Second", "First", "Grand"];
                
                await this.log("🎉 獎項揭曉成功:", {
                    tokenId: args.tokenId.toString(),
                    prize: prizeNames[args.prize] || "Unknown",
                    amount: this.formatEther(args.amount) + " ETH",
                    gasUsed: receipt.gasUsed.toString()
                });
                return args.amount;
            } else {
                await this.log("✅ 揭曉完成但未找到獎項事件");
                return 0;
            }
        } catch (error) {
            await this.log("❌ 揭曉獎項失敗:", error.message);
            return null;
        }
    }

    async testFullWorkflow() {
        await this.log("🚀 開始完整測試流程...");
        await this.log("=".repeat(50));

        // 1. 添加資金到獎池（如果是合約擁有者）
        try {
            await this.testAddToPool();
            await this.delay(2000);
        } catch (error) {
            await this.log("ℹ️ 跳過添加獎池資金 (可能不是合約擁有者)");
        }

        // 2. 購買刮刮樂
        const tokenId = await this.testMint();
        if (!tokenId) return;

        await this.delay(2000);

        // 3. 等待隨機數生成
        const randomNumberReady = await this.waitForRandomNumber(tokenId);
        if (!randomNumberReady) {
            await this.log("❌ 隨機數生成超時");
            return;
        }

        await this.delay(2000);

        // 4. 查詢代幣信息
        await this.testTokenInfo(tokenId);
        await this.delay(2000);

        // 5. 揭曉獎項
        await this.testReveal(tokenId);

        await this.log("=".repeat(50));
        await this.log("✅ 測試流程完成");
    }

    async generateReport() {
        await this.log("\n📊 測試報告");
        await this.log("=".repeat(50));
        
        for (const result of this.testResults) {
            console.log(`[${result.timestamp}] ${result.message}`);
            if (result.data) console.log(result.data);
        }
    }
}

async function main() {
    const tester = new ContractTester();
    await tester.initialize();
    await tester.testFullWorkflow();
    await tester.generateReport();
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ 測試過程中發生嚴重錯誤:", error);
        process.exit(1);
    });

module.exports = { ContractTester };