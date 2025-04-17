import { ethers } from 'ethers'

export const formatAddress = (address) => {
  if (!address) return ''
  return `${address.slice(0, 6)}...${address.slice(-4)}`
}

export const formatEther = (wei) => {
  if (!wei) return '0'
  return ethers.utils.formatEther(wei)
}

export const formatUSD = (amount) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(amount)
}

export const formatDate = (timestamp) => {
  return new Date(timestamp).toLocaleDateString()
} 