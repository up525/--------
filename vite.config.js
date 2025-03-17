import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src')
    }
  },
  server: {
    port: 5173,
    open: true,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        secure: false,
        ws: true,
        configure: (proxy, options) => {
          proxy.on('error', (err, req, res) => {
            console.error('proxy error', err);
            if (!res.writableEnded) {
              res.writeHead(500, {
                'Content-Type': 'application/json',
              });
              res.end(JSON.stringify({ 
                code: 0, 
                message: '服务器连接错误，请检查后端服务是否运行' 
              }));
            }
          });
          
          proxy.on('proxyReq', (proxyReq, req, res) => {
            proxyReq.setSocketKeepAlive(true);
          });
          
          proxy.on('proxyRes', (proxyRes, req, res) => {
            console.log(`[API] ${req.method} ${req.url} => ${proxyRes.statusCode}`);
            
            proxyRes.on('error', (err) => {
              console.error('proxyRes error', err);
            });
          });
        },
        timeout: 60000,
        proxyTimeout: 60000
      }
    }
  }
})
