import { defineStore } from 'pinia'
import { ethers } from 'ethers'

export const useWalletStore = defineStore('wallet', {
  state: () => ({
    address: '',
    isConnected: false,
    chainId: null,
    balance: '0',
  }),
  
  getters: {
    shortAddress: (state) => {
      if (!state.address) return ''
      return `${state.address.slice(0, 6)}...${state.address.slice(-4)}`
    },
  },
  
  actions: {
    async connectWallet() {
      try {
        if (typeof window.ethereum === 'undefined') {
          throw new Error('MetaMask is not installed')
        }

        const provider = new ethers.providers.Web3Provider(window.ethereum)
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
        throw error
      }
    },

    disconnect() {
      this.address = ''
      this.isConnected = false
      this.chainId = null
      this.balance = '0'
    },
  },
}) 