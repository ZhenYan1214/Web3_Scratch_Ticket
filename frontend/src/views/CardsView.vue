<template>
  <div class="min-h-screen bg-[#7c4585] overflow-hidden relative">
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

    <!-- 主要內容區 -->
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-4xl font-bold text-yellow-400 mb-8 text-center">🃏 我的刮刮樂</h1>
      <!-- 狀態篩選區塊 -->
      <div class="flex justify-center mb-8 gap-4">
        <button
          v-for="type in statusTypes"
          :key="type"
          @click="selectedStatus = type"
          :class=" [
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
        <div class="flex flex-row gap-8 px-4 snap-x snap-mandatory overflow-x-auto scrollbar-hide">
          <!-- 刮刮樂卡片 -->
          <!-- 卡片區塊 -->
          <div
            v-for="card in filteredCards"
            :key="card.id"
            class="snap-center shrink-0"
          >
            <div
              :class="[
                'bg-white text-[#7c4585] rounded-lg shadow-lg p-6 text-center min-w-[220px] w-64 h-[370px] flex flex-col items-center justify-between border-4 transition-transform duration-300 hover:scale-105',
                card.status === '待刮開'
                  ? 'border-yellow-300'
                  : card.status === '已中獎'
                  ? 'border-emerald-400'
                  : card.status === '未中獎'
                  ? 'border-gray-400'
                  : 'border-yellow-400/50',
                justAdded === card.id ? 'animate-shake-x' : ''
              ]"
               @click="card.status === '待刮開' ? openScratchModal(card) : null"
                class="cursor-pointer"
            >
              <div class="w-36 h-36 mx-auto mb-2 flex items-center justify-center rounded-lg overflow-hidden bg-white">
                <img :src="card.img" :alt="card.name" class="w-full h-full object-contain" />
              </div>
              <div class="text-2xl font-extrabold mb-1 leading-tight">{{ card.name }}</div>
              <div v-if="card.status === '已中獎'" class="text-yellow-500 text-xl font-bold mb-1 leading-tight">獎金金額</div>
              <div v-if="card.status === '已中獎'" class="text-3xl font-bold text-yellow-400 mb-1 leading-tight">
                {{ card.amount }} ETH
              </div>
              <div
                :class="[
                  'mt-1 text-lg font-bold leading-tight',
                  card.status === '已中獎'
                    ? 'text-emerald-500'
                    : card.status === '未中獎'
                    ? 'text-gray-500'
                    : 'text-yellow-500'
                ]"
              >
                {{ card.status }}
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
        <div class="relative w-64 h-96 mx-auto scratch-cursor">
          <img
            v-if="prizeImg"
            :src="prizeImg"
            alt="prize"
            class="w-full h-full object-cover rounded absolute inset-0 z-0"
          />
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
          <!-- 彈出獎勵框，z-50確保在最上層 -->
          <div
            v-if="prizeGiven"
            class="fixed inset-0 flex items-center justify-center z-[9999]"
            style="background: rgba(0,0,0,0.3);"
          >
            <div class="bg-white rounded-2xl shadow-2xl px-8 py-8 flex flex-col items-center border-4 border-yellow-400">
              <div class="text-4xl mb-4" v-if="prizeMsg.emoji">{{ prizeMsg.emoji }}</div>
              <div class="text-2xl font-bold mb-2 text-[#7c4585]">{{ prizeMsg.title }}</div>
              <div class="text-lg text-gray-700 mb-4">{{ prizeMsg.text }}</div>
              <button
                class="bg-yellow-400 text-[#7c4585] px-8 py-2 rounded-lg font-bold text-lg hover:bg-yellow-500 transition"
                @click="closeScratchModal"
              >關閉</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const justAdded = ref(null)

// 取得錢包地址，例如 userAddress = '0x123...'
const userAddress = ref('')
// 讀取當前 userAddress 下的卡片
const cardRecord = ref([])

function loadCards() {
  console.log('📥 Loading cards for address:', userAddress.value)
  if (!userAddress.value) {
    console.log('⚠️ No user address, clearing cards')
    cardRecord.value = []
    return
  }
  const stored = localStorage.getItem(`myCards_${userAddress.value}`)
  console.log('📦 Stored cards data:', stored)
  cardRecord.value = stored ? JSON.parse(stored) : []
  console.log('🎴 Loaded cards:', cardRecord.value)
}

function saveCards(cards) {
  if (!userAddress.value) return
  localStorage.setItem(`myCards_${userAddress.value}`, JSON.stringify(cards))
}

// 在 onMounted 時取得錢包地址
onMounted(async () => {
  console.log('🔍 CardsView mounted')
  if (window.ethereum) {
    try {
      console.log('🦊 MetaMask detected')
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })
      console.log('👛 Connected accounts:', accounts)
      if (accounts && accounts.length > 0) {
        userAddress.value = accounts[0]
        console.log('✅ User address set:', userAddress.value)
        loadCards() // 載入該地址的卡片
      }
    } catch (e) {
      console.error('❌ 連接錢包失敗:', e)
    }
  } else {
    console.log('⚠️ MetaMask not detected')
  }
})

// 監聽錢包地址變動
window.ethereum?.on('accountsChanged', (accounts) => {
  if (accounts.length > 0) {
    userAddress.value = accounts[0]
    loadCards() // 重新載入新地址的卡片
  } else {
    userAddress.value = ''
    cardRecord.value = []
  }
})

const statusTypes = ['全部', '已中獎', '未中獎', '待刮開']
const selectedStatus = ref('全部')
const filteredCards = computed(() => {
  if (selectedStatus.value === '全部') return cardRecord.value
  if (selectedStatus.value === '待刮開') {
    return cardRecord.value.filter(card => card.status === '待刮開')
  }
  if (selectedStatus.value === '未中獎') {
    return cardRecord.value.filter(card => card.status !== '待刮開' && Number(card.prize) === 0)
  }
  if (selectedStatus.value === '已中獎') {
    return cardRecord.value.filter(card => card.status !== '待刮開' && Number(card.prize) > 0)
  }
  return cardRecord.value
})

// 新增卡片時，已中獎或未中獎都會存進 userAddress 專屬 localStorage
function addCardToMyCards(card, resultStatus = '待刮開', prizeAmount = '') {
  if (!userAddress.value) return
  const myCards = JSON.parse(localStorage.getItem(`myCards_${userAddress.value}`) || '[]')
  const newCard = {
    id: Date.now(),
    img: card.image,
    name: card.name,
    status: resultStatus,
    amount: resultStatus === '已中獎' ? prizeAmount : ''
  }
  myCards.push(newCard)
  localStorage.setItem(`myCards_${userAddress.value}`, JSON.stringify(myCards))
  cardRecord.value = myCards
}

const scratchModalCard = ref(null)
const showScratchModal = ref(false)

function openScratchModal(card) {
  if (card.status !== '待刮開') return // 只允許待刮開
  scratchModalCard.value = card
  showScratchModal.value = true
}

function closeScratchModal() {
  showScratchModal.value = false
  scratchModalCard.value = null
}
</script>

<style scoped>
.scratch-cursor {
  cursor: url('/images/finger.png'), pointer;
}
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
@keyframes bounce-in {
  60% { transform: scale(1.1); opacity: 1; }
  80% { transform: scale(0.95); opacity: 1; }
  100% { transform: scale(1); }
  100% { transform: scale(1); }
}
.animate-bounce-in {
  animation: bounce-in 0.7s;
 animation: bounce-in 0.7s;
}
/* 新增的搖動動畫 */
@keyframes shake-x {
  0%, 100% { transform: translateX(0); }
  20% { transform: translateX(-16px); }
  40% { transform: translateX(12px); }
  60% { transform: translateX(-8px); }
  80% { transform: translateX(4px); }
  80% { transform: translateX(4px); }
}
.animate-shake-x {
  animation: shake-x 0.7s;
} 
</style>
