<template>
  <div class="min-h-screen bg-gradient-to-b from-red-100 to-yellow-100 overflow-hidden">
    <!-- 頂部導航欄 -->
    <nav class="bg-red-800 text-white py-3 px-6 shadow-lg">
      <div class="container mx-auto flex justify-between items-center">
        <div class="flex items-center">
          <span class="text-2xl font-bold">財神存錢罐</span>
        </div>
        <div class="hidden md:flex space-x-6">
          <a href="#" class="hover:text-yellow-300 transition-colors">首頁</a>
          <a href="#" class="hover:text-yellow-300 transition-colors">我的資產</a>
          <a href="#" class="hover:text-yellow-300 transition-colors">存錢記錄</a>
          <a href="#" class="hover:text-yellow-300 transition-colors">排行榜</a>
          <a href="#" class="hover:text-yellow-300 transition-colors">關於我們</a>
        </div>
      </div>
    </nav>

    <!-- 主要內容區 -->
    <div class="container mx-auto px-4 py-8">
      <div class="flex flex-col lg:flex-row gap-8">
        <!-- 左側：土豆流氓和撒錢動畫 -->
        <div class="lg:w-2/3 relative">
          <div class="bg-white rounded-lg shadow-xl p-6 text-center relative overflow-hidden">
            <h1 class="text-3xl md:text-4xl font-bold text-red-800 mb-4">歡迎來到財神存錢罐</h1>
            <p class="text-xl text-gray-700 mb-8">智能理財，安全可靠，讓你的財富穩步增長</p>
            
            <!-- 土豆流氓圖片 -->
            <div class="relative mx-auto w-64 h-64 mb-8">
              <img 
                src="/images/potato-gangster.png" 
                alt="戴墨鏡的土豆流氓" 
                class="w-full h-full object-contain animate-bounce"
              />
              
              <!-- 撒錢動畫 -->
              <div class="money-animation">
                <div v-for="i in 20" :key="i" class="money-item" :style="{ 
                  left: `${Math.random() * 100}%`, 
                  top: `${Math.random() * 100}%`,
                  animationDelay: `${Math.random() * 5}s`,
                  animationDuration: `${3 + Math.random() * 5}s`
                }">
                  <span v-if="i % 2 === 0" class="text-yellow-500 text-4xl">$</span>
                  <span v-else class="text-yellow-500 text-4xl">¥</span>
                </div>
              </div>
            </div>
            
            <!-- 獎池 -->
            <div class="bg-gradient-to-r from-red-600 to-red-800 text-white rounded-lg p-6 shadow-lg mb-8">
              <h2 class="text-2xl font-bold mb-2">當前獎池</h2>
              <div class="text-4xl font-bold text-yellow-300">100,000 ETH</div>
              <p class="text-sm mt-2">每週抽取幸運用戶獲得獎勵</p>
            </div>
            
            <!-- 操作按鈕 -->
            <div class="flex flex-wrap justify-center gap-4">
              <button class="bg-red-600 text-white px-6 py-3 rounded-lg hover:bg-red-700 transition-colors flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                開始存錢
              </button>
              <button class="bg-yellow-500 text-white px-6 py-3 rounded-lg hover:bg-yellow-600 transition-colors flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
                </svg>
                代幣兌換
              </button>
            </div>
          </div>
        </div>
        
        <!-- 右側：排行榜 -->
        <div class="lg:w-1/3">
          <div class="bg-white rounded-lg shadow-xl p-6">
            <h2 class="text-2xl font-bold text-red-800 mb-4 text-center">財富排行榜</h2>
            
            <div class="space-y-4">
              <div v-for="(user, index) in topUsers" :key="index" 
                class="flex items-center p-3 rounded-lg" 
                :class="index === 0 ? 'bg-yellow-100' : index === 1 ? 'bg-gray-100' : index === 2 ? 'bg-red-100' : ''"
              >
                <div class="w-8 h-8 flex items-center justify-center rounded-full mr-3"
                  :class="index === 0 ? 'bg-yellow-500 text-white' : index === 1 ? 'bg-gray-400 text-white' : index === 2 ? 'bg-red-500 text-white' : 'bg-gray-200'"
                >
                  {{ index + 1 }}
                </div>
                <div class="flex-1">
                  <div class="font-semibold">{{ user.name }}</div>
                  <div class="text-sm text-gray-500">{{ user.amount }} ETH</div>
                </div>
                <div class="text-yellow-500">
                  <svg v-if="index < 3" xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
                  </svg>
                </div>
              </div>
            </div>
            
            <div class="mt-6 text-center">
              <button class="text-red-600 hover:text-red-800 transition-colors">
                查看完整排行榜
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

// 排行榜數據
const topUsers = ref([
  { name: '財神爺', amount: '1,234,567' },
  { name: '金元寶', amount: '987,654' },
  { name: '富貴花', amount: '876,543' },
  { name: '發財貓', amount: '765,432' },
  { name: '招財狗', amount: '654,321' },
  { name: '聚寶盆', amount: '543,210' },
  { name: '搖錢樹', amount: '432,109' },
  { name: '財運到', amount: '321,098' }
])
</script>

<style scoped>
/* 撒錢動畫 */
.money-animation {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.money-item {
  position: absolute;
  animation: fall linear infinite;
  opacity: 0;
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
    transform: translateY(1000%) rotate(360deg);
    opacity: 0;
  }
}
</style> 