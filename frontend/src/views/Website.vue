<template>
  <div class="min-h-screen bg-gradient-to-br from-red-700 via-red-800 to-purple-900 relative overflow-hidden">
    <!-- 動態背景效果 -->
    <div class="absolute inset-0">
      <!-- 光暈效果 -->
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_50%_50%,rgba(255,215,0,0.15),transparent_70%)] animate-pulse"></div>
      
      <!-- 浮動的金幣和符號 -->
      <div class="coins-container">
        <div v-for="i in 30" :key="i" class="coin-symbol" :style="{
          left: `${Math.random() * 100}%`,
          top: `${Math.random() * 100}%`,
          animationDelay: `${Math.random() * 10}s`,
          fontSize: `${Math.random() * 20 + 20}px`
        }">
          {{ ['💰', '🪙', '💎', '✨'][Math.floor(Math.random() * 4)] }}
        </div>
      </div>

      <!-- 福字裝飾 -->
      <div class="absolute top-10 left-10 transform -rotate-12 opacity-20 text-8xl text-yellow-500 animate-float-slow">福</div>
      <div class="absolute bottom-10 right-10 transform rotate-12 opacity-20 text-8xl text-yellow-500 animate-float-slow">財</div>
    </div>

    <!-- 主要內容 -->
    <div class="relative z-10 container mx-auto px-4 py-12 min-h-screen flex flex-col items-center justify-center">
      <!-- Logo 區域 -->
      <div class="text-center mb-16 transform hover:scale-105 transition-transform duration-500">
        <div class="relative inline-block">
          <h1 class="text-7xl md:text-8xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-yellow-400 via-yellow-300 to-yellow-400 mb-6 animate-title-shine">
            財神存錢罐
          </h1>
          <div class="absolute -inset-1 bg-gradient-to-r from-yellow-400 to-red-600 opacity-30 blur"></div>
        </div>
        <p class="text-2xl md:text-3xl text-red-100 font-medium mt-4 animate-fade-in">
          Web3 時代的智能理財新選擇
        </p>
      </div>

      <!-- 特色卡片 -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-16 w-full max-w-6xl">
        <div class="feature-card group" data-aos="fade-up" data-aos-delay="100">
          <div class="card-content">
            <div class="icon-wrapper">
              <span class="text-5xl mb-6 group-hover:scale-110 transition-transform duration-300">🔒</span>
            </div>
            <h3 class="text-xl font-bold mb-3 text-yellow-300">安全可靠</h3>
            <p class="text-red-100">智能合約審計，資產安全無憂</p>
          </div>
          <div class="card-glow"></div>
        </div>

        <div class="feature-card group" data-aos="fade-up" data-aos-delay="200">
          <div class="card-content">
            <div class="icon-wrapper">
              <span class="text-5xl mb-6 group-hover:scale-110 transition-transform duration-300">💰</span>
            </div>
            <h3 class="text-xl font-bold mb-3 text-yellow-300">收益豐厚</h3>
            <p class="text-red-100">DeFi 收益優化，財運滾滾來</p>
          </div>
          <div class="card-glow"></div>
        </div>

        <div class="feature-card group" data-aos="fade-up" data-aos-delay="300">
          <div class="card-content">
            <div class="icon-wrapper">
              <span class="text-5xl mb-6 group-hover:scale-110 transition-transform duration-300">🚀</span>
            </div>
            <h3 class="text-xl font-bold mb-3 text-yellow-300">創新科技</h3>
            <p class="text-red-100">區塊鏈技術，引領未來理財</p>
          </div>
          <div class="card-glow"></div>
        </div>
      </div>

      <!-- 連接錢包按鈕區域 -->
      <div class="text-center space-y-6" data-aos="fade-up" data-aos-delay="400">
        <button 
          @click="connectWallet" 
          :disabled="isConnecting"
          class="wallet-btn group"
        >
          <div class="wallet-btn-background"></div>
          <div class="wallet-btn-content">
            <span class="icon">{{ isConnecting ? '⏳' : '🧧' }}</span>
            <span class="text">{{ isConnecting ? '連接中...' : '連接錢包開運' }}</span>
          </div>
        </button>
        
        <!-- 錯誤訊息 -->
        <div v-if="errorMessage" class="error-message">
          <span class="icon">⚠️</span>
          <span>{{ errorMessage }}</span>
        </div>
        
        <p class="connect-hint">連接錢包後開始您的財運之旅</p>
      </div>

      <!-- 底部資訊 -->
      <div class="absolute bottom-8 left-0 right-0 text-center">
        <div class="special-offer">
          <span class="icon">🎁</span>
          <span class="text">新年限定：連接錢包即可參與 888 ETH 限時空投</span>
          <span class="icon">🎁</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ethers } from 'ethers'

const router = useRouter()
const isConnecting = ref(false)
const errorMessage = ref('')

const connectWallet = async () => {
  try {
    isConnecting.value = true
    errorMessage.value = ''

    // 檢查是否有 MetaMask
    if (typeof window.ethereum === 'undefined') {
      throw new Error('請先安裝 MetaMask 錢包！點擊這裡安裝：https://metamask.io/')
    }

    // 使用 window.ethereum 作為 provider
    const provider = new ethers.BrowserProvider(window.ethereum)

    try {
      // 請求用戶切換到 Goerli 測試網
      await window.ethereum.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: '0x5' }]
      })
    } catch (switchError) {
      if (switchError.code === 4902) {
        try {
          await window.ethereum.request({
            method: 'wallet_addEthereumChain',
            params: [{
              chainId: '0x5',
              chainName: 'Goerli Test Network',
              nativeCurrency: {
                name: 'ETH',
                symbol: 'ETH',
                decimals: 18
              },
              rpcUrls: ['https://goerli.infura.io/v3/'],
              blockExplorerUrls: ['https://goerli.etherscan.io']
            }]
          })
        } catch (addError) {
          throw new Error('無法添加網絡，請手動切換到 Goerli 測試網')
        }
      }
    }

    // 請求連接錢包
    const accounts = await window.ethereum.request({ 
      method: 'eth_requestAccounts' 
    })

    if (!accounts || accounts.length === 0) {
      throw new Error('未能獲取錢包地址，請確保授權訪問')
    }

    // 獲取簽名者
    const signer = await provider.getSigner()
    const address = accounts[0]

    // 存儲錢包地址
    localStorage.setItem('walletAddress', address)

    // 監聽錢包事件
    window.ethereum.on('accountsChanged', (newAccounts) => {
      if (!newAccounts.length) {
        localStorage.removeItem('walletAddress')
        router.push('/')
      }
    })

    window.ethereum.on('chainChanged', () => {
      window.location.reload()
    })

    // 跳轉到主頁
    await router.push('/home')
  } catch (error) {
    console.error('連接錢包失敗:', error)
    if (error.code === 4001) {
      errorMessage.value = '您拒絕了連接請求，請重試'
    } else if (error.code === -32002) {
      errorMessage.value = '請檢查 MetaMask 彈窗並確認連接'
    } else {
      errorMessage.value = error.message || '連接錢包失敗，請稍後再試'
    }
  } finally {
    isConnecting.value = false
  }
}

// 檢查是否已經連接
onMounted(async () => {
  try {
    if (window.ethereum) {
      const accounts = await window.ethereum.request({
        method: 'eth_accounts'
      })
      if (accounts.length > 0) {
        await router.push('/home')
      }
    }
  } catch (error) {
    console.error('檢查錢包狀態失敗:', error)
  }

  // 添加入場動畫
  document.querySelectorAll('[data-aos]').forEach(element => {
    element.classList.add('aos-animate')
  })
})
</script>

<style scoped>
/* 動畫關鍵幀 */
@keyframes float {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  50% { transform: translateY(-20px) rotate(5deg); }
}

@keyframes shine {
  0% { background-position: -200% center; }
  100% { background-position: 200% center; }
}

@keyframes pulse-glow {
  0%, 100% { opacity: 0.6; }
  50% { opacity: 1; }
}

@keyframes coin-float {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  50% { transform: translateY(-100px) rotate(180deg); }
}

/* 基礎樣式 */
.feature-card {
  @apply relative bg-gradient-to-br from-red-900/40 to-purple-900/40 p-8 rounded-2xl backdrop-blur-sm border border-red-500/30 text-center transform transition-all duration-500 hover:scale-105 overflow-hidden;
}

.card-content {
  @apply relative z-10;
}

.card-glow {
  @apply absolute inset-0 bg-gradient-to-r from-yellow-500/20 to-red-500/20 opacity-0 transition-opacity duration-300;
}

.feature-card:hover .card-glow {
  @apply opacity-100;
}

.icon-wrapper {
  @apply flex justify-center items-center mb-4;
}

/* 錢包按鈕樣式 */
.wallet-btn {
  @apply relative inline-flex items-center px-8 py-4 rounded-xl cursor-pointer transform transition-all duration-300 hover:scale-105 disabled:opacity-70 disabled:cursor-not-allowed;
}

.wallet-btn-background {
  @apply absolute inset-0 bg-gradient-to-r from-yellow-400 via-yellow-500 to-yellow-400 rounded-xl border-2 border-red-700/50 transition-all duration-300;
  background-size: 200% auto;
  animation: shine 3s linear infinite;
}

.wallet-btn-content {
  @apply relative flex items-center justify-center text-red-900 text-xl font-bold;
}

.wallet-btn-content .icon {
  @apply mr-2 text-2xl;
}

/* 錯誤訊息樣式 */
.error-message {
  @apply flex items-center justify-center space-x-2 text-red-300 bg-red-900/50 px-6 py-3 rounded-xl backdrop-blur-sm border border-red-500/30;
}

/* 提示文字樣式 */
.connect-hint {
  @apply text-red-200 text-lg;
}

/* 特別優惠樣式 */
.special-offer {
  @apply inline-flex items-center space-x-3 bg-red-900/30 px-6 py-3 rounded-full backdrop-blur-sm border border-red-500/30;
}

.special-offer .icon {
  @apply text-xl animate-bounce;
}

.special-offer .text {
  @apply text-red-100;
}

/* 浮動元素動畫 */
.coin-symbol {
  @apply absolute;
  animation: coin-float 15s ease-in-out infinite;
}

/* 標題動畫 */
.animate-title-shine {
  background-size: 200% auto;
  animation: shine 3s linear infinite;
}

.animate-float-slow {
  animation: float 8s ease-in-out infinite;
}

.animate-fade-in {
  animation: fadeIn 1s ease-out forwards;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* AOS 動畫 */
[data-aos] {
  opacity: 0;
  transform: translateY(20px);
  transition: opacity 0.6s ease-out, transform 0.6s ease-out;
}

.aos-animate {
  opacity: 1;
  transform: translateY(0);
}
</style>
