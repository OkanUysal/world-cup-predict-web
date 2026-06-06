import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

const BACKEND = 'https://world-cup-predict-be-production.up.railway.app';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: BACKEND,
        changeOrigin: true,
        secure: true,
      },
    },
  },
});
