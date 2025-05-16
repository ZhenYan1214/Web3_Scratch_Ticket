<template>
  <div class="min-h-screen bg-[#7c4585] overflow-hidden relative">
    <!-- 頂部導航欄 -->
    <nav class="bg-[#7c4585]/90 text-yellow-100 py-4 px-6 shadow-lg border-b border-yellow-400/30 backdrop-blur-sm">
      <div class="container mx-auto flex justify-between items-center">
        <div class="flex items-center">
          <span class="text-3xl font-bold text-yellow-400"  @click="goBack">Lucky Scratch</span>
        </div>
        <div class="hidden md:flex space-x-8">
          <router-link to="/" class="hover:text-yellow-400 transition-colors text-lg">🏠 首頁</router-link>
          <router-link to="/cards" class="hover:text-yellow-400 transition-colors text-lg">🃏 我的卡片</router-link>
          <router-link to="/pool" class="hover:text-yellow-400 transition-colors text-lg">💰 獎池資訊</router-link>
          <router-link to="/rules" class="hover:text-yellow-400 transition-colors text-lg">📜 規則說明</router-link>
        </div>
      </div>
    </nav>

    <!-- 主要內容區 -->
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-4xl font-bold text-yellow-400 mb-8 text-center">🃏 我的刮刮樂</h1>
      <!-- 狀態篩選區塊 -->
      <div class="flex justify-center mb-8 gap-4">
        <button
          v-for="type in statusTypes"
          :key="type"
          @click="selectedStatus = type"
          :class="[
            'px-6 py-2 rounded-full font-bold transition',
            selectedStatus === type
              ? 'bg-yellow-400 text-[#7c4585] shadow'
              : 'bg-[#7c4585] text-yellow-200 border border-yellow-400 hover:bg-yellow-500 hover:text-[#7c4585]'
          ]"
        >
          {{ type }}
        </button>
      </div>
      <!-- 卡片滑動區域 -->
      <div class="relative overflow-x-auto pb-8">
        <div class="flex space-x-6 px-4 snap-x snap-mandatory overflow-x-auto scrollbar-hide">
          <!-- 刮刮樂卡片 -->
          <div
            v-for="card in filteredCards"
            :key="card.id"
            class="snap-center shrink-0"
          >
            <div
              class="w-72 h-96 bg-gradient-to-br from-[#7c4585]/80 to-purple-900/80 rounded-2xl shadow-2xl p-6 border-2 border-yellow-400/50 backdrop-blur-sm transform transition-all duration-300 hover:scale-105"
              :class="card.status === '待刮開' ? 'cursor-pointer ring-2 ring-yellow-300' : ''"
              @click="card.status === '待刮開' && openScratchModal(card)"
            >
              <!-- 卡片內容 -->
              <div class="h-full flex flex-col items-center justify-between">
                <!-- 卡片圖案 -->
                <div class="w-32 h-32 rounded-full bg-gradient-to-br from-yellow-400 to-yellow-600 flex items-center justify-center mb-4">
                  <span class="text-6xl">{{ card.symbol }}</span>
                </div>
                <!-- 獎金資訊 -->
                <div class="text-center">
                  <div class="text-yellow-400 text-xl font-bold mb-2">獎金金額</div>
                  <div class="text-3xl font-bold text-yellow-300">{{ card.amount }} ETH</div>
                  <div class="text-yellow-200 mt-2">{{ card.status }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <!-- 刮刮樂動畫 Modal -->
      <div v-if="showScratchModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
        <div class="relative bg-white rounded-lg p-6 shadow-lg w-96">
          <h2 class="text-2xl font-bold text-center mb-4" style="color: #7c4585">刮開你的刮刮樂！</h2>
          <div class="relative w-64 h-96 mx-auto">
            <!-- 預留：底圖（依據中獎結果顯示不同圖片） -->
            <img
              v-if="showResult"
              :src="isWin ? getWinImage(selectedCard, resultText) : getLoseImage(selectedCard)"
              alt="result"
              class="w-full h-full object-cover rounded absolute inset-0 z-10"
            />
            <!-- 預設底圖（未刮開或尚未顯示結果時） -->
            <img
              v-else
              :src="getPrizeImage(selectedCard)"
              alt="prize"
              class="w-full h-full object-cover rounded absolute inset-0 z-0"
            />
            <!-- 上方 canvas 灰色遮罩 -->
            <canvas
              ref="scratchCanvas"
              width="256"
              height="384"
              class="absolute inset-0 rounded z-20"
              @mousedown="startScratching"
              @mousemove="scratch"
              @mouseup="stopScratching"
              @mouseleave="stopScratching"
            ></canvas>
            <!-- 中獎結果動畫 -->
            <transition name="fade">
              <div
                v-if="showResult"
                class="absolute inset-0 flex flex-col items-center justify-center rounded z-30"
                :class="resultClass"
              >
                <div class="text-4xl font-extrabold mb-2" v-text="resultText"></div>
                <div v-if="isWin" class="confetti"></div>
                <div v-else class="shake"></div>
              </div>
            </transition>
          </div>
          <button @click="closeScratchModal" class="mt-4 w-full bg-green-500 text-white py-2 rounded-lg hover:bg-green-600">
            完成
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, watch, computed } from 'vue'

const statusTypes = ['全部', '已中獎', '未中獎', '待刮開']
const selectedStatus = ref('全部')

// 卡片數據
const cards = ref([
  { id: 1, symbol: '🎰', amount: '0.5', status: '已中獎' },
  { id: 2, symbol: '💎', amount: '0.8', status: '未中獎' },
  { id: 3, symbol: '🎲', amount: '1.2', status: '待刮開' },
  { id: 4, symbol: '🎯', amount: '0.3', status: '已中獎' },
  { id: 5, symbol: '🎪', amount: '2.0', status: '待刮開' },
  { id: 6, symbol: '🎨', amount: '0.6', status: '未中獎' }
])

const filteredCards = computed(() => {
  if (selectedStatus.value === '全部') return cards.value
  return cards.value.filter(card => card.status === selectedStatus.value)
})

const showScratchModal = ref(false)
const selectedCard = ref(null)
const scratchCanvas = ref(null)
let isScratching = false

// 中獎結果
const resultText = ref('')
const showResult = ref(false)
const isWin = ref(false)
const resultClass = computed(() => {
  return isWin.value
    ? 'bg-yellow-100/80 animate__animated animate__tada'
    : 'bg-gray-200/80 animate__animated animate__headShake'
})

const prizeList = [
  { text: '🎉 大獎！', win: true },
  { text: '🥈 二獎', win: true },
  { text: '🥉 三獎', win: true },
  { text: '🎁 安慰獎', win: true },
  { text: '未中獎', win: false }
]

const openScratchModal = (card) => {
  selectedCard.value = card
  showScratchModal.value = true
  showResult.value = false
  nextTick(drawMask)
}

const closeScratchModal = () => {
  showScratchModal.value = false
  selectedCard.value = null
  showResult.value = false
}

const getPrizeImage = (card) => {
  // 你可以根據卡片資訊回傳不同圖片
  return '/images/prize.png'
}

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

  // 檢查刮開程度，若超過一定比例則顯示結果
  revealResultIfNeeded()
}

const stopScratching = () => {
  isScratching = false
}

function drawMask() {
  if (scratchCanvas.value) {
    const ctx = scratchCanvas.value.getContext('2d')
    ctx.globalCompositeOperation = 'source-over'
    ctx.fillStyle = '#bbb'
    ctx.fillRect(0, 0, scratchCanvas.value.width, scratchCanvas.value.height)
    ctx.font = 'bold 32px sans-serif'
    ctx.fillStyle = '#888'
    ctx.textAlign = 'center'
    ctx.fillText('刮一刮', scratchCanvas.value.width / 2, scratchCanvas.value.height / 2)
  }
}

// 檢查刮開比例，超過60%就顯示結果
function revealResultIfNeeded() {
  if (!scratchCanvas.value || showResult.value) return
  const ctx = scratchCanvas.value.getContext('2d')
  const imgData = ctx.getImageData(0, 0, scratchCanvas.value.width, scratchCanvas.value.height)
  let transparent = 0
  for (let i = 0; i < imgData.data.length; i += 4) {
    if (imgData.data[i + 3] === 0) transparent++
  }
  const percent = transparent / (imgData.data.length / 4)
  if (percent > 0.6) { // 60%
    // 隨機產生結果
    const prize = prizeList[Math.floor(Math.random() * prizeList.length)]
    resultText.value = prize.text
    isWin.value = prize.win
    showResult.value = true
  }
}

// 預留：依據結果顯示不同底圖
function getWinImage(card, resultText) {
  // 依據 resultText 或 card 回傳不同中獎圖片
  // 例如 return `/images/win-${resultText}.png`
  return '/images/win-default.png'
}
function getLoseImage(card) {
  // 依據 card 回傳不同未中獎圖片
  return '/images/lose-default.png'
}

watch(showScratchModal, (val) => {
  if (val) nextTick(drawMask)
})
</script>

<style scoped>
/* 隱藏滾動條但保持功能 */
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}

/* 卡片懸浮效果 */
.hover\:scale-105:hover {
  transform: scale(1.05);
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.2),
              0 10px 10px -5px rgba(0, 0, 0, 0.1);
}

/* 動畫 */
@import "https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css";

.confetti {
  width: 100%;
  height: 60px;
  background: url('https://cdn.jsdelivr.net/gh/stevenjoezhang/live2d-widget@latest/asset/other/confetti.gif') center/contain no-repeat;
}
.shake {
  width: 100%;
  height: 40px;
  animation: shake 0.7s;
}
@keyframes shake {
  10%, 90% { transform: translateX(-2px); }
  20%, 80% { transform: translateX(4px); }
  30%, 50%, 70% { transform: translateX(-8px); }
  40%, 60% { transform: translateX(8px); }
}
.fade-enter-active, .fade-leave-active {
  transition: opacity .5s;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>