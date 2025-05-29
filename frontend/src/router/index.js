import { createRouter, createWebHistory } from 'vue-router'
import Website from '@/views/Website.vue'
import HomeView from '@/views/HomeView.vue'
import BuyScratchCardView from '@/views/BuyScratchCardView.vue'
import CardsView from '@/views/CardsView.vue'
import Rules from '@/views/Rules.vue'

const routes = [
  {
    path: '/',
    name: 'website',
    component: Website
  },
  {
    path: '/home',
    name: 'home',
    component: HomeView
  },
  {
    path: '/buy',
    name: 'buy',
    component: BuyScratchCardView
  },
  {
    path: '/cards',
    name: 'cards',
    component: CardsView
  },
  {
    path: '/rules',
    name: 'rules',
    component: Rules
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router