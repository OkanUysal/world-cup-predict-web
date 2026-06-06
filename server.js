const express = require('express');
const path = require('path');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const port = process.env.PORT || 8080;

const BACKEND = 'https://world-cup-predict-be-production.up.railway.app';

// API → backend proxy (aynı origin, CORS yok)
app.use(
  '/api',
  createProxyMiddleware({
    target: BACKEND,
    changeOrigin: true,
    secure: true,
  }),
);

// Flutter web static dosyalar
const webRoot = path.join(__dirname, 'build', 'web');
app.use(express.static(webRoot));

// SPA routing
app.get('*', (_req, res) => {
  res.sendFile(path.join(webRoot, 'index.html'));
});

app.listen(port, () => {
  console.log(`Server: http://0.0.0.0:${port}`);
  console.log(`API proxy: /api → ${BACKEND}/api`);
});
