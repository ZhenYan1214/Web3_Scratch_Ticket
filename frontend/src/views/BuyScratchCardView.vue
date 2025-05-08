<template>
<nav class="bg-[#7c4585]/90 text-yellow-100 py-4 px-6 shadow-lg border-b border-yellow-400/30 backdrop-blur-sm">
    <div class="flex items-center">
        <span class="text-3xl font-bold text-yellow-400"  @click="goBack">Lucky  Scratch</span>
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

    <!-- 刮刮樂動畫 -->
    <div v-else class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="relative bg-white rounded-lg p-6 shadow-lg w-96">
        <h2 class="text-2xl font-bold text-center mb-4" style="color: #7c4585">刮開你的刮刮樂！</h2>
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

    <router-link to="/cards" class="mt-8 bg-yellow-500 text-[#7c4585] py-2 px-6 rounded-lg hover:bg-yellow-600">
      我的卡片
    </router-link>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const scratchCards = [
  { name: '金幣卡', image: '/images/scratch-card-1.png' },
  { name: '幸運卡', image: '/images/scratch-card-2.png' },
  { name: '財神卡', image: '/images/scratch-card-3.png' }
]

const selectedCard = ref(null)
const scratchCanvas = ref(null)
let isScratching = false

const selectCard = (card) => {
  selectedCard.value = card
}

const resetScratchCard = () => {
  selectedCard.value = null
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

onMounted(() => {
  if (scratchCanvas.value) {
    const ctx = scratchCanvas.value.getContext('2d')
    ctx.fillStyle = '#ccc'
    ctx.fillRect(0, 0, scratchCanvas.value.width, scratchCanvas.value.height)
  }
})

const goBack = () => {
  router.push('/')
}
</script>

<style scoped>
/* 可根據需要添加樣式 */
</style>