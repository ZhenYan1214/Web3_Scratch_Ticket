<template>
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
  <div class="min-h-screen bg-[#7c4585] flex flex-col items-center justify-center text-yellow-100">
    <h1 class="text-4xl font-bold mb-8">🎫 購買刮刮樂</h1>
    <div v-if="!selectedCard" class="flex flex-row gap-8 overflow-x-auto pb-4">
      <div
        v-for="(card, index) in scratchCards"
        :key="index"
        class="bg-white text-[#7c4585] rounded-lg shadow-lg p-6 text-center cursor-pointer hover:scale-105 transition-transform min-w-[220px]"
        @click="selectCard(card)"
      >
        <div class="w-40 h-40 mx-auto mb-4 flex items-center justify-center">
          <img
            :src="card.image"
            :alt="card.name"
            class="w-full h-full object-cover rounded-lg"
          />
        </div>
        <h2 class="text-2xl font-bold">{{ card.name }}</h2>
        <p class="text-lg mt-2">價格：0.01 ETH</p>
      </div>
    </div>

    <!-- 確認付款 Modal（不連結錢包） -->
    <div v-if="showPayModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 shadow-lg w-96 text-[#7c4585]">
        <h2 class="text-2xl font-bold text-center mb-4">確認付款</h2>
        <p class="text-center mb-4">支付 <span class="font-bold">0.01 ETH</span> 購買刮刮樂(我只能按一下哦❤️)</p>
        <button
          class="w-full bg-yellow-500 text-white py-2 rounded-lg hover:bg-yellow-600 mb-2"
          @click="pay"
        >確認付款</button>
        <button
          class="w-full bg-gray-300 text-[#7c4585] py-2 rounded-lg hover:bg-gray-400"
          @click="cancelPay"
        >取消</button>
      </div>
    </div>

    <!-- 付款完成後選擇刮開或下次再來 -->
    <div v-if="showAfterPay" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 shadow-lg w-96 text-[#7c4585] flex flex-col items-center">
        <h2 class="text-2xl font-bold text-center mb-4">購買成功！</h2>
        <div class="flex gap-4 w-full">
          <button
            class="flex-1 bg-green-500 text-white py-2 rounded-lg hover:bg-green-600"
            @click="showScratch"
          >刮開刮刮樂</button>
          <button
            class="flex-1 bg-gray-300 text-[#7c4585] py-2 rounded-lg hover:bg-gray-400"
            @click="resetScratchCard"
          >下次再來刮</button>
        </div>
      </div>
    </div>

    <!-- loading動畫 -->
    <div v-if="showLoading" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="flex flex-col items-center">
        <div class="loader mb-4"></div>
        <div class="text-yellow-100 text-xl font-bold">{{ loadingMessage }}</div>
      </div>
    </div>

    <!-- 刮刮樂動畫 -->
    <div v-if="showScratchModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="relative bg-white rounded-lg p-6 shadow-lg w-96">
        <h2 class="text-2xl font-bold text-center mb-4" style="color: #7c4585">刮開你的刮刮樂！</h2>
        <div class="relative w-64 h-96 mx-auto scratch-cursor">
          <!-- 下層：獎項圖片，依隨機結果顯示 -->
          <img
            v-if="prizeResult"
            :src="prizeResult.img"
            :alt="prizeResult.text"
            class="w-full h-full object-cover rounded absolute inset-0 z-0"
          />
          <!-- 上層：灰色遮罩 canvas -->
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
        </div>
      </div>
      <!-- 彈出獎勵框 -->
      <div
        v-if="showPrizeModal"
        class="fixed inset-0 flex items-center justify-center z-60"
      >
        <div class="bg-white rounded-2xl shadow-2xl px-8 py-8 flex flex-col items-center border-4 border-yellow-400">
          <div class="text-4xl mb-4" v-if="prizeMsg.emoji">{{ prizeMsg.emoji }}</div>
          <div class="text-2xl font-bold mb-2 text-[#7c4585]">{{ prizeMsg.title }}</div>
          <div class="text-lg text-gray-700 mb-4">{{ prizeMsg.text }}</div>
          <div v-if="revealLoading" class="flex flex-col items-center justify-center py-8">
            <div class="w-20 h-20 mb-4 flex items-center justify-center rounded-full bg-gradient-to-tr from-yellow-300 to-yellow-500 animate-pulse shadow-lg">
              <svg class="animate-spin w-12 h-12 text-yellow-700" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path>
              </svg>
            </div>
            <div class="text-2xl font-bold text-yellow-600 mb-2">獎項揭曉中...</div>
            <div class="text-lg text-gray-500">揭曉需要一點時間，請耐心等待❤️</div>
          </div>
          <div v-else-if="revealResult" class="flex flex-col items-center justify-center py-8">
            <div class="w-20 h-20 mb-4 flex items-center justify-center rounded-full bg-gradient-to-tr from-yellow-400 to-yellow-600 shadow-xl">
              <svg v-if="revealResult.amount !== '0.0'" class="w-12 h-12 text-green-600" fill="none" viewBox="0 0 24 24">
                <path stroke="currentColor" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
              <svg v-else class="w-12 h-12 text-gray-400" fill="none" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                <path stroke="currentColor" stroke-width="2" d="M8 12h8" />
              </svg>
            </div>
            <div class="text-2xl font-bold mb-2" :class="revealResult.amount !== '0.0' ? 'text-green-700' : 'text-gray-500'">              {{ revealResult.amount !== '0.0' ? '恭喜中獎！' : '未中獎' }}
            </div>
            <div class="text-xl mb-1 text-[#7c4585]">汪汪說你刮到了：<span class="font-bold">{{ prizeNameMap[revealResult.prize] }}！！！</span></div>
            <div class="text-xl mb-4 text-yellow-700">叮咚～你收到：<span class="font-bold">{{ Number(revealResult.amount).toFixed(4) }} ETH，財運旺旺來報到！</span></div>
            <div v-if="revealResult.amount !== '0.0'" class="text-lg text-green-600 font-semibold mb-2">獎金已自動發送到你的錢包❤️</div>
            <button
              class="bg-yellow-400 text-[#7c4585] px-8 py-2 rounded-lg font-bold text-lg hover:bg-yellow-500 transition"
              @click="closePrizeModal"
            >關閉</button>
          </div>
          <div v-else-if="revealError" class="text-red-500 font-bold">{{ revealError }}</div>
        </div>
      </div>
    </div>

    <router-link to="/cards" class="mt-8 bg-yellow-500 text-[#7c4585] py-2 px-6 rounded-lg hover:bg-yellow-600">
      我的卡片
    </router-link>

    <!-- VRF loading 動畫 -->
    <div v-if="showVRFLoading" class="fixed inset-0 bg-black/50 flex flex-col items-center justify-center z-50">
      <img src="/images/正式loading2.gif" alt="Loading..." class="w-72 h-72 mb-6" />
      <div class="text-yellow-100 text-xl font-bold">財神爺正在搖金元寶，專屬幸運號碼即將降臨</div>
    </div>

    <!-- MetaMask loading 動畫 -->
    <div v-if="showMetaMaskLoading" class="fixed inset-0 bg-black/50 flex flex-col items-center justify-center z-50">
      <img src="/images/正式loading2.gif" alt="MetaMask Loading..." class="w-72 h-72 mb-6" />
      <div class="text-yellow-100 text-xl font-bold">好運旺旺來！快到 MetaMask 點擊確認</div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ethers } from 'ethers'

const router = useRouter()
const route = useRoute()

const scratchCards = [
  { name: '金幣卡', image: '/images/card/3.png' },
  { name: '福氣卡', image: '/images/card/5.png' },
  { name: '幸運卡', image: '/images/card/2.png' },
  { name: '財神卡', image: '/images/card/4.png' },
  { name: '吉祥卡', image: '/images/card/1.png' }
]

const selectedCard = ref(null)
const showPayModal = ref(false)
const showAfterPay = ref(false)
const showScratchModal = ref(false)
const showLoading = ref(false)
const scratchCanvas = ref(null)
const prizeImage = ref('/images/prize.png')
let isScratching = false

const prizeOptions = [
  { img: '/images/prizes/thanks.png' },      // 0: None
  { img: '/images/prizes/feedback.png' },   // 1: Consolation
  { img: '/images/prizes/lucky.png' },      // 2: Second
  { img: '/images/prizes/goodluck.png' },   // 3: First
  { img: '/images/prizes/money.png' }       // 4: Grand
]

const prizeResult = ref(null)
const scratchedPercent = ref(0)
const prizeGiven = ref(false)
const showPrizeModal = ref(false)
const prizeMsg = ref({
  title: '',
  text: '',
  emoji: ''
})

const justAddedCardId = ref(null)
const justAdded = ref(null)

const loadingMessage = ref('')
const tokenId = ref(null)
const randomReady = ref(false)
const showVRFLoading = ref(false)
const showMetaMaskLoading = ref(false)

// reveal 相關狀態
const revealResult = ref(null)
const revealLoading = ref(false)
const revealError = ref('')

// 新增獎項名稱對應
const prizeNameMap = {
  0: '銘謝惠顧QQ',
  1: '回饋獎',
  2: '小確幸獎',
  3: '好運滿滿獎',
  4: '金幣大放送',
  
}


// 取得錢包地址
const userAddress = ref('')

// 在 onMounted 時取得錢包地址
onMounted(async () => {
  console.log('🔍 BuyScratchCardView mounted')
  if (window.ethereum) {
    try {
      console.log('🦊 MetaMask detected')
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })
      console.log('👛 Connected accounts:', accounts)
      if (accounts && accounts.length > 0) {
        userAddress.value = accounts[0]
        console.log('✅ User address set:', userAddress.value)
      }
    } catch (e) {
      console.error('❌ 連接錢包失敗:', e)
    }
  } else {
    console.log('⚠️ MetaMask not detected')
  }

  if (route.query.justAdded) {
    justAdded.value = Number(route.query.justAdded)
    history.replaceState(null, '', location.pathname)
  }
})

const selectCard = (card) => {
  selectedCard.value = card
  showPayModal.value = true
}

const pay = () => {
  showPayModal.value = false
  showMetaMaskLoading.value = true
  buyCard();
}

const cancelPay = () => {
  showPayModal.value = false
  selectedCard.value = null
}

const showScratch = () => {
  showAfterPay.value = false
  showLoading.value = true
  setTimeout(() => {
    // prizeResult.value 已經在 mint 隨機數產生後設好
    showScratchModal.value = true
    prizeGiven.value = false
    scratchedPercent.value = 0
    showLoading.value = false
    nextTick(drawMask)
  }, 1000)
}

function addCardToMyCards(card, tokenId) {
  const key = `myCards_${userAddress.value}`
  const cards = JSON.parse(localStorage.getItem(key) || '[]')
  const newCard = {
    id: Date.now(),
    tokenId: tokenId,
    img: card.image,
    name: card.name,
    status: '待刮開',
    amount: ''
  }
  cards.push(newCard)
  localStorage.setItem(key, JSON.stringify(cards))
  console.log('🆕 New card to add:', newCard)
  console.log('💾 Saved cards to storage:', cards)
}

const resetScratchCard = () => {
  selectedCard.value = null
  showPayModal.value = false
  showAfterPay.value = false
  showScratchModal.value = false
}

const startScratching = () => {
  isScratching = true
}

const scratch = (event) => {
  if (!isScratching || !scratchCanvas.value) return
  const ctx = scratchCanvas.value.getContext('2d')
  const rect = scratchCanvas.value.getBoundingClientRect()
  const x = event.clientX - rect.left
  const y = event.clientY - rect.top
  ctx.globalCompositeOperation = 'destination-out'
  ctx.beginPath()
  ctx.arc(x, y, 20, 0, Math.PI * 2)
  ctx.fill()

  // 計算已刮面積百分比
  const imageData = ctx.getImageData(0, 0, scratchCanvas.value.width, scratchCanvas.value.height)
  let transparent = 0
  for (let i = 3; i < imageData.data.length; i += 4) {
    if (imageData.data[i] === 0) transparent++
  }
  scratchedPercent.value = transparent / (scratchCanvas.value.width * scratchCanvas.value.height) * 100

  // 若已刮超過50%，自動顯示獎金
  if (scratchedPercent.value > 50 && !prizeGiven.value) {
    givePrizeByImage()
    prizeGiven.value = true
  }
}

const stopScratching = () => {
  isScratching = false
}

async function revealCard(tokenId) {
  try {
    console.log('🔔 開始觸發 reveal，tokenId:', tokenId)
    revealLoading.value = true
    revealError.value = ''
    const provider = new ethers.BrowserProvider(window.ethereum)
    const signer = await provider.getSigner()
    const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer)
    // 呼叫 reveal
    const tx = await contract.reveal(tokenId)
    console.log('⏳ 等待 reveal 交易確認...')
    await tx.wait()
    console.log('✅ reveal 交易完成！')
    // 查詢獎項資訊
    const info = await contract.getTokenInfo(tokenId)
    // info: [revealed, randomNumber, prize, potentialPrize]
    revealResult.value = {
      prize: info[2],
      amount: ethers.formatEther(info[3])
    }
    console.log('🎉 reveal 結果:', revealResult.value)
    // === 新增：同步 localStorage ===
    if (userAddress.value) {
      const myCards = JSON.parse(localStorage.getItem(`myCards_${userAddress.value}`) || '[]')
      // 找到最後一張 status 為 '待刮開' 的卡片（剛剛 mint 的）
      for (let i = myCards.length - 1; i >= 0; i--) {
        if (myCards[i].status === '待刮開') {
          myCards[i].status = Number(info[2]) === 0 ? '未中獎' : '已中獎'
          myCards[i].prize = Number(info[2])
          myCards[i].amount = ethers.formatEther(info[3])
          break
        }
      }
      localStorage.setItem(`myCards_${userAddress.value}`, JSON.stringify(myCards))
      console.log('📝 已同步 reveal 結果到 localStorage', myCards)
    }
    // === END ===
  } catch (e) {
    revealError.value = e?.message || '揭曉失敗'
    console.error('❌ reveal 發生錯誤:', e)
  } finally {
    revealLoading.value = false
  }
}

function givePrizeByImage() {
  if (!prizeResult.value) return
  // 自動觸發 reveal
  if (tokenId.value) {
    console.log('🟡 準備自動觸發 reveal，tokenId:', tokenId.value)
    revealCard(tokenId.value)
  } else {
    console.warn('⚠️ tokenId 不存在，無法觸發 reveal')
  }
  // reveal 結果顯示由 revealCard 取得
  showPrizeModal.value = true
}

function closePrizeModal() {
  showPrizeModal.value = false
  showScratchModal.value = false   // 關閉中獎視窗時，同時關閉刮刮樂動畫
  selectedCard.value = null        // 回到購買刮刮樂頁面（顯示卡片選擇）
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

const goBack = () => {
  router.push('/')
}

const getPrizeImage = (card) => {
  // 根據選擇的卡片返回對應的獎項圖片
  return card.image.replace('/images/', '/images/prizes/').replace('.png', '-prize.png')
}

function getRandomPrize() {
  const rand = Math.random() * 100
  let sum = 0
  for (const prize of prizeOptions) {
    sum += prize.probability
    if (rand < sum) return prize
  }
  // 若沒中，預設回傳最後一個
  return prizeOptions[prizeOptions.length - 1]
}

function recordCard(card, resultStatus, prizeAmount = '') {
  // card: { name, image }
  const cardRecord = JSON.parse(localStorage.getItem('cardRecord') || '[]')
  cardRecord.push({
    id: Date.now(),
    name: card.name,
    img: card.image,
    status: resultStatus, // '已中獎'、'未中獎'、'待刮開'
    amount: resultStatus === '已中獎' ? prizeAmount : ''
  })
  localStorage.setItem('cardRecord', JSON.stringify(cardRecord))
}

// 合約資訊
const CONTRACT_ADDRESS = '0x16E8D265dd429E8592A98188c74FE7ba75648818'
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
];

async function buyCard() {
  if (!window.ethereum) {
    alert('請先安裝 MetaMask！')
    showMetaMaskLoading.value = false
    return
  }
  try {
    console.log('🚀 開始購買流程...')
    const provider = new ethers.BrowserProvider(window.ethereum)
    const signer = await provider.getSigner()
    const userAddress = await signer.getAddress()
    const balance = await provider.getBalance(userAddress)
    console.log('用戶地址:', userAddress)
    console.log('用戶餘額:', ethers.formatEther(balance), 'ETH')
    if (balance < ethers.parseEther('0.01')) {
      alert('餘額不足！需要至少 0.01 ETH')
      showMetaMaskLoading.value = false
      return
    }

    // 關閉付款視窗，顯示 MetaMask loading
    showPayModal.value = false
    showMetaMaskLoading.value = true

    try {
      const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer)
      
      // 監聽 VRF 事件
      console.log('🎯 開始監聽 VRF 事件...')
      let requestId = null
      let randomWordsReceived = false
      
      // 監聽 RequestSent 事件
      contract.on("RequestSent", (reqId, numWords) => {
        console.log('📡 VRF 請求已發送:', { requestId: reqId.toString(), numWords: numWords.toString() })
        requestId = reqId
      })

      // 監聽 RequestFulfilled 事件
      contract.on("RequestFulfilled", (reqId, randomWords, payment) => {
        console.log('🎲 VRF 回調已收到:', { 
          requestId: reqId.toString(), 
          randomWords: randomWords.map(x => x.toString()),
          payment: payment.toString()
        })
        if (reqId.toString() === requestId?.toString()) {
          randomWordsReceived = true
        }
      })

      console.log('發送 mint 交易...')
      const tx = await contract.mint({ value: ethers.parseEther('0.01'), gasLimit: 500000 })
      console.log('交易已發送，hash:', tx.hash)
      console.log('等待交易確認...')
      await tx.wait()
      console.log('✅ 交易確認成功！')

      // 關閉 MetaMask loading，顯示 VRF loading
      showMetaMaskLoading.value = false
      showVRFLoading.value = true

      // 取得 tokenId 並等待隨機數
      const nextId = await contract.nextTokenId()
      tokenId.value = nextId - 1n
      console.log('🔍 開始查詢 tokenId:', tokenId.value.toString())
      
      // 等待 VRF 回調
      let found = false
      let finalRandomNumber = 0
      for (let i = 0; i < 60; i++) {
        const randomNumber = await contract.tokenIdToRandomNumber(tokenId.value)
        console.log(`[查詢第${i+1}次] tokenId: ${tokenId.value.toString()} randomNumber: ${randomNumber.toString()}`)
        
        if (randomWordsReceived && randomNumber > 0) {
          found = true
          finalRandomNumber = randomNumber
          break
        }
        await new Promise(r => setTimeout(r, 2000))
      }

      // 移除事件監聽
      contract.removeAllListeners("RequestSent")
      contract.removeAllListeners("RequestFulfilled")

      // 關閉 VRF loading
      showVRFLoading.value = false

      if (found) {
        // 查詢合約獎項
        const info = await contract.getTokenInfo(tokenId.value)
        const prizeIndex = Number(info[2])
        prizeResult.value = { img: prizeOptions[prizeIndex]?.img || '/images/prizes/thanks.png' }
        console.log('✅ VRF 隨機數已生成:', { 
          tokenId: tokenId.value.toString(), 
          randomNumber: finalRandomNumber.toString(), 
          prizeIndex, 
          prizeImg: prizeResult.value.img 
        })
        // 將卡片加入到 localStorage
        if (selectedCard.value) {
          console.log('📝 準備將卡片加入到 localStorage:', selectedCard.value)
          addCardToMyCards(selectedCard.value, tokenId.value.toString())
        }
        showAfterPay.value = true
      } else {
        console.log('⏰ 等待隨機數超時')
        alert('等待隨機數超時，請稍後再試')
      }
    } catch (error) {
      console.error('❌ 交易失敗:', error)
      showMetaMaskLoading.value = false
      showVRFLoading.value = false
      alert('交易失敗：' + (error?.message || '請稍後再試'))
      return
    }
  } catch (error) {
    console.error('❌ 初始化失敗:', error)
    showMetaMaskLoading.value = false
    showVRFLoading.value = false
    alert('初始化失敗：' + (error?.message || '請稍後再試'))
  }
}
</script>

<style scoped>
.z-60 {
  z-index: 60;
}
@keyframes bounce-in {
  0% { transform: scale(0.5); opacity: 0; }
  60% { transform: scale(1.1); opacity: 1; }
  80% { transform: scale(0.95); }
  100% { transform: scale(1); }
}
.animate-bounce-in {
  animation: bounce-in 0.7s;
}
.scratch-cursor {
  cursor: url('/images/finger.png') 16 16,auto;
}
.loader {
  border: 6px solid #f3f3f3;
  border-top: 6px solid #facc15;
  border-radius: 50%;
  width: 56px;
  height: 56px;
  animation: spin 1s linear infinite;
}
@keyframes spin {
  0% { transform: rotate(0deg);}
  100% { transform: rotate(360deg);}
}
</style>