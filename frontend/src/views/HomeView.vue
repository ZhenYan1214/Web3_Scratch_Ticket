<template>
  <div class="min-h-screen bg-gradient-to-b from-red-800 via-red-700 to-red-900 overflow-hidden relative">
    <!-- 新年裝飾元素 -->
    <div class="absolute inset-0 pointer-events-none">
      <div v-for="i in 20" :key="i" class="lantern absolute" :style="{
        left: `${Math.random() * 100}%`,
        top: `${Math.random() * 100}%`,
        animationDelay: `${Math.random() * 5}s`
      }">🏮</div>
      <div v-for="i in 30" :key="`coin-${i}`" class="coin absolute" :style="{
        left: `${Math.random() * 100}%`,
        top: `${Math.random() * 100}%`,
        animationDelay: `${Math.random() * 8}s`
      }">💰</div>
    </div>

    <!-- 頂部導航欄 -->
    <nav class="bg-gradient-to-r from-red-900 to-red-800 text-yellow-100 py-4 px-6 shadow-lg border-b border-yellow-400/30 backdrop-blur-sm">
      <div class="container mx-auto flex justify-between items-center">
        <div class="flex items-center">
          <span class="text-3xl font-bold text-yellow-400">🧧 財神存錢罐</span>
        </div>
        <div class="hidden md:flex space-x-8">
          <router-link to="/" class="hover:text-yellow-400 transition-colors text-lg">🏠 首頁</router-link>
          <router-link to="/assets" class="hover:text-yellow-400 transition-colors text-lg">💰 我的資產</router-link>
          <router-link to="/records" class="hover:text-yellow-400 transition-colors text-lg">📝 存錢記錄</router-link>
          <router-link to="/leaderboard" class="hover:text-yellow-400 transition-colors text-lg">🏆 排行榜</router-link>
          <router-link to="/about" class="hover:text-yellow-400 transition-colors text-lg">ℹ️ 關於我們</router-link>
        </div>
      </div>
    </nav>

    <!-- 主要內容區 -->
    <div class="container mx-auto px-4 py-8">
      <div class="flex flex-col lg:flex-row gap-8">
        <!-- 左側：土豆流氓和新年祝福 -->
        <div class="lg:w-2/3 relative">
          <div class="bg-gradient-to-br from-red-950/80 to-red-900/80 rounded-2xl shadow-2xl p-8 text-center relative overflow-hidden border-2 border-yellow-400/50 backdrop-blur-sm">
            <div class="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-yellow-400 via-yellow-500 to-yellow-400"></div>
            <h1 class="text-4xl md:text-5xl font-bold text-yellow-400 mb-4">🎊 恭喜發財 🎊</h1>
            <p class="text-2xl text-yellow-200 mb-8">新年旺旺來，財運滾滾來！</p>
            
            <!-- 土豆流氓圖片 -->
            <div class="relative mx-auto w-72 h-72 mb-8">
              <div class="absolute inset-0 bg-yellow-400/20 rounded-full animate-pulse"></div>
              <img 
                src="/images/potato-gangster.png" 
                alt="戴墨鏡的土豆流氓" 
                class="w-full h-full object-contain animate-bounce"
              />
            </div>
            
            <!-- 獎池 -->
            <div class="bg-gradient-to-r from-yellow-500 to-yellow-600 text-red-950 rounded-xl p-8 shadow-xl mb-8 transform hover:scale-105 transition-transform border border-yellow-400/50">
              <h2 class="text-3xl font-bold mb-2">🏮 新年獎池 🏮</h2>
              <div class="text-5xl font-bold mb-2">888,888 ETH</div>
              <p class="text-lg">新年加碼！每日抽出八位幸運用戶</p>
            </div>
            
            <!-- 操作按鈕 -->
            <div class="flex flex-wrap justify-center gap-6">
              <button class="bg-gradient-to-r from-red-600 to-red-700 text-yellow-200 px-8 py-4 rounded-xl hover:from-red-700 hover:to-red-800 transition-all transform hover:scale-105 flex items-center text-xl shadow-lg border-2 border-yellow-400/30">
                <span class="text-2xl mr-2">🧧</span>
                開始存錢
              </button>
              <button class="bg-gradient-to-r from-yellow-500 to-yellow-600 text-red-950 px-8 py-4 rounded-xl hover:from-yellow-400 hover:to-yellow-500 transition-all transform hover:scale-105 flex items-center text-xl shadow-lg border-2 border-yellow-400/30">
                <span class="text-2xl mr-2">💱</span>
                代幣兌換
              </button>
            </div>
          </div>
        </div>
        
        <!-- 右側：排行榜 -->
        <div class="lg:w-1/3">
          <div class="bg-gradient-to-br from-red-950/80 to-red-900/80 rounded-2xl shadow-2xl p-6 border-2 border-yellow-400/50 backdrop-blur-sm">
            <h2 class="text-3xl font-bold text-yellow-400 mb-6 text-center">🏆 財神榜 🏆</h2>
            
            <div class="space-y-4">
              <div v-for="(user, index) in topUsers" :key="index" 
                class="flex items-center p-4 rounded-xl transition-all hover:transform hover:scale-102 bg-gradient-to-r" 
                :class="[
                  index === 0 ? 'from-yellow-500/20 to-yellow-600/20 border border-yellow-400/50' : 
                  index === 1 ? 'from-gray-500/20 to-gray-600/20 border border-gray-400/50' : 
                  index === 2 ? 'from-red-500/20 to-red-600/20 border border-red-400/50' : 
                  'from-red-950/50 to-red-900/50 border border-red-800/30'
                ]"
              >
                <div class="w-10 h-10 flex items-center justify-center rounded-full mr-4 text-xl"
                  :class="[
                    index === 0 ? 'bg-yellow-500 text-red-950' : 
                    index === 1 ? 'bg-gray-400 text-white' : 
                    index === 2 ? 'bg-red-500 text-white' : 
                    'bg-red-800/50 text-white'
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
</template>

<script setup>
import { ref } from 'vue'

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
</script>

<style scoped>
.lantern {
  font-size: 2rem;
  animation: float 3s ease-in-out infinite;
  opacity: 0.5;
}

.coin {
  font-size: 1.5rem;
  animation: spin 4s linear infinite;
  opacity: 0.3;
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