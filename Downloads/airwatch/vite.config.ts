import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  // ← שנה 'airwatch-il' לשם ה-repo המדויק שלך ב-GitHub
  base: '/airwatch-il/',
  server: {
    proxy: {
      '/api/oref': {
        target: 'https://www.oref.org.il',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api\/oref/, ''),
        headers: {
          Referer: 'https://www.oref.org.il/',
          'X-Requested-With': 'XMLHttpRequest',
        },
      },
    },
  },
})
