<template>
  <!-- 頂部導航欄 -->
    <nav class="bg-[#7c4585]/90 text-yellow-100 py-4 px-6 shadow-lg border-b border-yellow-400/30 backdrop-blur-sm">
      <div class="container mx-auto flex justify-between items-center">
        <div class="flex items-center">
          <router-link to="/home" class="text-3xl font-bold text-yellow-400 hover:text-yellow-300 transition-colors">
            Lucky Scratch
          </router-link>
        </div>
        <div class="hidden md:flex space-x-8">
          <router-link to="/home" class="hover:text-yellow-400 transition-colors text-lg">🏠 首頁</router-link>
          <router-link to="/cards" class="hover:text-yellow-400 transition-colors text-lg">🃏 我的卡片</router-link>
          <router-link to="/rules" class="hover:text-yellow-400 transition-colors text-lg">💰 獎池說明</router-link>
        </div>
      </div>
    </nav>
  <div class="min-h-screen bg-[#7c4585] flex flex-col items-center justify-center text-yellow-100">
    <h1 class="text-4xl font-bold mb-8">🎫 購買刮刮樂</h1>
    <div v-if="!selectedCard" class="flex flex-row gap-8 overflow-x-auto pb-4">
      <div
        v-for="(card, index) in scratchCards"
        :key="index"
        class="bg-white text-[#7c4585] rounded-lg shadow-lg p-6 text-center cursor-pointer hover:scale-105 transition-transform min-w-[220px]"
        @click="selectCard(card)"
      >
        <div class="w-40 h-40 mx-auto mb-4 flex items-center justify-center">
          <img
            :src="card.image"
            :alt="card.name"
            class="w-full h-full object-cover rounded-lg"
          />
        </div>
        <h2 class="text-2xl font-bold">{{ card.name }}</h2>
        <p class="text-lg mt-2">價格：0.01 ETH</p>
      </div>
    </div>

    <!-- 確認付款 Modal（不連結錢包） -->
    <div v-if="showPayModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 shadow-lg w-96 text-[#7c4585]">
        <h2 class="text-2xl font-bold text-center mb-4">確認付款</h2>
        <p class="text-center mb-4">請確認支付 <span class="font-bold">0.01 ETH</span> 以購買刮刮樂。</p>
        <button
          class="w-full bg-yellow-500 text-white py-2 rounded-lg hover:bg-yellow-600 mb-2"
          @click="pay"
        >確認付款</button>
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

    <!-- loading動畫 -->
    <div v-if="showLoading" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="flex flex-col items-center">
        <div class="loader mb-4"></div>
        <div class="text-yellow-100 text-xl font-bold">LOADING...</div>
      </div>
    </div>

    <!-- 刮刮樂動畫 -->
    <div v-if="showScratchModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="relative bg-white rounded-lg p-6 shadow-lg w-96">
        <h2 class="text-2xl font-bold text-center mb-4" style="color: #7c4585">刮開你的刮刮樂！</h2>
        <div class="relative w-64 h-96 mx-auto scratch-cursor">
          <!-- 下層：獎項圖片，依隨機結果顯示 -->
          <img
            v-if="prizeResult"
            :src="prizeResult.img"
            :alt="prizeResult.text"
            class="w-full h-full object-cover rounded absolute inset-0 z-0"
          />
          <!-- 上層：灰色遮罩 canvas -->
          <canvas
            ref="scratchCanvas"
            width="256"
            height="384"
            class="absolute inset-0 rounded z-10 scratch-cursor"
            @mousedown="startScratching"
            @mousemove="scratch"
            @mouseup="stopScratching"
            @mouseleave="stopScratching"
          ></canvas>
        </div>
      </div>
      <!-- 彈出獎勵框 -->
      <div
        v-if="showPrizeModal"
        class="fixed inset-0 flex items-center justify-center z-60"
      >
        <div class="bg-white rounded-2xl shadow-2xl px-8 py-8 flex flex-col items-center border-4 border-yellow-400">
          <div class="text-4xl mb-4" v-if="prizeMsg.emoji">{{ prizeMsg.emoji }}</div>
          <div class="text-2xl font-bold mb-2 text-[#7c4585]">{{ prizeMsg.title }}</div>
          <div class="text-lg text-gray-700 mb-4">{{ prizeMsg.text }}</div>
          <button
            class="bg-yellow-400 text-[#7c4585] px-8 py-2 rounded-lg font-bold text-lg hover:bg-yellow-500 transition"
            @click="closePrizeModal"
          >關閉</button>
        </div>
      </div>
    </div>

    <router-link to="/cards" class="mt-8 bg-yellow-500 text-[#7c4585] py-2 px-6 rounded-lg hover:bg-yellow-600">
      我的卡片
    </router-link>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()

const scratchCards = [
  { name: '金幣卡', image: '/images/card/3.png' },
  { name: '福氣卡', image: '/images/card/5.png' },
  { name: '幸運卡', image: '/images/card/2.png' },
  { name: '財神卡', image: '/images/card/4.png' },
  { name: '吉祥卡', image: '/images/card/1.png' }
]

const selectedCard = ref(null)
const showPayModal = ref(false)
const showAfterPay = ref(false)
const showScratchModal = ref(false)
const showLoading = ref(false)
const scratchCanvas = ref(null)
const prizeImage = ref('/images/prize.png')
let isScratching = false

const prizeOptions = [
  {
    img: '/images/prizes/thanks.png',
    probability: 65
  },
  {
    img: '/images/prizes/feedback.png',
    probability: 15
  },
  {
    img: '/images/prizes/lucky.png',
    probability: 10
  },
  {
    img: '/images/prizes/goodluck.png',
    probability: 5
  },
  {
    img: '/images/prizes/money.png',
    probability: 0.5
  }
]

const prizeResult = ref(null)
const scratchedPercent = ref(0)
const prizeGiven = ref(false)
const showPrizeModal = ref(false)
const prizeMsg = ref({
  title: '',
  text: '',
  emoji: ''
})

const justAddedCardId = ref(null)
const justAdded = ref(null)

onMounted(() => {
  if (route.query.justAdded) {
    justAdded.value = Number(route.query.justAdded)
    // 清除 query 參數，避免重複動畫
    history.replaceState(null, '', location.pathname)
  }
})

const selectCard = (card) => {
  selectedCard.value = card
  showPayModal.value = true
}

const pay = () => {
  // 直接模擬付款成功
  showPayModal.value = false
  showAfterPay.value = true
}

const cancelPay = () => {
  showPayModal.value = false
  selectedCard.value = null
}

const showScratch = () => {
  showAfterPay.value = false
  showLoading.value = true
  setTimeout(() => {
    prizeResult.value = getRandomPrize()
    showScratchModal.value = true
    prizeGiven.value = false
    scratchedPercent.value = 0
    showLoading.value = false
    nextTick(drawMask)
  }, 60000) // 1分鐘loading動畫
}


// 刪除這個舊的版本
// function addCardToMyCards(card) {
//   const myCards = JSON.parse(localStorage.getItem('myCards') || '[]')
//   const newCard = {
//     id: Date.now(),
    // img: card.image,
    // status: '待刮開',
    // amount: '',
    // name: card.name
  // }
  // myCards.push(newCard)
  // localStorage.setItem('myCards', JSON.stringify(myCards))
  // justAddedCardId.value = newCard.id // 標記剛加入的卡片
// }

// 保留這個新版（支援已中獎/未中獎/待刮開）
function addCardToMyCards(card, resultStatus = '待刮開', prizeAmount = '') {
  const myCards = JSON.parse(localStorage.getItem('myCards') || '[]')
  const newCard = {
    id: Date.now(),
    img: card.image,
    name: card.name,
    status: resultStatus, // '已中獎'、'未中獎'、'待刮開'
    amount: resultStatus === '已中獎' ? prizeAmount : ''
  }
  myCards.push(newCard)
  localStorage.setItem('myCards', JSON.stringify(myCards))
  justAddedCardId.value = newCard.id
}

const resetScratchCard = () => {
  if (selectedCard.value) {
    addCardToMyCards(selectedCard.value)
  }
  selectedCard.value = null
  showPayModal.value = false
  showAfterPay.value = false
  showScratchModal.value = false
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

  // 計算已刮面積百分比
  const imageData = ctx.getImageData(0, 0, scratchCanvas.value.width, scratchCanvas.value.height)
  let transparent = 0
  for (let i = 3; i < imageData.data.length; i += 4) {
    if (imageData.data[i] === 0) transparent++
  }
  scratchedPercent.value = transparent / (scratchCanvas.value.width * scratchCanvas.value.height) * 100

  // 若已刮超過40%，自動顯示獎金
  if (scratchedPercent.value > 50 && !prizeGiven.value) {
    givePrizeByImage()
    prizeGiven.value = true
  }
}

const stopScratching = () => {
  isScratching = false
}

// 根據底圖給予獎金（用彈窗顯示）
function givePrizeByImage() {
  if (!prizeResult.value) return
  let status = '未中獎'
  let amount = ''
  if (prizeResult.value.img.includes('money')) {
    prizeMsg.value = { title: '恭喜獲得 1 ETH！', text: '你中了最大獎！', emoji: '🎉' }
    status = '已中獎'
    amount = '1'
  } else if (prizeResult.value.img.includes('goodluck')) {
    prizeMsg.value = { title: '恭喜獲得 0.1 ETH！', text: '好運降臨！', emoji: '🍀' }
    status = '已中獎'
    amount = '0.1'
  } else if (prizeResult.value.img.includes('lucky')) {
    prizeMsg.value = { title: '恭喜獲得 0.05 ETH！', text: '幸運之神眷顧你！', emoji: '✨' }
    status = '已中獎'
    amount = '0.05'
  } else if (prizeResult.value.img.includes('feedback')) {
    prizeMsg.value = { title: '恭喜獲得 0.01 ETH！', text: '祝你下次中大獎！', emoji: '💌' }
    status = '已中獎'
    amount = '0.01'
  } else {
    prizeMsg.value = { title: '謝謝參與！', text: '再接再厲，下次會更好！', emoji: '🙏' }
    status = '未中獎'
    amount = ''
  }
  // 新增：記錄卡片到 myCards
  addCardToMyCards(selectedCard.value, status, amount)
  showPrizeModal.value = true
}

// 關閉彈窗
function closePrizeModal() {
  showPrizeModal.value = false
  showScratchModal.value = false   // 關閉中獎視窗時，同時關閉刮刮樂動畫
  selectedCard.value = null        // 回到購買刮刮樂頁面（顯示卡片選擇）
}

function drawMask() {
  if (scratchCanvas.value) {
    const ctx = scratchCanvas.value.getContext('2d')
    const maskImg = new window.Image()
    maskImg.src = '/images/unscratch.png'
    maskImg.onload = () => {
      ctx.globalCompositeOperation = 'source-over'
      ctx.clearRect(0, 0, scratchCanvas.value.width, scratchCanvas.value.height)
      ctx.drawImage(maskImg, 0, 0, scratchCanvas.value.width, scratchCanvas.value.height)
    }
  }
}

watch(showScratchModal, (val) => {
  if (val) nextTick(drawMask)
})

const goBack = () => {
  router.push('/')
}

const getPrizeImage = (card) => {
  // 根據選擇的卡片返回對應的獎項圖片
  return card.image.replace('/images/', '/images/prizes/').replace('.png', '-prize.png')
}

// 機率抽獎
function getRandomPrize() {
  const rand = Math.random() * 100
  let sum = 0
  for (const prize of prizeOptions) {
    sum += prize.probability
    if (rand < sum) return prize
  }
  // 若沒中，預設回傳最後一個
  return prizeOptions[prizeOptions.length - 1]
}

// 記錄卡片到歷史紀錄
function recordCard(card, resultStatus, prizeAmount = '') {
  // card: { name, image }
  const cardRecord = JSON.parse(localStorage.getItem('cardRecord') || '[]')
  cardRecord.push({
    id: Date.now(),
    name: card.name,
    img: card.image,
    status: resultStatus, // '已中獎'、'未中獎'、'待刮開'
    amount: resultStatus === '已中獎' ? prizeAmount : ''
  })
  localStorage.setItem('cardRecord', JSON.stringify(cardRecord))
}
</script>

<style scoped>
.z-60 {
  z-index: 60;
}
@keyframes bounce-in {
  0% { transform: scale(0.5); opacity: 0; }
  60% { transform: scale(1.1); opacity: 1; }
  80% { transform: scale(0.95); }
  100% { transform: scale(1); }
}
.animate-bounce-in {
  animation: bounce-in 0.7s;
}
.scratch-cursor {
  cursor: url('/images/finger.png') 16 16,auto;
}
.loader {
  border: 6px solid #f3f3f3;
  border-top: 6px solid #facc15;
  border-radius: 50%;
  width: 56px;
  height: 56px;
  animation: spin 1s linear infinite;
}
@keyframes spin {
  0% { transform: rotate(0deg);}
  100% { transform: rotate(360deg);}
}
</style>