<template>
  <!-- 首頁背景設定 -->
  <div class="min-h-screen bg-[#7c4585] overflow-hidden relative">  
    
    <!--全頁金幣動畫：在圖層最下方 -->
    <div class="absolute inset-0 pointer-events-none">
    <div v-for="i in 20" :key="i" class="coin-large absolute" :style="{
      left: `${Math.random() * 100}%`,
      top: `${Math.random() * 100}%`,
      animationDelay: `${Math.random() * 5}s`
    }">
      <img src="/images/coin.png" alt="coin" class="w-8 h-8" />
      
    </div>
    <div v-for="i in 30" :key="`coin-${i}`" class="coin-small absolute" :style="{
      left: `${Math.random() * 100}%`,
      top: `${Math.random() * 100}%`,
      animationDelay: `${Math.random() * 8}s`
    }">
      <img src="/images/coin.png" alt="coin" class="w-6 h-6" />
    </div>

    <!-- 💰 撒錢動畫 -->
  <div class="money-animation">
    <div
      v-for="(coin, i) in fallingCoins"
      :key="i"
      class="money-item"
      :style="{
        left: `${coin.left}%`,
        animationDelay: `${coin.delay}s`,
        animationDuration: `${coin.duration}s`
      }"
    >
      <img src="/images/coin.png" alt="coin" class="w-6 h-6" />
    </div>
  </div>

  </div>

    <!-- 頂部導航欄 -->
    <nav class="bg-[#7c4585]/90 text-yellow-100 py-4 px-6 shadow-lg border-b border-yellow-400/30 backdrop-blur-sm">
      <div class="container mx-auto flex justify-between items-center">
        <div class="flex items-center">
          <span class="text-3xl font-bold text-yellow-400">Lucky  Scratch</span>
        </div>
        <div class="hidden md:flex space-x-8">
          <router-link to="/cards" class="hover:text-yellow-400 transition-colors text-lg">🃏 我的卡片</router-link>
          <router-link to="/rules" class="hover:text-yellow-400 transition-colors text-lg">💰 獎池說明</router-link>
        </div>
      </div>
    </nav>

    <!-- 跑馬燈 -->
    <div class="w-full bg-red-300/80 py-2 overflow-hidden marquee mb-5">
      <div class="marquee-content text-[#AE0000] font-bold text-lg flex items-center">
        <span v-for="(user, idx) in topUsers.slice(0, 8)" :key="idx" class="mx-8 whitespace-nowrap">
          恭喜{{ user.name }} 刮中獎金 {{ user.amount }} ETH
        </span>
      </div>
    </div>


    <!-- 主要內容區 -->
    <div class="flex justify-center items-center w-full min-h-[80vh] px-2">
      <div class="flex flex-col items-center justify-center w-full">
        <!-- 獎池金額區塊（在圖片上方，置中） -->
        <div>
          <span class="text-2xl font-bold text-yellow-100 mb-2">目前獎池金額：</span>
          <span class="text-4xl font-extrabold text-yellow-500 mb-1">10.00 ETH</span>
        </div>
        <!-- 跳動的土豆流氓圖片（置中） -->
        <div class="relative mx-auto mb-8 w-[500px] h-[500px] max-w-[90vw] max-h-[90vw]">
              <div class="absolute inset-0 bg-yellow-400/20 rounded-full animate-pulse"></div>
              <img 
                src="/images/money2.jpg" 
                alt="主畫面的狐狸財神爺" 
                class="w-full h-full object-contain animate-bounce"
              />
        </div> 
        <!-- 購買刮刮樂按鈕（移到圖片下方，並用static讓它不再浮動） -->
        <button
          class="buy-float-btn static relative mx-auto mt-2 bg-yellow-400 hover:bg-yellow-500 text-[#7c4585] font-bold px-16 py-8 rounded-2xl shadow-2xl text-4xl flex items-center gap-4"
          @click="connectWalletAndGoBuy"
          :disabled="isConnecting"
          style="position: static !important; right: auto !important; bottom: auto !important;"
        >
          <span class="text-5xl">🎫</span> 購買刮刮樂
        </button>
      </div>
    </div>

    <!-- 刮刮樂選擇彈窗 -->
    <ScratchCardModal
      :isVisible="isModalVisible"
      :cards="scratchCards"
      @close="isModalVisible = false"
      @select="handleCardSelect"
    />

    <!-- 刮刮樂動畫 -->
    <div v-if="selectedCard" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="relative bg-white rounded-lg p-6 shadow-lg w-96">
        <h2 class="text-2xl font-bold text-center mb-4">刮開你的刮刮樂！</h2>
        <div class="relative w-64 h-96 mx-auto">
          <img :src="selectedCard.image" alt="刮刮樂" class="w-full h-full object-cover" />
          <canvas
            ref="scratchCanvas"
            class="absolute inset-0"
            @mousedown="startScratching"
            @mousemove="scratch"
            @mouseup="stopScratching"
            @mouseleave="stopScratching"
          ></canvas>
        </div>
        <button @click="resetScratchCard" class="mt-4 w-full bg-green-500 text-white py-2 rounded-lg hover:bg-green-600">
          完成
        </button>
      </div>
    </div>

   
  </div>
</template>


<script setup>
  import { ref, onMounted } from 'vue'
  import { useRouter } from 'vue-router'
  import '@/assets/styles/buy.css'  
  import ScratchCardModal from '@/components/ScratchCardModal.vue'

  const coinsLarge = Array.from({ length: 20 }, () => ({
    left: Math.random() * 100,
    top: Math.random() * 100,
    delay: Math.random() * 5
  })) 
  const fallingCoins = Array.from({ length: 30 }, () => ({
  left: Math.random() * 100,
  delay: Math.random() * 5,
  duration: 3 + Math.random() * 2
  }))
  

  const router = useRouter()
  const isConnecting = ref(false)

  async function connectWalletAndGoBuy() {
    if (!window.ethereum) {
      alert('請先安裝 MetaMask 錢包！')
      return
    }
    isConnecting.value = true
    try {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })
      if (accounts && accounts.length > 0) {
        // 連接成功再跳轉
        router.push('/buy')
      } else {
        alert('未取得錢包地址')
      }
    } catch (e) {
      alert('連接錢包失敗')
    } finally {
      isConnecting.value = false
    }
  }
  

// 排行榜數據
const topUsers = ref([
  { name: '🐲 財神爺', amount: '1,888,888' },
  { name: '🏮 金元寶', amount: '888,888' },
  { name: '🎊 富貴花', amount: '666,666' },
  { name: '🧧 發財貓', amount: '555,555' },
  { name: '🎋 招財狗', amount: '444,444' },
  { name: '💰 聚寶盆', amount: '333,333' },
  { name: '🌟 搖錢樹', amount: '222,222' },
  { name: '✨ 財運到', amount: '111,111' }
])

const isModalVisible = ref(false)
const selectedCard = ref(null)
const scratchCards = [
  { name: '金幣卡', image: '/images/scratch-card-1.png' },
  { name: '幸運卡', image: '/images/scratch-card-2.png' },
  { name: '財神卡', image: '/images/scratch-card-3.png' }
]

const handleCardSelect = (card) => {
  selectedCard.value = card
  isModalVisible.value = false
}

const resetScratchCard = () => {
  selectedCard.value = null
}

const scratchCanvas = ref(null)
let isScratching = false

const startScratching = () => {
  isScratching = true
}

const scratch = (event) => {
  if (!isScratching || !scratchCanvas.value) return
  const ctx = scratchCanvas.value.getContext('2d')
  const rect = scratchCanvas.value.getBoundingClientRect()
  const x = event.clientX - rect.left
  const y = event.clientY - rect.top
  ctx.globalCompositeOperation = 'destination-out'
  ctx.beginPath()
  ctx.arc(x, y, 20, 0, Math.PI * 2)
  ctx.fill()
}

const stopScratching = () => {
  isScratching = false
}

onMounted(() => {
  if (scratchCanvas.value) {
    const ctx = scratchCanvas.value.getContext('2d')
    ctx.fillStyle = '#ccc'
    ctx.fillRect(0, 0, scratchCanvas.value.width, scratchCanvas.value.height)
  }
})
</script>

<style scoped>
.coin-large {
  animation: float 3s ease-in-out infinite;
  opacity: 0.7;
  filter: drop-shadow(0 0 8px rgba(214, 26, 9, 0.5));
}

.coin-small {
  animation: spin 4s linear infinite;
  opacity: 0.5;
  filter: drop-shadow(0 0 5px rgba(208, 75, 63, 0.3));
}

@keyframes float {
  0%, 100% {
    transform: translateY(0) rotate(-5deg);
  }
  50% {
    transform: translateY(-20px) rotate(5deg);
  }
}

@keyframes spin {
  from {
    transform: rotate(0deg) scale(1);
    opacity: 0.3;
  }
  50% {
    transform: rotate(180deg) scale(1.2);
    opacity: 0.6;
  }
  to {
    transform: rotate(360deg) scale(1);
    opacity: 0.3;
  }
}

/* 撒錢動畫 */
.money-animation {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
}

.money-item {
  position: absolute;
  animation: fall linear infinite;
  opacity: 0;
  z-index: 0;
}

@keyframes fall {
  0% {
    transform: translateY(-100%) rotate(0deg);
    opacity: 0;
  }
  10% {
    opacity: 1;
  }
  90% {
    opacity: 1;
  }
  100% {
    transform: translateY(100vh) rotate(360deg);
    opacity: 0;
  }
}

/* 跑馬燈樣式 */
.marquee {
  position: relative;
  width: 100%;
  overflow: hidden;
  height: 2.5rem;
}
.marquee-content {
  display: inline-block;
  white-space: nowrap;
  animation: marquee 60s linear infinite; /* 原本是18s，改成36s會變慢一半 */
}
@keyframes marquee {
  0% { transform: translateX(100%);}
  100% { transform: translateX(-100%);}
}



/* 新增的動畫 */
@keyframes bounce-soft {
  0%, 100% {
    transform: translateY(0);
    animation-timing-function: cubic-bezier(0.8,0,1,1);
  }
  50% {
    transform: translateY(-16px); /* 柔和跳動 */
    animation-timing-function: cubic-bezier(0,0,0.2,1);
  }
}
.animate-bounce-soft {
  animation: bounce-soft 1.2s infinite;
}
@keyframes shine-border {
  0% { box-shadow: 0 0 16px 4px #ffe066, 0 0 0 0 #ffd700; }
  50% { box-shadow: 0 0 32px 8px #ffd700, 0 0 0 0 #ffe066; }
  100% { box-shadow: 0 0 16px 4px #ffe066, 0 0 0 0 #ffd700; }
}
.animate-shine {
  animation: shine-border 2s infinite;
  border-radius: 1rem;
  border: 4px solid transparent;
}

</style>