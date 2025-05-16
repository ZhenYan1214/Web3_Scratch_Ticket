<template>
  <nav class="bg-[#7c4585]/90 text-yellow-100 py-4 px-6 shadow-lg border-b border-yellow-400/30 backdrop-blur-sm">
    <div class="flex items-center">
      <span class="text-3xl font-bold text-yellow-400" @click="goBack">Lucky  Scratch</span>
    </div>
  </nav>
  <div class="min-h-screen bg-[#7c4585] flex flex-col items-center justify-center text-yellow-100">
    <h1 class="text-4xl font-bold mb-8">🎫 購買刮刮樂</h1>
    <div v-if="!selectedCard" class="grid grid-cols-1 md:grid-cols-3 gap-8">
      <div
        v-for="(card, index) in scratchCards"
        :key="index"
        class="bg-white text-[#7c4585] rounded-lg shadow-lg p-6 text-center cursor-pointer hover:scale-105 transition-transform"
        @click="selectCard(card)"
      >
        <img :src="card.image" :alt="card.name" class="w-32 h-48 mx-auto mb-4" />
        <h2 class="text-2xl font-bold">{{ card.name }}</h2>
        <p class="text-lg mt-2">價格：0.01 ETH</p>
      </div>
    </div>

    <!-- 連接錢包與付款 Modal -->
    <div v-if="showPayModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 shadow-lg w-96 text-[#7c4585]">
        <h2 class="text-2xl font-bold text-center mb-4">連接錢包並付款</h2>
        <p class="text-center mb-4">請連接錢包並支付 <span class="font-bold">0.01 ETH</span> 以購買刮刮樂。</p>
        <button
          class="w-full bg-yellow-500 text-white py-2 rounded-lg hover:bg-yellow-600 mb-2"
          @click="pay"
        >連接錢包並付款</button>
        <button
          class="w-full bg-gray-300 text-[#7c4585] py-2 rounded-lg hover:bg-gray-400"
          @click="cancelPay"
        >取消</button>
      </div>
    </div>

    <!-- 付款完成後選擇刮開或下次再來 -->
    <div v-if="showAfterPay" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 shadow-lg w-96 text-[#7c4585] flex flex-col items-center">
        <h2 class="text-2xl font-bold text-center mb-4">購買成功！</h2>
        <div class="flex gap-4 w-full">
          <button
            class="flex-1 bg-green-500 text-white py-2 rounded-lg hover:bg-green-600"
            @click="showScratch"
          >刮開刮刮樂</button>
          <button
            class="flex-1 bg-gray-300 text-[#7c4585] py-2 rounded-lg hover:bg-gray-400"
            @click="resetScratchCard"
          >下次再來刮</button>
        </div>
      </div>
    </div>

    <!-- 刮刮樂動畫 -->
    <div v-if="showScratchModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="relative bg-white rounded-lg p-6 shadow-lg w-96">
        <h2 class="text-2xl font-bold text-center mb-4" style="color: #7c4585">刮開你的刮刮樂！</h2>
        <div class="relative w-64 h-96 mx-auto">
          <img :src="prizeImage" alt="prize" class="w-full h-full object-cover rounded" />
          <canvas
            ref="scratchCanvas"
            width="256"
            height="384"
            class="absolute inset-0 rounded"
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

    <router-link to="/cards" class="mt-8 bg-yellow-500 text-[#7c4585] py-2 px-6 rounded-lg hover:bg-yellow-600">
      我的卡片
    </router-link>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick, watch } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const scratchCards = [
  { name: '金幣卡', image: '/images/scratch-card-1.png' },
  { name: '幸運卡', image: '/images/scratch-card-2.png' },
  { name: '財神卡', image: '/images/scratch-card-3.png' }
]

const selectedCard = ref(null)
const showPayModal = ref(false)
const showAfterPay = ref(false)
const showScratchModal = ref(false)
const scratchCanvas = ref(null)
const prizeImage = ref('/images/prize.png')
let isScratching = false

const selectCard = (card) => {
  selectedCard.value = card
  showPayModal.value = true
}

const pay = () => {
  // 這裡應串接錢包與付款邏輯
  // 模擬付款成功
  showPayModal.value = false
  showAfterPay.value = true
}

const cancelPay = () => {
  showPayModal.value = false
  selectedCard.value = null
}

const showScratch = () => {
  showAfterPay.value = false
  showScratchModal.value = true
  nextTick(drawMask)
}

const resetScratchCard = () => {
  selectedCard.value = null
  showPayModal.value = false
  showAfterPay.value = false
  showScratchModal.value = false
  router.push('/cards') // 新增這行，跳回我的卡片頁面
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

watch(showScratchModal, (val) => {
  if (val) nextTick(drawMask)
})

const goBack = () => {
  router.push('/')
}
</script>

<style scoped>
/* 可根據需要添加樣式 */
</style>