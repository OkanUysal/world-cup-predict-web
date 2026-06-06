const express = require('express');
const path = require('path');
const http = require('http');
const https = require('https');
const { URL } = require('url');

const app = express();
const port = process.env.PORT || 8080;
const ALLOWED_HOST = 'world-cup-predict-be-production.up.railway.app';

function setCors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader(
    'Access-Control-Allow-Methods',
    'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  );
  res.setHeader(
    'Access-Control-Allow-Headers',
    'Content-Type, Authorization, Accept',
  );
}

app.options('/api/v1/proxy', (req, res) => {
  setCors(res);
  res.sendStatus(204);
});

app.use('/api/v1/proxy', express.raw({ type: '*/*', limit: '10mb' }));

// outcome_be /api/riot/proxy ile aynı mantık
app.all('/api/v1/proxy', (req, res) => {
  setCors(res);

  const target = req.query.target;
  if (!target || typeof target !== 'string') {
    return res.status(400).json({ error: 'target query parameter required' });
  }

  let targetUrl;
  try {
    targetUrl = new URL(target);
  } catch {
    return res.status(400).json({ error: 'invalid target URL' });
  }

  if (targetUrl.hostname !== ALLOWED_HOST) {
    return res.status(400).json({ error: 'target not allowed' });
  }

  const forwardHeaders = {};
  for (const [key, val] of Object.entries(req.headers)) {
    const lower = key.toLowerCase();
    if (
      (lower === 'content-type' ||
        lower === 'authorization' ||
        lower === 'accept') &&
      val
    ) {
      forwardHeaders[key] = val;
    }
  }

  const client = targetUrl.protocol === 'https:' ? https : http;
  const proxyReq = client.request(
    targetUrl,
    { method: req.method, headers: forwardHeaders },
    (proxyRes) => {
      res.status(proxyRes.statusCode);
      setCors(res);
      for (const [k, v] of Object.entries(proxyRes.headers)) {
        if (v !== undefined) res.setHeader(k, v);
      }
      proxyRes.pipe(res);
    },
  );

  proxyReq.on('error', (err) => {
    if (!res.headersSent) {
      res.status(502).json({ error: err.message });
    }
  });

  if (req.body && req.body.length) {
    proxyReq.write(req.body);
  }
  proxyReq.end();
});

const webRoot = path.join(__dirname, 'build', 'web');
app.use(express.static(webRoot));

app.get('*', (_req, res) => {
  res.sendFile(path.join(webRoot, 'index.html'));
});

app.listen(port, () => {
  console.log(`Server: http://0.0.0.0:${port}`);
  console.log(`Proxy: /api/v1/proxy?target=<backend-url>`);
});
