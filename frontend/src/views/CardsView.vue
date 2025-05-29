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
      <!-- 這裡是動畫內容 -->
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const justAdded = ref(null)
const showScratchModal = ref(false)

// 讀取 localStorage 中的卡片資料
const myCards = ref([])

function loadCardsFromStorage() {
  const stored = localStorage.getItem('myCards')
  if (stored) {
    try {
      myCards.value = JSON.parse(stored)
    } catch {
      myCards.value = []
    }
  } else {
    myCards.value = []
  }
}

onMounted(() => {
  loadCardsFromStorage()
  ensureDefaultCards()
  if (route.query.justAdded) {
    justAdded.value = Number(route.query.justAdded)
    history.replaceState(null, '', location.pathname)
  }
})

const statusTypes = ['全部', '已中獎', '未中獎', '待刮開']
const selectedStatus = ref('全部')
const filteredCards = computed(() => {
  if (selectedStatus.value === '全部') return myCards.value
  return myCards.value.filter(card => card.status === selectedStatus.value)
})

// 新增卡片時，已中獎或未中獎都會存進 localStorage
function addCard(resultStatus, prizeAmount, selectedCard) {
  const newCard = {
    id: Date.now(),
    img: selectedCard.value.image,
    name: selectedCard.value.name,
    status: resultStatus,
    amount: resultStatus === '已中獎' ? prizeAmount : ''
  }
  myCards.value.push(newCard)
  localStorage.setItem('myCards', JSON.stringify(myCards.value))
}
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
@keyframes bounce-in {
  0% { transform: scale(0.5); opacity: 0; }
  60% { transform: scale(1.1); opacity: 1; }
  80% { transform: scale(0.95); }
  100% { transform: scale(1); }
}
.animate-bounce-in {
  animation: bounce-in 0.7s;
}

/* 新增的搖動動畫 */
@keyframes shake-x {
  0%, 100% { transform: translateX(0); }
  20% { transform: translateX(-16px); }
  40% { transform: translateX(12px); }
  60% { transform: translateX(-8px); }
  80% { transform: translateX(4px); }
}
.animate-shake-x {
  animation: shake-x 0.7s;
}
</style>