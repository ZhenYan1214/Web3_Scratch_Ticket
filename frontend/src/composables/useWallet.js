import { useWalletStore } from '@/store/wallet'
import { storeToRefs } from 'pinia'

export function useWallet() {
  const walletStore = useWalletStore()
  const { address, isConnected, chainId, balance } = storeToRefs(walletStore)

  const connectWallet = async () => {
    try {
      await walletStore.connectWallet()
    } catch (error) {
      console.error('Failed to connect wallet:', error)
      throw error
    }
  }

  const disconnectWallet = () => {
    walletStore.disconnect()
  }

  return {
    // State
    address,
    isConnected,
    chainId,
    balance,
    
    // Methods
    connectWallet,
    disconnectWallet,
  }
} 