<template>
  <div class="min-h-screen bg-[#7c4585] overflow-hidden relative">
    <!-- 頂部導航欄 -->
    <nav class="bg-[#7c4585]/90 text-yellow-100 py-4 px-6 shadow-lg border-b border-yellow-400/30 backdrop-blur-sm">
      <div class="container mx-auto flex justify-between items-center">
        <div class="flex items-center">
          <span class="text-3xl font-bold text-yellow-400">Lucky Scratch</span>
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
      
      <!-- 卡片滑動區域 -->
      <div class="relative overflow-x-auto pb-8">
        <div class="flex space-x-6 px-4 snap-x snap-mandatory overflow-x-auto scrollbar-hide">
          <!-- 刮刮樂卡片 -->
          <div v-for="card in cards" :key="card.id" class="snap-center shrink-0">
            <div class="w-72 h-96 bg-gradient-to-br from-[#7c4585]/80 to-purple-900/80 rounded-2xl shadow-2xl p-6 border-2 border-yellow-400/50 backdrop-blur-sm transform transition-all duration-300 hover:scale-105">
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
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

// 卡片數據
const cards = ref([
  { id: 1, symbol: '🎰', amount: '0.5', status: '已中獎' },
  { id: 2, symbol: '💎', amount: '0.8', status: '已中獎' },
  { id: 3, symbol: '🎲', amount: '1.2', status: '待刮開' },
  { id: 4, symbol: '🎯', amount: '0.3', status: '已中獎' },
  { id: 5, symbol: '🎪', amount: '2.0', status: '待刮開' },
  { id: 6, symbol: '🎨', amount: '0.6', status: '待刮開' }
])
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
</style> 