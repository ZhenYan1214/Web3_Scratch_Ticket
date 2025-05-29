<template>
  <div class="min-h-screen bg-gradient-to-b from-red-800 via-red-700 to-red-900">
    <nav class="bg-gradient-to-r from-red-900 to-red-800 text-yellow-100 py-4 px-6 shadow-lg border-b border-yellow-400/30 backdrop-blur-sm">
      <div class="container mx-auto flex justify-between items-center">
        <div class="flex items-center">
          <span class="text-3xl font-bold text-yellow-400">🧧 Lucky Scratch</span>
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

    <div class="container mx-auto px-4 py-8">
      <div class="bg-gradient-to-br from-red-950/80 to-red-900/80 rounded-2xl shadow-2xl p-8 text-center relative overflow-hidden border-2 border-yellow-400/50 backdrop-blur-sm">
        <h1 class="text-4xl font-bold text-yellow-400 mb-8">📝 存錢記錄</h1>
        <!-- 這裡可以添加存錢記錄相關的內容 -->
      </div>
    </div>
  </div>
</template>

<script setup>
// 這裡可以添加存錢記錄相關的邏輯
</script> 