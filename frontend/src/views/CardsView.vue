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
          <router-link to="/rules" class="hover:text-yellow-400 transition-colors text-lg">💰 獎池說明</router-link>
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
          :class=" [
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
        <div class="flex flex-row gap-8 px-4 snap-x snap-mandatory overflow-x-auto scrollbar-hide">
          <!-- 刮刮樂卡片 -->
          <!-- 卡片區塊 -->
          <div
            v-for="card in filteredCards"
            :key="card.id"
            class="snap-center shrink-0"
          >
            <div
              :class="[
                'bg-white text-[#7c4585] rounded-lg shadow-lg p-6 text-center min-w-[220px] w-64 h-[370px] flex flex-col items-center justify-between border-4 transition-transform duration-300 hover:scale-105',
                card.status === '待刮開'
                  ? 'border-yellow-300'
                  : card.status === '已中獎'
                  ? 'border-emerald-400'
                  : card.status === '未中獎'
                  ? 'border-gray-400'
                  : 'border-yellow-400/50',
                justAdded === card.id ? 'animate-shake-x' : ''
              ]"
               @click="card.status === '待刮開' ? openScratchModal(card) : null"
                class="cursor-pointer"
            >
              <div class="w-36 h-36 mx-auto mb-2 flex items-center justify-center rounded-lg overflow-hidden bg-white">
                <img :src="card.img" :alt="card.name" class="w-full h-full object-contain" />
              </div>
              <div class="text-2xl font-extrabold mb-1 leading-tight">{{ card.name }}</div>
              <div
                :class="[
                  'mt-1 text-lg font-bold leading-tight',
                  card.status === '已中獎'
                    ? 'text-emerald-500'
                    : card.status === '未中獎'
                    ? 'text-gray-500'
                    : 'text-yellow-500'
                ]"
              >
                {{ card.status }}
              </div>
              <div v-if="card.status === '已中獎'" class="text-yellow-500 text-xl font-bold mb-1 leading-tight">
                獎金金額
              </div>
              <div v-if="card.status === '已中獎'" class="text-3xl font-bold text-yellow-400 mb-1 leading-tight">
                {{ Number(card.amount).toFixed(4) }} ETH
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 刮刮樂動畫 Modal -->
    <div v-if="showScratchModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="relative bg-white rounded-lg p-6 shadow-lg w-96">
        <h2 class="text-2xl font-bold text-center mb-4" style="color: #7c4585">刮開你的刮刮樂！</h2>
        <div class="relative w-64 h-96 mx-auto scratch-cursor">
          <img
            :src="revealedImg"
            alt="prize"
            class="w-full h-full object-cover rounded absolute inset-0 z-0"
          />
          <canvas
            ref="scratchCanvas"
            width="256"
            height="384"
            class="absolute inset-0 rounded z-10 scratch-cursor"
            @mousedown="startScratching"
            @mousemove="scratch"
            @mouseup="stopScratching"
            @mouseleave="stopScratching"
          ></canvas>
          <!-- loading 動畫 -->
          <div v-if="revealLoading" class="absolute inset-0 flex items-center justify-center z-20 bg-white/80">
            <div class="flex flex-col items-center justify-center py-8">
              <div class="w-20 h-20 mb-4 flex items-center justify-center rounded-full bg-gradient-to-tr from-yellow-300 to-yellow-500 animate-pulse shadow-lg">
                <svg class="animate-spin w-12 h-12 text-yellow-700" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path>
                </svg>
              </div>
              <div class="text-2xl font-bold text-yellow-600 mb-2">獎項揭曉中...</div>
              <div class="text-lg text-gray-500">揭曉需要一點時間，請耐心等待</div>
            </div>
          </div>
          <!-- 結果彈窗 -->
          <div v-if="revealResult && !revealLoading" class="fixed inset-0 flex items-center justify-center z-[9999]" style="background: rgba(0,0,0,0.3);">
            <div class="bg-white rounded-2xl shadow-2xl px-8 py-8 flex flex-col items-center border-4 border-yellow-400">
              <div class="text-4xl mb-4" v-if="revealResult.amount !== '0.0'">🎉</div>
              <div class="text-2xl font-bold mb-2 text-[#7c4585]">{{ revealResult.amount !== '0.0' ? '恭喜中獎！' : '未中獎' }}</div>
              <div class="text-xl mb-1 text-[#7c4585]">汪汪說恭喜你刮到：<span class="font-bold">{{ prizeNameMap[revealResult.prize] }}！！！</span></div>
              <div class="text-xl mb-4 text-yellow-700">你獲得了：<span class="font-bold">{{ Number(revealResult.amount).toFixed(4) }} ETH！！！</span></div>
              <div v-if="revealResult.amount !== '0.0'" class="text-lg text-green-600 font-semibold mb-2">獎金已自動發送到你的錢包❤️</div>
              <button class="bg-yellow-400 text-[#7c4585] px-8 py-2 rounded-lg font-bold text-lg hover:bg-yellow-500 transition" @click="closeScratchModal">關閉</button>
            </div>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ethers } from 'ethers'

const route = useRoute()
const justAdded = ref(null)

// 取得錢包地址，例如 userAddress = '0x123...'
const userAddress = ref('')
// 讀取當前 userAddress 下的卡片
const cardRecord = ref([])

const CONTRACT_ADDRESS = '0xF689Df063700A11b5916309c382Ed5d93401927B'
const CONTRACT_ABI = [
    // 讀取函數
    "function nextTokenId() view returns (uint256)",
    "function poolBalance() view returns (uint256)",
    "function platformFee() view returns (uint256)",
    "function ownerOf(uint256 tokenId) view returns (address)",
    "function tokenIdToRandomNumber(uint256) view returns (uint256)",
    "function tokenIdToPrize(uint256) view returns (uint8)",
    "function isRevealed(uint256) view returns (bool)",
    "function getTokenInfo(uint256 tokenId) view returns (bool revealed, uint256 randomNumber, uint8 prize, uint256 potentialPrize)",
    "function getContractStats() view returns (uint256 totalSupply, uint256 currentPoolBalance, uint256 currentPlatformFee)",
    // 寫入函數
    "function mint() payable returns (uint256)",
    "function reveal(uint256 tokenId)",
    "function addToPool() payable",
    "function withdrawFee(address payable to, uint256 amount)",
    "function withdrawNative(uint256 amount)",
    // 事件
    "event PrizeClaimed(address user, uint256 tokenId, uint8 prize, uint256 amount)",
    "event RequestSent(uint256 requestId, uint32 numWords)",
    "event RequestFulfilled(uint256 requestId, uint256[] randomWords, uint256 payment)"
]

const prizeImg = ref('')
const scratchCanvas = ref(null)
let isScratching = false
const scratchedPercent = ref(0)
const prizeGiven = ref(false)
const prizeMsg = ref({
  title: '',
  text: '',
  emoji: ''
})

const revealResult = ref(null)
const revealLoading = ref(false)
const prizeOptions = [
  { img: '/images/prizes/thanks.png' },      // 0: None
  { img: '/images/prizes/feedback.png' },   // 1: Consolation
  { img: '/images/prizes/lucky.png' },      // 2: Second
  { img: '/images/prizes/goodluck.png' },   // 3: First
  { img: '/images/prizes/money.png' }       // 4: Grand
]
const prizeNameMap = {
  0: '銘謝惠顧QQ',
  1: '回饋獎',
  2: '小確幸獎',
  3: '好運滿滿獎',
  4: '金幣大放送',
  
}

const revealedImg = ref('') // canvas 下層圖片

async function loadCards() {
  console.log('📥 Loading cards for address:', userAddress.value)
  if (!userAddress.value) {
    console.log('⚠️ No user address, clearing cards')
    cardRecord.value = []
    return
  }
  let stored = localStorage.getItem(`myCards_${userAddress.value}`)
  let cards = stored ? JSON.parse(stored) : []

  // 與鏈上同步 revealed 狀態
  if (window.ethereum && cards.length > 0) {
    const provider = new ethers.BrowserProvider(window.ethereum)
    const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, provider)
    for (let i = 0; i < cards.length; i++) {
      const card = cards[i]
      if (card.tokenId !== undefined) {
        try {
          const info = await contract.getTokenInfo(card.tokenId)
          cards[i].revealed = info[0]
          cards[i].prizeEnum = Number(info[2])
          cards[i].amount = ethers.formatEther(info[3])
          cards[i].status = !info[0]
            ? '待刮開'
            : (Number(info[2]) > 0 ? '已中獎' : '未中獎')
        } catch (e) {
          console.warn('查詢鏈上卡片失敗', card.tokenId, e)
        }
      }
    }
    localStorage.setItem(`myCards_${userAddress.value}`, JSON.stringify(cards))
  }
  cardRecord.value = cards
  console.log('🎴 Loaded cards:', cardRecord.value)
}

function saveCards(cards) {
  if (!userAddress.value) return
  localStorage.setItem(`myCards_${userAddress.value}`, JSON.stringify(cards))
}

// 在 onMounted 時取得錢包地址
onMounted(async () => {
  if (window.ethereum) {
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })
    if (accounts && accounts.length > 0) {
      userAddress.value = accounts[0]
      loadCardsFromLocal() // 只在 userAddress 有值時才 load
    }
  }
})

function loadCardsFromLocal() {
  const key = `myCards_${userAddress.value}`
  let cards = JSON.parse(localStorage.getItem(key) || '[]')
  // 過濾掉沒有 tokenId 的待刮開卡片
  cards = cards.filter(card => !(card.status === '待刮開' && !card.tokenId && card.tokenId !== 0))
  // 只保留狀態正確的卡片
  const validStatus = ['待刮開', '已中獎', '未中獎']
  cards = cards.filter(card => validStatus.includes(card.status))
  cardRecord.value = cards
  localStorage.setItem(key, JSON.stringify(cards))
  console.log('Loaded cards:', cards)
}

// 監聽錢包地址變動
window.ethereum?.on('accountsChanged', (accounts) => {
  if (accounts.length > 0) {
    userAddress.value = accounts[0]
    loadCards() // 重新載入新地址的卡片
  } else {
    userAddress.value = ''
    cardRecord.value = []
  }
})

const statusTypes = ['全部', '已中獎', '未中獎', '待刮開']
const selectedStatus = ref('全部')
const filteredCards = computed(() => {
  if (selectedStatus.value === '全部') return cardRecord.value
  return cardRecord.value.filter(c => c.status === selectedStatus.value)
})

// 更新卡片狀態（在 reveal 後調用）
function updateCardStatus(tokenId, prizeEnum, prizeAmount) {
  if (!userAddress.value) return
  const myCards = JSON.parse(localStorage.getItem(`myCards_${userAddress.value}`) || '[]')
  const cardIndex = myCards.findIndex(card => card.tokenId === tokenId)
  
  if (cardIndex !== -1) {
    myCards[cardIndex] = {
      ...myCards[cardIndex],
      revealed: true,
      prizeEnum: prizeEnum,
      status: prizeEnum > 0 ? '已中獎' : '未中獎',
      amount: prizeEnum > 0 ? prizeAmount : ''
    }
    localStorage.setItem(`myCards_${userAddress.value}`, JSON.stringify(myCards))
    cardRecord.value = myCards
  }
}

// 新增卡片時，已中獎或未中獎都會存進 userAddress 專屬 localStorage
function addCardToMyCards(card, tokenId) {
  if (!userAddress.value) return
  const myCards = JSON.parse(localStorage.getItem(`myCards_${userAddress.value}`) || '[]')
  const newCard = {
    id: Date.now(),
    tokenId: tokenId,
    img: card.image,
    name: card.name,
    revealed: false,
    prizeEnum: 0,
    status: '待刮開',
    amount: ''
  }
  myCards.push(newCard)
  localStorage.setItem(`myCards_${userAddress.value}`, JSON.stringify(myCards))
  cardRecord.value = myCards
}

const scratchModalCard = ref(null)
const showScratchModal = ref(false)

function openScratchModal(card) {
  // 直接顯示正確的獎項圖
  revealedImg.value = prizeOptions[card.prizeEnum]?.img || '/images/prizes/thanks.png';
  scratchModalCard.value = card;
  prizeGiven.value = false;
  scratchedPercent.value = 0;
  showScratchModal.value = true;
  revealResult.value = null;
  revealLoading.value = false;
  nextTick(drawMask);
}

function drawMask() {
  if (scratchCanvas.value) {
    const ctx = scratchCanvas.value.getContext('2d')
    const maskImg = new window.Image()
    maskImg.src = '/images/unscratch.png'
    maskImg.onload = () => {
      ctx.globalCompositeOperation = 'source-over'
      ctx.clearRect(0, 0, scratchCanvas.value.width, scratchCanvas.value.height)
      ctx.drawImage(maskImg, 0, 0, scratchCanvas.value.width, scratchCanvas.value.height)
    }
  }
}

watch(showScratchModal, (val) => {
  if (val) nextTick(drawMask)
})

// canvas 刮開 50% 直接彈出結果彈窗
const startScratching = () => {
  isScratching = true;
}

const scratch = (event) => {
  if (!isScratching || !scratchCanvas.value) return;
  const ctx = scratchCanvas.value.getContext('2d');
  const rect = scratchCanvas.value.getBoundingClientRect();
  const x = event.clientX - rect.left;
  const y = event.clientY - rect.top;
  ctx.globalCompositeOperation = 'destination-out';
  ctx.beginPath();
  ctx.arc(x, y, 20, 0, Math.PI * 2);
  ctx.fill();

  // 計算已刮面積百分比
  const imageData = ctx.getImageData(0, 0, scratchCanvas.value.width, scratchCanvas.value.height);
  let transparent = 0;
  for (let i = 3; i < imageData.data.length; i += 4) {
    if (imageData.data[i] === 0) transparent++;
  }
  scratchedPercent.value = transparent / (scratchCanvas.value.width * scratchCanvas.value.height) * 100;

  // 若已刮超過50%，觸發 reveal 並顯示 loading
  if (scratchedPercent.value > 50 && !prizeGiven.value) {
    prizeGiven.value = true;
    revealLoading.value = true;
    revealCard(scratchModalCard.value.tokenId);
  }
}

async function revealCard(tokenId) {
  try {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);
    const tx = await contract.reveal(tokenId);
    await tx.wait();
    const info = await contract.getTokenInfo(tokenId);
    const prizeIndex = Number(info[2]);
    const amount = ethers.formatEther(info[3]);
    // 不再切換 revealedImg，canvas 下層圖片不變
    revealResult.value = {
      prize: prizeIndex,
      amount: amount
    };
    updateCardStatus(tokenId, prizeIndex, amount);
  } catch (e) {
    revealResult.value = {
      prize: 0,
      amount: '0.0'
    };
  } finally {
    revealLoading.value = false;
  }
}

const stopScratching = () => {
  isScratching = false;
}

function closeScratchModal() {
  showScratchModal.value = false
  scratchModalCard.value = null
}

// mint 成功後
function addCardAfterMint(card, tokenId) {
  const key = `myCards_${userAddress.value}`
  const cards = JSON.parse(localStorage.getItem(key) || '[]')
  const newCard = {
    id: Date.now(),
    tokenId,
    img: card.image,
    name: card.name,
    status: '待刮開',
    prize: 0
  }
  cards.push(newCard)
  localStorage.setItem(key, JSON.stringify(cards))
  cardRecord.value = cards
}

// reveal 成功後
function updateCardAfterReveal(tokenId, prizeAmount) {
  const key = `myCards_${userAddress.value}`
  const cards = JSON.parse(localStorage.getItem(key) || '[]')
  const updated = cards.map(card =>
    card.tokenId === tokenId
      ? { ...card,
          status: prizeAmount > 0 ? '已中獎' : '未中獎',
          prize: prizeAmount }
      : card
  )
  localStorage.setItem(key, JSON.stringify(updated))
  cardRecord.value = updated
}
</script>

<style scoped>
.scratch-cursor {
  cursor: url('/images/finger.png'), pointer;
}
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
@keyframes bounce-in {
  60% { transform: scale(1.1); opacity: 1; }
  80% { transform: scale(0.95); opacity: 1; }
  100% { transform: scale(1); }
  100% { transform: scale(1); }
}
.animate-bounce-in {
  animation: bounce-in 0.7s;
 animation: bounce-in 0.7s;
}
/* 新增的搖動動畫 */
@keyframes shake-x {
  0%, 100% { transform: translateX(0); }
  20% { transform: translateX(-16px); }
  40% { transform: translateX(12px); }
  60% { transform: translateX(-8px); }
  80% { transform: translateX(4px); }
  80% { transform: translateX(4px); }
}
.animate-shake-x {
  animation: shake-x 0.7s;
} 
</style>
