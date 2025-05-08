<template>
  <div v-if="isVisible" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
    <div class="bg-white rounded-lg p-6 shadow-lg w-96">
      <h2 class="text-2xl font-bold text-center mb-4">選擇你的刮刮樂</h2>
      <div class="flex justify-around">
        <div
          v-for="(card, index) in cards"
          :key="index"
          class="cursor-pointer hover:scale-105 transition-transform"
          @click="selectCard(card)"
        >
          <img :src="card.image" :alt="card.name" class="w-24 h-36 rounded-lg shadow-md" />
          <p class="text-center mt-2">{{ card.name }}</p>
        </div>
      </div>
      <button @click="closeModal" class="mt-4 w-full bg-red-500 text-white py-2 rounded-lg hover:bg-red-600">
        取消
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, defineProps, defineEmits } from 'vue'

defineProps(['isVisible', 'cards'])
defineEmits(['close', 'select'])

const closeModal = () => {
  emit('close')
}

const selectCard = (card) => {
  emit('select', card)
}
</script>

<style scoped>
/* 可根據需要添加樣式 */
</style>