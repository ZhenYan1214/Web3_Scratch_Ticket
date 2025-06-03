<!-- filepath: c:\Users\Goo\Desktop\codeee\dapp\Web3_Scratch_Ticket\frontend\src\views\PrizePoolView.vue -->
<template>
  <div class="min-h-screen bg-[#7c4585] overflow-hidden flex flex-col items-center justify-center text-yellow-100">
    <!-- 頂部導航欄 -->
    <nav class="bg-[#7c4585]/90 text-yellow-100 py-4 px-6 shadow-lg border-b border-yellow-400/30 backdrop-blur-sm w-full">
      <div class="container mx-auto flex justify-between items-center">
        <div class="flex items-center">
          <router-link to="/home" class="text-3xl font-bold text-yellow-400 hover:text-yellow-300 transition-colors">
            Lucky Scratch
          </router-link>
        </div>
        <div class="hidden md:flex space-x-8">
          <router-link to="/home" class="hover:text-yellow-400 transition-colors text-lg">🏠 首頁</router-link>
          <router-link to="/cards" class="hover:text-yellow-400 transition-colors text-lg">🃏 我的卡片</router-link>
          <router-link to="/prizepool" class="hover:text-yellow-400 transition-colors text-lg">💰 獎池資訊</router-link>
          <router-link to="/rules" class="hover:text-yellow-400 transition-colors text-lg">📜 規則說明</router-link>
        </div>
      </div>
    </nav>
    <div class="flex-1 flex flex-col items-center justify-center w-full">
      <h1 class="text-4xl font-bold mb-8 text-center">🏆 獎池資訊</h1>
      <div class="bg-white/90 rounded-lg shadow-lg p-8 text-[#7c4585] w-full max-w-xl mx-auto">
        <h2 class="text-2xl font-bold mb-4 text-center">目前獎池總額</h2>
        <div class="text-3xl font-extrabold text-yellow-500 mb-6 text-center">10.00 ETH</div>
        <p class="mb-4 text-center">獎池會隨著玩家購買刮刮樂自動累積，並定期發放給幸運玩家！</p>
        <ul class="list-disc pl-6 text-lg">
          <li>金幣大放送：可獲得獎池金額的40%</li>
          <li>好運滿滿獎：可獲得獎池金額的15%</li>
          <li>小確幸獎：可獲得獎池金額的5%</li>
          <li>回饋獎：可獲得獎池金額的2%</li>
        </ul>
      </div>
    </div>
  </div>
</template>