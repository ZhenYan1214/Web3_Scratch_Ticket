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
    <div class="w-full bg-yellow-100/60 py-2 overflow-hidden marquee">
      <div class="marquee-content text-[#7c4585] font-bold text-lg flex items-center">
        <span v-for="(user, idx) in topUsers.slice(0, 8)" :key="idx" class="mx-8 whitespace-nowrap">
          恭喜{{ user.name }} 刮中獎金 {{ user.amount }} ETH
        </span>
      </div>
    </div>


    <!-- 主要內容區 -->
    <div class="w-full px-2 py-4">
      <div class="flex flex-col lg:flex-row gap-4">
        <!-- 左側：土豆流氓和新年祝福 -->
        <div class="max-w-3xl mx-auto relative">
          <div class="bg-[#7c4585]/80 rounded-2xl shadow-2xl p-3 text-center relative overflow-hidden border-2 border-yellow-400/50 backdrop-blur-sm">
            <div class="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-yellow-400 via-yellow-500 to-yellow-400"></div>
            <h1 class="text-2xl md:text-3xl font-bold text-yellow-400 mb-2">✨ 好運刮刮樂 ✨</h1>
            <p class="text-lg text-yellow-200 mb-4">試試手氣，下一個就是你！</p>
            <!-- 土豆流氓圖片 -->
            <div class="relative mx-auto w-64 h-48 mb-4">
              <div class="absolute top-1/2 left-1/2 w-40 h-32 -translate-x-1/2 -translate-y-1/2 bg-yellow-400/20 rounded-full animate-pulse"></div>
              <img 
                src="/images/money2.jpg" 
                alt="戴墨鏡的土豆流氓" 
                class="w-full h-full object-contain animate-bounce"
              />
            </div>
            <!-- 獎池金額區塊 -->
            <div class="bg-yellow-100/90 border-2 border-yellow-400 rounded-xl shadow-lg px-4 py-3 mb-2 flex flex-col items-center">
              <div class="text-lg font-bold text-[#7c4585] mb-1">目前獎池金額</div>
              <div class="text-2xl font-extrabold text-yellow-500 mb-1">10.00 ETH</div>
              <div class="text-[#7c4585] text-base">獎池會隨著購買自動累積，快來試手氣！</div>
            </div>
          </div>
        </div>
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

    <!-- 固定在右下角的購買刮刮樂按鈕（放大版） -->
      <button
  class="fixed bottom-4 right-4 sm:bottom-6 sm:right-6 z-[999] bg-yellow-400 hover:bg-yellow-500 text-[#7c4585] font-bold px-5 py-3 sm:px-6 sm:py-4 rounded-lg shadow-lg text-lg sm:text-xl flex items-center gap-2 buy-float-btn"
  @click="$router.push('/buy')"
>
  <span class="text-3xl sm:text-4xl">🎫</span> 購買刮刮樂
</button>
  </div>
</template>


<script setup>
  import { ref, onMounted } from 'vue'
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
  filter: drop-shadow(0 0 8px rgba(255, 215, 0, 0.5));
}

.coin-small {
  animation: spin 4s linear infinite;
  opacity: 0.5;
  filter: drop-shadow(0 0 5px rgba(255, 215, 0, 0.3));
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
  animation: marquee 36s linear infinite; /* 原本是18s，改成36s會變慢一半 */
}
@keyframes marquee {
  0% { transform: translateX(100%);}
  100% { transform: translateX(-100%);}
}

/* 浮動購買按鈕樣式 */
.buy-float-btn {
  position: relative;
  overflow: hidden;
  transition: background 0.2s, box-shadow 0.2s, transform 0.1s;
  box-shadow: 0 8px 32px 0 rgba(124, 69, 133, 0.18);
  font-size: 2rem;
  padding: 1.5rem 2.5rem;
}

.buy-float-btn::after {
  content: '';
  position: absolute;
  top: -50%;
  left: -30%;
  width: 60%;
  height: 200%;
  background: linear-gradient(120deg, rgba(255,255,255,0.2) 0%, rgba(255,255,255,0.7) 50%, rgba(255,255,255,0.2) 100%);
  transform: skewX(-20deg);
  animation: shine 2.2s infinite;
  pointer-events: none;
}

@keyframes shine {
  0% {
    left: -60%;
  }
  100% {
    left: 120%;
  }
}

.buy-float-btn:hover {
  transform: scale(1.12);
}
.buy-float-btn {
  position: fixed !important;
  right: 1rem !important;
  bottom: 1rem !important;
}
</style>