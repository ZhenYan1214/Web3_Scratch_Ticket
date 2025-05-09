<template>
  <!-- 首頁背景設定 -->
  <div class="min-h-screen bg-[#7c4585] overflow-hidden relative">  
  
<!-- ✅ 全頁金幣動畫：在圖層最下方 -->
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
          <router-link to="/pool" class="hover:text-yellow-400 transition-colors text-lg">💰 獎池資訊</router-link>
          <router-link to="/rules" class="hover:text-yellow-400 transition-colors text-lg">📜 規則說明</router-link>
        </div>
      </div>
    </nav>

    <!-- 主要內容區 -->
    <div class="container mx-auto px-4 py-8">
      <div class="flex flex-col lg:flex-row gap-8">
        <!-- 左側：土豆流氓和新年祝福 -->
        <div class="lg:w-2/3 relative">
          <div class="bg-[#7c4585]/80 rounded-2xl shadow-2xl p-8 text-center relative overflow-hidden border-2 border-yellow-400/50 backdrop-blur-sm">
            <div class="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-yellow-400 via-yellow-500 to-yellow-400"></div>
            <h1 class="text-4xl md:text-5xl font-bold text-yellow-400 mb-4">✨ 好運刮刮樂 ✨</h1>
            <p class="text-2xl text-yellow-200 mb-8">試試手氣，下一個就是你！</p>
            
            <!-- 土豆流氓圖片 -->
            <div class="relative mx-auto w-188 h-188 mb-8">
              <div class="absolute inset-0 bg-yellow-400/20 rounded-full animate-pulse"></div>
              <img 
                src="/images/money2.jpg" 
                alt="戴墨鏡的土豆流氓" 
                class="w-full h-full object-contain animate-bounce"
              />
            </div>
            
            <!-- 獎池 -->
            <div class="bg-gradient-to-r from-yellow-500 to-yellow-600 text-[#7c4585] rounded-xl p-8 shadow-xl mb-8 transform hover:scale-105 transition-transform border border-yellow-400/50">
              <h2 class="text-3xl font-bold mb-2">🔮 神秘獎池 🔮</h2>
              <div class="text-5xl font-bold mb-2">888,888 ETH</div>
              <p class="text-lg">每日抽取八位幸運用戶</p>
            </div>
            

            <button class="buy-button" @click="$router.push('/buy')">
              <span class="text-3xl mr-2">🎫</span>
                立即購買刮刮樂
              </button>
          
          </div>
        </div>
        
        <!-- 右側：排行榜 -->
        <div class="lg:w-1/3">
          <div class="bg-[#7c4585]/80 rounded-2xl shadow-2xl p-6 border-2 border-yellow-400/50 backdrop-blur-sm">
            <h2 class="text-3xl font-bold text-yellow-400 mb-6 text-center">🏆 神秘榜單 🏆</h2>
            
            <div class="space-y-4">
              <div v-for="(user, index) in topUsers" :key="index" 
                class="flex items-center p-4 rounded-xl transition-all hover:transform hover:scale-102 bg-gradient-to-r" 
                :class="[
                  index === 0 ? 'from-yellow-500/20 to-yellow-600/20 border border-yellow-400/50' : 
                  index === 1 ? 'from-[#7c4585]/20 to-[#7c4585]/30 border border-[#7c4585]/50' : 
                  index === 2 ? 'from-[#7c4585]/10 to-[#7c4585]/20 border border-[#7c4585]/30' : 
                  'from-[#7c4585]/5 to-[#7c4585]/10 border border-[#7c4585]/20'
                ]"
              >
                <div class="w-10 h-10 flex items-center justify-center rounded-full mr-4 text-xl"
                  :class="[
                    index === 0 ? 'bg-yellow-500 text-[#7c4585]' : 
                    index === 1 ? 'bg-[#7c4585] text-yellow-400' : 
                    index === 2 ? 'bg-[#7c4585]/80 text-yellow-400' : 
                    'bg-[#7c4585]/60 text-yellow-400'
                  ]"
                >
                  {{ ['🥇', '🥈', '🥉'][index] || (index + 1) }}
                </div>
                <div class="flex-1">
                  <div class="font-bold text-lg text-yellow-100">{{ user.name }}</div>
                  <div class="text-yellow-400 font-medium">{{ user.amount }} ETH</div>
                </div>
                <div class="text-yellow-400">
                  <span v-if="index < 3" class="text-2xl">✨</span>
                </div>
              </div>
            </div>
            
            <div class="mt-6 text-center">
              <button class="text-yellow-400 hover:text-yellow-300 transition-colors text-lg font-bold">
                🎯 查看完整榜單
              </button>
            </div>
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

</style>