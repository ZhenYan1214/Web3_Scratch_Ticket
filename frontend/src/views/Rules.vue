<template>
  <div class="min-h-screen bg-[#7c4585] relative overflow-hidden">
    <!-- 導覽列 -->
    <nav class="bg-[#7c4585]/90 text-yellow-100 py-4 px-6 shadow-lg border-b border-yellow-400/30 backdrop-blur-sm sticky top-0 z-50">
      <div class="container mx-auto flex justify-between items-center">
        <div class="flex items-center">
          <router-link to="/home" class="text-3xl font-bold text-yellow-400 hover:text-yellow-300 transition-colors">
            Lucky Scratch
          </router-link>
        </div>
        <div class="flex space-x-8">
          <router-link to="/home" class="hover:text-yellow-400 transition-colors text-lg">🏠 首頁</router-link>
          <router-link to="/cards" class="hover:text-yellow-400 transition-colors text-lg">🃏 我的卡片</router-link>
          <router-link to="/buy" class="hover:text-yellow-400 transition-colors text-lg">🛒 購買刮刮樂</router-link>
           <router-link to="/prizepool" class="hover:text-yellow-400 transition-colors text-lg">💰 獎池說明</router-link>
          
        </div>
      </div>
    </nav>

    <!-- 動態背景效果 -->
    <div class="absolute inset-0">
      <!-- 光暈效果 -->
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_50%_50%,rgba(255,215,0,0.15),transparent_70%)] animate-pulse"></div>
      <!-- 浮動的金幣和符號 -->
      <div class="coins-container">
        <div v-for="i in 30" :key="i" class="coin-symbol" :style="{
          left: `${Math.random() * 100}%`,
          top: `${Math.random() * 100}%`,
          animationDelay: `${Math.random() * 10}s`,
          fontSize: `${Math.random() * 20 + 20}px`
        }">
          {{ ['💰', '🪙', '💎', '✨'][Math.floor(Math.random() * 4)] }}
        </div>
      </div>
      <!-- 福字裝飾 -->
      <div class="absolute top-10 left-10 transform -rotate-12 opacity-20 text-8xl text-yellow-500 animate-float-slow">福</div>
      <div class="absolute bottom-10 right-10 transform rotate-12 opacity-20 text-8xl text-yellow-500 animate-float-slow">財</div>
    </div>

    <!-- 主要內容 -->
    <div class="relative z-10 container mx-auto px-4 py-12 min-h-screen flex flex-col items-center justify-center">
      <!-- Logo 區域 -->
      <div class="text-center mb-12 transform hover:scale-105 transition-transform duration-500">
        <div class="relative inline-block">
          <h1 class="text-4xl md:text-5xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-yellow-400 via-yellow-300 to-yellow-400 mb-6 animate-title-shine">
            財神存錢罐
          </h1>
          <p class="text-2xl md:text-3xl text-red-100 font-medium mt-4 animate-fade-in">
            Web3 時代的智能理財新選擇
          </p>
        </div>
      </div>

      <!-- 兩大區塊左右排列 -->
      <div class="w-full flex flex-col md:flex-row gap-8 items-stretch justify-center mb-12">
        <!-- 獎池資訊 -->
        <div class="flex-1 bg-white/90 rounded-lg shadow-lg p-8 max-w-xl mx-auto flex flex-col">
          <h2 class="text-3xl font-bold mb-6 text-center" style="color: #7c4585;">🏆 獎池資訊</h2>
          <span>
            <h3 class="text-2xl font-bold mb-4 text-center" style="color: #7c4585;">目前獎池總額</h3>
            <p class="text-3xl font-extrabold text-yellow-500 mb-6 text-center">10.00 ETH</p>
          </span>
          <ul class="list-disc pl-6 text-lg" style="color: #7c4585;">
            <li>金幣大放送：可獲得獎池金額的40%</li>
            <li>好運滿滿獎：可獲得獎池金額的15%</li>
            <li>小確幸獎：可獲得獎池金額的5%</li>
            <li>回饋獎：可獲得獎池金額的2%</li>
          </ul>
        </div>
        <!-- 規則說明 -->
        <div class="flex-1 bg-white/90 rounded-lg shadow-lg p-8 max-w-xl mx-auto flex flex-col">
          <h2 class="text-3xl font-bold mb-6 text-center" style="color: #7c4585;">📜 規則說明</h2>
          <ul class="list-decimal pl-6 text-lg space-y-3" style="color: #7c4585;">
            <li>連接錢包後可購買刮刮樂，每張 0.01 ETH。</li>
            <li>刮開刮刮樂有機會獲得不同獎項，最高可得金幣大放送獎！</li>
            <li>每日抽取八位幸運用戶，獎池金額每日更新。</li>
            <li>所有過程皆由智能合約自動執行，公平公正。</li>
          </ul>
        </div>
      </div>
  

      <!-- 底部資訊 -->
      <div class="absolute bottom-8 left-0 right-0 text-center">
        <div class="special-offer">
          <span class="icon">🎁</span>
          <span class="text">新年限定：連接錢包即可參與 888 ETH 限時空投</span>
          <span class="icon">🎁</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// 無AOS動畫，無需特別JS
</script>

<style scoped>
/* 動畫關鍵幀 */
@keyframes float {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  50% { transform: translateY(-20px) rotate(5deg); }
}

@keyframes shine {
  0% { background-position: -200% center; }
  100% { background-position: 200% center; }
}

@keyframes pulse-glow {
  0%, 100% { opacity: 0.6; }
  50% { opacity: 1; }
}

@keyframes coin-float {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  50% { transform: translateY(-100px) rotate(180deg); }
}

/* 基礎樣式 */
.feature-card {
  @apply relative bg-gradient-to-br from-red-900/40 to-purple-900/40 p-8 rounded-2xl backdrop-blur-sm border border-red-500/30 text-center transform transition-all duration-500 hover:scale-105 overflow-hidden;
}

.card-content {
  @apply relative z-10;
}

.card-glow {
  @apply absolute inset-0 bg-gradient-to-r from-yellow-500/20 to-red-500/20 opacity-0 transition-opacity duration-300;
}

.feature-card:hover .card-glow {
  @apply opacity-100;
}

.icon-wrapper {
  @apply flex justify-center items-center mb-4;
}

/* 錯誤訊息樣式 */
.error-message {
  @apply flex items-center justify-center space-x-2 text-red-300 bg-red-900/50 px-6 py-3 rounded-xl backdrop-blur-sm border border-red-500/30;
}

/* 提示文字樣式 */
.connect-hint {
  @apply text-red-200 text-lg;
}

/* 特別優惠樣式 */
.special-offer {
  @apply inline-flex items-center space-x-3 bg-red-900/30 px-6 py-3 rounded-full backdrop-blur-sm border border-red-500/30;
}

.special-offer .icon {
  @apply text-xl animate-bounce;
}

.special-offer .text {
  @apply text-red-100;
}

/* 浮動元素動畫 */
.coin-symbol {
  @apply absolute;
  animation: coin-float 15s ease-in-out infinite;
}

/* 標題動畫 */
.animate-title-shine {
  background-size: 200% auto;
  animation: shine 3s linear infinite;
}

.animate-float-slow {
  animation: float 8s ease-in-out infinite;
}

.animate-fade-in {
  animation: fadeIn 1s ease-out forwards;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
