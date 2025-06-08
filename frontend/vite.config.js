import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

const isGhPages = process.env.GH_PAGES === 'true'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  base: isGhPages
    ? '/Web3_Scratch_Ticket/'   // 只有你跑 GH-Pages 部署時，記得 set GH_PAGES=true
    : '/',                       // Vercel（和本地 dev）都用 '/'
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    }
  },
  server: {
    port: 8080,
    strictPort: true // 強制使用指定端口，如果被占用則報錯
  }
}) 