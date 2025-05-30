import { defineStore } from 'pinia'
import { ethers } from 'ethers'

export const useWalletStore = defineStore('wallet', {
  state: () => ({
    address: '',
    isConnected: false,
    chainId: null,
    balance: '0',
    error: null,
    isConnecting: false,
    retryCount: 0,
    maxRetries: 3
  }),
  
  getters: {
    shortAddress: (state) => {
      if (!state.address) return ''
      return `${state.address.slice(0, 6)}...${state.address.slice(-4)}`
    },
    hasError: (state) => !!state.error,
    canRetry: (state) => state.retryCount < state.maxRetries
  },
  
  actions: {
    async connectWallet() {
      this.isConnecting = true
      this.error = null
      
      try {
        if (typeof window.ethereum === 'undefined') {
          throw new Error('請先安裝 MetaMask 錢包')
        }

        // 檢查網路連接
        if (!navigator.onLine) {
          throw new Error('請檢查您的網路連接')
        }

        const provider = new ethers.providers.Web3Provider(window.ethereum)
        
        // 檢查 MetaMask 是否已解鎖
        const accounts = await provider.listAccounts()
        if (accounts.length === 0) {
          throw new Error('請先解鎖您的 MetaMask 錢包')
        }

        await provider.send('eth_requestAccounts', [])
        const signer = provider.getSigner()
        const address = await signer.getAddress()
        const network = await provider.getNetwork()
        const balance = await provider.getBalance(address)

        this.address = address
        this.isConnected = true
        this.chainId = network.chainId
        this.balance = ethers.utils.formatEther(balance)
      } catch (error) {
        console.error('Failed to connect wallet:', error)
        this.error = this.getErrorMessage(error)
        throw error
      } finally {
        this.isConnecting = false
      }
    },

    async retryConnection() {
      if (this.retryCount >= this.maxRetries) {
        this.error = '重試次數已達上限，請稍後再試'
        return
      }
      
      this.retryCount++
      await this.connectWallet()
    },

    getErrorMessage(error) {
      if (error.code === 4001) {
        return '您拒絕了連接請求'
      } else if (error.code === -32002) {
        return '請在 MetaMask 中確認連接請求'
      } else if (error.message.includes('MetaMask')) {
        return '請確認 MetaMask 是否正確安裝並解鎖'
      } else if (error.message.includes('network')) {
        return '請確認您的網路連接狀態'
      } else {
        return '連接錢包時發生錯誤，請重試'
      }
    },

    disconnect() {
      this.address = ''
      this.isConnected = false
      this.chainId = null
      this.balance = '0'
      this.error = null
      this.retryCount = 0
    },

    clearError() {
      this.error = null
    }
  },
}) 