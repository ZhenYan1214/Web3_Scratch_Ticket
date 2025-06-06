// LuckyScratch.vue
<template>
  <div class="scratch-container">
    <!-- 連接錢包按鈕 -->
    <div v-if="!connected" class="wallet-section">
      <button @click="connectWallet" class="connect-btn">
        連接 MetaMask 錢包
      </button>
    </div>

    <!-- 主要遊戲界面 -->
    <div v-else class="game-section">
      <!-- 合約統計 -->
      <div class="stats-panel">
        <h3>獎池統計</h3>
        <p>總獎池: {{ contractStats.poolBalance }} ETH</p>
        <p>已售出: {{ contractStats.totalSupply }} 張</p>
        <p>單價: 0.01 ETH</p>
      </div>

      <!-- 購買按鈕 -->
      <div class="purchase-section">
        <button 
          @click="buyTicket" 
          :disabled="loading"
          class="buy-btn"
        >
          {{ loading ? '購買中...' : '購買刮刮樂 (0.01 ETH)' }}
        </button>
      </div>

      <!-- 我的刮刮樂 -->
      <div class="my-tickets">
        <h3>我的刮刮樂</h3>
        <div v-for="ticket in userTickets" :key="ticket.tokenId" class="ticket-card">
          <div class="ticket-info">
            <p>編號: #{{ ticket.tokenId }}</p>
            
            <!-- VRF Loading 狀態 -->
            <div v-if="ticket.randomNumber === '0'" class="vrf-loading">
              <div class="loading-spinner"></div>
              <p>正在生成隨機數...</p>
              <p>預計等待時間: 1-2 分鐘</p>
            </div>
            
            <!-- 準備揭曉 -->
            <div v-else-if="!ticket.revealed" class="ready-reveal">
              <p>🎲 隨機數: {{ ticket.randomNumber }}</p>
              <p>💰 潛在獎金: {{ ticket.potentialPrize }} ETH</p>
              <button @click="revealTicket(ticket.tokenId)" class="reveal-btn">
                揭曉獎項！
              </button>
            </div>
            
            <!-- 已揭曉 -->
            <div v-else class="revealed">
              <p>🏆 獎項: {{ getPrizeName(ticket.prize) }}</p>
              <p>💵 獲得: {{ ticket.wonAmount || '0' }} ETH</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading 遮罩 -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-content">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
      </div>
    </div>
  </div>
</template>

<script>
import { ethers } from 'ethers'

export default {
  name: 'LuckyScratch',
  data() {
    return {
      // 連接狀態
      connected: false,
      account: '',
      provider: null,
      signer: null,
      contract: null,
      
      // 載入狀態
      loading: false,
      loadingMessage: '',
      
      // 合約數據
      contractStats: {
        totalSupply: '0',
        poolBalance: '0',
        platformFee: '0'
      },
      
      // 用戶票券
      userTickets: [],
      
      // 合約配置
      contractAddress: '0x543c8622b80D87510C2473d99500197f9E483184',
      contractABI: [
        // 你的合約 ABI
        "function mint() payable returns (uint256)",
        "function reveal(uint256 tokenId)",
        "function getTokenInfo(uint256 tokenId) view returns (bool revealed, uint256 randomNumber, uint8 prize, uint256 potentialPrize)",
        "function getContractStats() view returns (uint256 totalSupply, uint256 currentPoolBalance, uint256 currentPlatformFee)",
        "function ownerOf(uint256 tokenId) view returns (address)",
        "function nextTokenId() view returns (uint256)",
        "event PrizeClaimed(address user, uint256 tokenId, uint8 prize, uint256 amount)"
      ]
    }
  },
  
  async mounted() {
    // 檢查是否已連接錢包
    if (window.ethereum) {
      const accounts = await window.ethereum.request({ method: 'eth_accounts' })
      if (accounts.length > 0) {
        await this.connectWallet()
      }
    }
  },
  
  methods: {
    // 連接錢包
    async connectWallet() {
      try {
        if (!window.ethereum) {
          alert('請安裝 MetaMask!')
          return
        }
        
        const accounts = await window.ethereum.request({ 
          method: 'eth_requestAccounts' 
        })
        
        this.provider = new ethers.providers.Web3Provider(window.ethereum)
        this.signer = this.provider.getSigner()
        this.account = accounts[0]
        this.connected = true
        
        // 初始化合約
        this.contract = new ethers.Contract(
          this.contractAddress, 
          this.contractABI, 
          this.signer
        )
        
        // 載入數據
        await this.loadContractStats()
        await this.loadUserTickets()
        
        // 開始監聽 VRF 更新
        this.startVRFMonitoring()
        
      } catch (error) {
        console.error('連接錢包失敗:', error)
        alert('連接錢包失敗!')
      }
    },
    
    // 購買刮刮樂
    async buyTicket() {
      try {
        this.loading = true
        this.loadingMessage = '正在購買刮刮樂...'
        
        const tx = await this.contract.mint({
          value: ethers.utils.parseEther('0.01')
        })
        
        this.loadingMessage = '等待交易確認...'
        await tx.wait()
        
        // 重新載入數據
        await this.loadContractStats()
        await this.loadUserTickets()
        
        alert('購買成功！請等待隨機數生成...')
        
      } catch (error) {
        console.error('購買失敗:', error)
        alert('購買失敗: ' + error.message)
      } finally {
        this.loading = false
      }
    },
    
    // 揭曉獎項
    async revealTicket(tokenId) {
      try {
        this.loading = true
        this.loadingMessage = '正在揭曉獎項...'
        
        const tx = await this.contract.reveal(tokenId)
        await tx.wait()
        
        // 重新載入數據
        await this.loadUserTickets()
        await this.loadContractStats()
        
        alert('獎項揭曉完成！')
        
      } catch (error) {
        console.error('揭曉失敗:', error)
        alert('揭曉失敗: ' + error.message)
      } finally {
        this.loading = false
      }
    },
    
    // 載入合約統計
    async loadContractStats() {
      try {
        const stats = await this.contract.getContractStats()
        this.contractStats = {
          totalSupply: stats[0].toString(),
          poolBalance: ethers.utils.formatEther(stats[1]),
          platformFee: ethers.utils.formatEther(stats[2])
        }
      } catch (error) {
        console.error('載入統計失敗:', error)
      }
    },
    
    // 載入用戶票券
    async loadUserTickets() {
      try {
        const nextTokenId = await this.contract.nextTokenId()
        const tickets = []
        
        // 檢查所有已發行的票券
        for (let i = 1; i < nextTokenId; i++) {
          try {
            const owner = await this.contract.ownerOf(i)
            if (owner.toLowerCase() === this.account.toLowerCase()) {
              const info = await this.contract.getTokenInfo(i)
              tickets.push({
                tokenId: i,
                revealed: info[0],
                randomNumber: info[1].toString(),
                prize: info[2],
                potentialPrize: ethers.utils.formatEther(info[3])
              })
            }
          } catch (error) {
            // 票券可能不存在，跳過
          }
        }
        
        this.userTickets = tickets
      } catch (error) {
        console.error('載入票券失敗:', error)
      }
    },
    
    // VRF 監聽 (定期檢查隨機數更新)
    startVRFMonitoring() {
      setInterval(async () => {
        // 檢查是否有票券還在等待隨機數
        const waitingTickets = this.userTickets.filter(t => t.randomNumber === '0')
        if (waitingTickets.length > 0) {
          await this.loadUserTickets()
        }
      }, 10000) // 每10秒檢查一次
    },
    
    // 獎項名稱轉換
    getPrizeName(prizeNumber) {
      const prizeNames = ["沒中獎", "安慰獎", "二獎", "一獎", "大獎"]
      return prizeNames[prizeNumber] || '未知'
    }
  }
}
</script>

<style scoped>
.scratch-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.connect-btn, .buy-btn, .reveal-btn {
  background: linear-gradient(45deg, #ff6b6b, #ee5a24);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 16px;
}

.connect-btn:hover, .buy-btn:hover, .reveal-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
}

.stats-panel {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.ticket-card {
  border: 2px solid #ddd;
  border-radius: 8px;
  padding: 16px;
  margin: 10px 0;
  background: white;
}

.vrf-loading {
  text-align: center;
  color: #007bff;
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid #f3f3f3;
  border-top: 2px solid #007bff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 10px;
}

.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.loading-content {
  background: white;
  padding: 30px;
  border-radius: 8px;
  text-align: center;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #007bff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 15px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.ready-reveal {
  background: #e8f5e8;
  padding: 10px;
  border-radius: 4px;
}

.revealed {
  background: #f0f8ff;
  padding: 10px;
  border-radius: 4px;
}
</style>