# Dünya Kupası Tahmin — React Web

React + Vite + Express. Railway'de otomatik build alır.

## Özellikler

- Giriş / Kayıt
- Tahminler (açık / bekleyen / tamamlanan)
- Event detay + tahmin girme
- Sıralama tablosu
- Profil

## Local geliştirme

```bash
npm install
npm run dev
```

→ http://localhost:5173 (Vite `/api` proxy → backend)

## Production build

```bash
npm install
npm run build
npm start
```

→ http://localhost:8080

## Railway deploy

Railway Node projesi olarak algılar:

1. **Build command:** `npm run build`
2. **Start command:** `npm start`

`server.js` static dosyaları (`dist/`) sunar ve `/api` isteklerini backend'e proxy eder — CORS sorunu olmaz.

```bash
git add .
git commit -m "React rewrite v2.0.0"
git push
```

Giriş ekranında `v2.0.0 · /api/v1` görünmeli.

## Backend

`https://world-cup-predict-be-production.up.railway.app/api/v1`

Detay: [user_api.md](user_api.md)
