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
              class="w-72 h-96 bg-gradient-to-br from-[#7c4585]/80 to-purple-900/80 rounded-2xl shadow-2xl p-6 backdrop-blur-sm transform transition-all duration-300 hover:scale-105"
              :class=" [
                card.status === '待刮開'
                  ? 'cursor-pointer ring-2 ring-yellow-300 border-2 border-yellow-300'
                  : card.status === '已中獎'
                  ? 'border-2 border-emerald-400 ring-2 ring-emerald-300'
                  : card.status === '未中獎'
                  ? 'border-2 border-gray-400 ring-2 ring-gray-300'
                  : 'border-2 border-yellow-400/50'
              ]"
              @click="card.status === '待刮開' && goToScratch(card)"
            >
              <div class="h-full flex flex-col items-center justify-between">
                <div class="w-32 h-32 rounded-full bg-gradient-to-br from-yellow-400 to-yellow-600 flex items-center justify-center mb-4 overflow-hidden">
                  <img :src="card.img" alt="card" class="w-full h-full object-cover" />
                </div>
                <div class="text-center">
                  <div v-if="card.status === '已中獎'" class="text-yellow-400 text-xl font-bold mb-2">獎金金額</div>
                  <div v-if="card.status === '已中獎'" class="text-3xl font-bold text-yellow-300">
                    {{ card.amount }} ETH
                  </div>
                  <div class="text-yellow-200 mt-2">{{ card.status }}</div>
                </div>
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
import { ref, computed } from 'vue'
const statusTypes = ['全部', '已中獎', '未中獎', '待刮開']
const selectedStatus = ref('全部')

// 卡片圖片資源
const cardImages = [
  '/images/card/1.png',
  '/images/card/2.png',
  '/images/card/3.png',
  '/images/card/4.png',
  '/images/card/5.png'
]

// 卡片數據（每張卡隨機一張圖）
function getRandomImg() {
  return cardImages[Math.floor(Math.random() * cardImages.length)]
}
const cards = ref([
  { id: 1, img: getRandomImg(), amount: '0.5', status: '已中獎' },
  { id: 2, img: getRandomImg(), amount: '0.8', status: '未中獎' },
  { id: 3, img: getRandomImg(), amount: '1.2', status: '待刮開' },
  { id: 4, img: getRandomImg(), amount: '0.3', status: '已中獎' },
  { id: 5, img: getRandomImg(), amount: '2.0', status: '待刮開' },
  { id: 6, img: getRandomImg(), amount: '0.6', status: '未中獎' }
])

const filteredCards = computed(() => {
  if (selectedStatus.value === '全部') return cards.value
  return cards.value.filter(card => card.status === selectedStatus.value)
})

const showScratchModal = ref(false)
const selectedCard = ref(null)

function goToScratch(card) {
  selectedCard.value = card
  showScratchModal.value = true
  // 其他初始化動畫的程式
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