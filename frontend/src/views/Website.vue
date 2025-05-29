<template>
  <div class="min-h-screen bg-[#7c4585] relative overflow-hidden">
    <!-- 🌟 背景動畫層 -->
    <div class="absolute inset-0">
      <!-- 光暈 -->
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_50%_50%,rgba(255,215,0,0.15),transparent_70%)] animate-pulse"></div>
      
      <!-- 漂浮符號 -->
      <div class="floating-symbols pointer-events-none absolute inset-0 z-0">
        <div
          v-for="(style, i) in floatingStyles"
          :key="i"
          class="absolute floating-item"
          :style="style"
        >
          {{ symbols[i % symbols.length] }}
        </div>
      </div>

      <!-- 福/財 -->
      <div class="absolute top-10 left-10 transform -rotate-12 opacity-20 text-8xl text-yellow-500 animate-float-slow">福</div>
      <div class="absolute bottom-10 right-10 transform rotate-12 opacity-20 text-8xl text-yellow-500 animate-float-slow">財</div>
    </div>

    <!-- 🌟 主內容層 -->
    <div class="relative z-10 container mx-auto px-4 py-12">

      <!-- 🧧 Logo 區塊 -->
      <section class="text-center mb-16">
        <div class="relative inline-block">
          <h1 class="text-glow text-7xl md:text-8xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-yellow-400 via-yellow-300 to-yellow-400 mb-6 animate-title-shine">
            Lucky Scratch
          </h1>
          <div class="absolute -inset-1 bg-gradient-to-r from-yellow-400 to-red-600 opacity-30 blur"></div>
        </div>
        <p class="text-2xl md:text-3xl text-red-100 font-medium mt-4 animate-fade-in">
          Web3 刮刮樂遊戲，帶來無限驚喜！
        </p>
      </section>

      <!-- ✨ 三張特色卡片 -->
      <section class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-16 w-full max-w-6xl mx-auto">
        <div 
          class="feature-card group bg-white/10 backdrop-blur-md rounded-2xl p-6 hover:bg-white/20 transition-all duration-300 transform hover:scale-105 hover:shadow-2xl border border-white/20" 
          v-for="(item, idx) in features" 
          :key="idx"
        >
          <div class="card-content text-center">
            <div class="icon-wrapper mb-4">
              <span class="text-5xl mb-6 group-hover:scale-110 transition-transform duration-300 inline-block">{{ item.icon }}</span>
            </div>
            <h3 class="text-xl font-bold mb-3 text-yellow-300">{{ item.title }}</h3>
            <p class="text-red-100">{{ item.desc }}</p>
          </div>
        </div>
      </section>

      <!-- 🟡 連接錢包按鈕 -->
      <section class="flex justify-center my-10">
        <!-- 未連接狀態 -->
        <div v-if="!walletConnected && !isConnecting" class="text-center">
          <button
            @click="connectWallet"
            class="wallet-btn bg-gradient-to-r from-yellow-400 to-yellow-500 hover:from-yellow-500 hover:to-yellow-600 text-[#7c4585] px-12 py-4 rounded-xl font-bold text-2xl shadow-[0_0_20px_rgba(255,215,0,0.6)] hover:shadow-[0_0_30px_rgba(255,215,0,0.8)] transition-all duration-300 transform hover:scale-105 active:scale-95"
          >
            <span class="flex items-center space-x-3">
              <span>🦊</span>
              <span>連接 MetaMask 錢包</span>
            </span>
          </button>
          <p class="text-yellow-200 text-sm mt-4 opacity-80">
            點擊按鈕連接您的 MetaMask 錢包開始使用
          </p>
        </div>

        <!-- 連接中狀態 -->
        <div v-else-if="isConnecting" class="text-center">
          <div class="bg-white/10 backdrop-blur-md rounded-xl px-8 py-6 border border-yellow-400/30">
            <div class="flex items-center justify-center space-x-3 mb-4">
              <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-yellow-400"></div>
              <span class="text-yellow-200 text-xl font-medium">正在連接錢包...</span>
            </div>
            <p class="text-yellow-200/80 text-sm">請在 MetaMask 中確認連接請求</p>
          </div>
        </div>

        <!-- 連接成功狀態 -->
        <div v-else-if="walletConnected" class="text-center">
          <div class="bg-green-500/20 backdrop-blur-md rounded-xl px-8 py-6 border border-green-400/30 animate-fade-in">
            <div class="flex items-center justify-center space-x-3 mb-4">
              <span class="text-3xl"></span>
              <span class="text-green-200 text-xl font-medium">錢包連接成功！</span>
            </div>
            <p class="text-green-200/80 text-sm mb-4">
              錢包地址：{{ formatAddress(walletAddress) }}
            </p>
            <div class="flex items-center justify-center space-x-2">
              <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-green-400"></div>
              <span class="text-green-200 text-sm">正在跳轉到主頁面...</span>
            </div>
          </div>
        </div>
      </section>

      <!-- ❗ 錯誤訊息 -->
      <div v-if="errorMsg" class="flex justify-center mb-8">
        <div class="error-message bg-red-500/20 backdrop-blur-md border border-red-400/30 rounded-xl px-6 py-4 max-w-md animate-fade-in">
          <div class="flex items-center space-x-3">
            <span class="text-2xl">⚠️</span>
            <div>
              <p class="text-red-200 font-medium">連接失敗</p>
              <p class="text-red-200/80 text-sm">{{ errorMsg }}</p>
            </div>
          </div>
          <button 
            @click="clearError" 
            class="mt-3 text-red-300 hover:text-red-100 text-sm underline"
          >
            關閉
          </button>
        </div>
      </div>

      <!-- 📜 規則說明 -->
      <section class="my-16 flex justify-center">
        <div class="bg-white/10 backdrop-blur-md rounded-2xl px-8 py-6 shadow-xl text-white text-lg w-full max-w-3xl mx-auto border border-white/20 animate-slide-up">
          <h2 class="text-3xl font-bold text-yellow-300 mb-4 text-center">📜 規則說明</h2>
          <ul class="space-y-3">
            <li class="flex items-start space-x-3">
              <span class="text-yellow-400 mt-1 text-lg">💳</span>
              <span>連接錢包後可購買刮刮樂，每張 0.01 ETH</span>
            </li>
            <li class="flex items-start space-x-3">
              <span class="text-yellow-400 mt-1 text-lg">🎁</span>
              <span>刮開可獲得驚喜獎項，金幣大放送！</span>
            </li>
            <li class="flex items-start space-x-3">
              <span class="text-yellow-400 mt-1 text-lg">🍀</span>
              <span>每日抽選八位幸運用戶，獎池金額天天更新</span>
            </li>
            <li class="flex items-start space-x-3">
              <span class="text-yellow-400 mt-1 text-lg">🤖</span>
              <span>智能合約自動執行，公平又安心</span>
            </li>
          </ul>
        </div>
      </section>

      <!-- 🎉 特別優惠 -->
      <section class="flex justify-center">
        <div class="special-offer flex items-center justify-center space-x-4 bg-yellow-500/20 px-6 py-3 rounded-full backdrop-blur-sm border border-yellow-400/30 animate-bounce-gentle">
          <span class="icon text-2xl animate-bounce">🎉</span>
          <span class="text-red-100 text-lg">特別優惠：首次購買刮刮樂可獲得額外 10% 獎金！</span>
        </div>
      </section>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const symbols = ['💰', '🪙', '💎', '✨']
const walletConnected = ref(false)
const walletAddress = ref('')
const errorMsg = ref('')
const isConnecting = ref(false)

const features = [
  { icon: '🔒', title: '安全可靠', desc: '智能合約審計，資產安全無憂' },
  { icon: '💰', title: '收益豐厚', desc: 'DeFi 收益優化，財運滾滾來' },
  { icon: '🚀', title: '創新科技', desc: '區塊鏈技術，引領未來理財' }
]

const floatingStyles = Array.from({ length: 40 }, (_, i) => getFloatingStyle(i))

function getFloatingStyle(i) {
  const left = Math.random() * 100
  const top = Math.random() * 100
  const size = Math.random() * 24 + 16
  const rotate = Math.random() * 360
  const duration = Math.random() * 4 + 2
  const delay = Math.random() * 3
  const opacity = Math.random() * 0.4 + 0.3

  return {
    left: `${left}%`,
    top: `${top}%`,
    fontSize: `${size}px`,
    '--init-rotate': `rotate(${rotate}deg)`,
    '--float-distance': '20px',
    animation: `floatAnim ${duration}s ease-in-out ${delay}s infinite`,
    opacity: opacity.toFixed(2),
  }
}

function formatAddress(address) {
  if (!address) return ''
  return `${address.slice(0, 6)}...${address.slice(-4)}`
}

function clearError() {
  errorMsg.value = ''
}

async function connectWallet() {
  if (isConnecting.value) return
  
  clearError()
  isConnecting.value = true
  
  // 檢查是否安裝 MetaMask
  if (!window.ethereum) {
    errorMsg.value = '請先安裝 MetaMask 錢包擴展程式！'
    isConnecting.value = false
    return
  }
  
  try {
    console.log('開始連接錢包...')
    
    // 請求連接帳戶
    const accounts = await window.ethereum.request({ 
      method: 'eth_requestAccounts' 
    })
    
    console.log('獲取到的帳戶:', accounts)
    
    if (accounts && accounts.length > 0) {
      walletAddress.value = accounts[0]
      walletConnected.value = true
      
      console.log('錢包連接成功，地址:', accounts[0])
      
      // 延遲跳轉，讓用戶看到成功訊息
      setTimeout(() => {
        alert('即將跳轉')
        router.push('/home').then(() => {
          alert('跳轉成功')
        }).catch((error) => {
          alert('跳轉失敗: ' + error)
        })
      }, 2000)
      
      // 清除錯誤訊息
      errorMsg.value = ''
      
    } else {
      errorMsg.value = '未能獲取錢包地址，請重試'
    }
    
  } catch (err) {
    console.error('錢包連接錯誤:', err)
    
    if (err.code === 4001) {
      errorMsg.value = '您拒絕了錢包連接請求'
    } else if (err.code === -32002) {
      errorMsg.value = '請先在 MetaMask 中處理待確認的請求'
    } else {
      errorMsg.value = `連接失敗：${err.message || '未知錯誤'}`
    }
  } finally {
    isConnecting.value = false
  }
}

// 監聽帳戶變更
function handleAccountsChanged(accounts) {
  console.log('帳戶變更:', accounts)
  if (accounts.length === 0) {
    // 用戶斷開了錢包
    walletConnected.value = false
    walletAddress.value = ''
  } else {
    // 用戶切換了帳戶
    walletAddress.value = accounts[0]
    walletConnected.value = true
  }
}

// 監聽鏈變更
function handleChainChanged(chainId) {
  console.log('鏈變更:', chainId)
  // 可以在這裡處理鏈變更邏輯
}

onMounted(async () => {
  // 檢查是否已經連接錢包
  if (window.ethereum) {
    try {
      const accounts = await window.ethereum.request({ method: 'eth_accounts' })
      if (accounts && accounts.length > 0) {
        walletAddress.value = accounts[0]
        walletConnected.value = true
        console.log('檢測到已連接的錢包:', accounts[0])
        setTimeout(() => {
          router.push('/home')
        }, 2000)
      }
      
      // 監聽事件
      window.ethereum.on('accountsChanged', handleAccountsChanged)
      window.ethereum.on('chainChanged', handleChainChanged)
      
    } catch (error) {
      console.error('檢查錢包狀態時發生錯誤:', error)
    }
  }
})

onUnmounted(() => {
  // 清理事件監聽器
  if (window.ethereum) {
    window.ethereum.removeListener('accountsChanged', handleAccountsChanged)
    window.ethereum.removeListener('chainChanged', handleChainChanged)
  }
})
</script>

<style scoped>
.floating-item {
  position: absolute;
  will-change: transform;
  transform: var(--init-rotate, rotate(0deg));
}

@keyframes floatAnim {
  0%, 100% {
    transform: var(--init-rotate, rotate(0deg)) translateY(0);
  }
  50% {
    transform: var(--init-rotate, rotate(0deg)) translateY(var(--float-distance));
  }
}

@keyframes titleShine {
  0%, 100% {
    background-position: -100% 0%;
  }
  50% {
    background-position: 100% 0%;
  }
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes floatSlow {
  0%, 100% {
    transform: translateY(0px) rotate(var(--init-rotate, 0deg));
  }
  50% {
    transform: translateY(-10px) rotate(var(--init-rotate, 0deg));
  }
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes bounceGentle {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-5px);
  }
}

.animate-title-shine {
  background-size: 200% 200%;
  animation: titleShine 3s ease-in-out infinite;
}

.animate-fade-in {
  animation: fadeIn 0.8s ease-out;
}

.animate-float-slow {
  animation: floatSlow 4s ease-in-out infinite;
}

.animate-slide-up {
  animation: slideUp 0.8s ease-out;
}

.animate-bounce-gentle {
  animation: bounceGentle 2s ease-in-out infinite;
}

.feature-card {
  position: relative;
  overflow: hidden;
}

.feature-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
  transition: left 0.5s;
}

.feature-card:hover::before {
  left: 100%;
}

.wallet-btn {
  position: relative;
  overflow: hidden;
}

.wallet-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.6s;
}

.wallet-btn:hover::before {
  left: 100%;
}
</style>