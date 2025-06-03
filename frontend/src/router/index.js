import { createRouter, createWebHistory } from 'vue-router'
import Website from '@/views/Website.vue'
import HomeView from '@/views/HomeView.vue'
import BuyScratchCardView from '@/views/BuyScratchCardView.vue'
import CardsView from '@/views/CardsView.vue'
import Rules from '@/views/Rules.vue'
import PrizePoolView from '@/views/PrizePoolView.vue'

const routes = [
  {
    path: '/', 
    redirect: '/home'
  },
  /*
    {*
    path: '/',
    name: 'website',
    component: Website
  },
  */
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
  },
  {
    path: '/prizepool',
    name: 'PrizePool',
    component: PrizePoolView
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router