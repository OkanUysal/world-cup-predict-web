import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';
import { createProxyMiddleware } from 'http-proxy-middleware';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();
const port = process.env.PORT || 8080;
const BACKEND = 'https://world-cup-predict-be-production.up.railway.app';

app.use(
  createProxyMiddleware({
    pathFilter: '/api',
    target: BACKEND,
    changeOrigin: true,
    secure: true,
  }),
);

const dist = path.join(__dirname, 'dist');
app.use(express.static(dist));

app.get('*', (_req, res) => {
  res.sendFile(path.join(dist, 'index.html'));
});

app.listen(port, () => {
  console.log(`Server: http://0.0.0.0:${port}`);
  console.log(`API proxy: /api → ${BACKEND}/api`);
});
