# Dünya Kupası Tahmin — Web

## Ortamlar

| Ortam | API URL | CORS |
|-------|---------|------|
| `flutter run` (local debug) | Doğrudan backend | Backend localhost izni gerekir |
| Railway / `npm start` (release) | `/api/v1` proxy | Gerekmez |

## Local debug

```bash
flutter run -d chrome
```

CORS hatası normal — backend `http://localhost:*` açmalı.

## Railway deploy

```bash
flutter build web --release
git add build/web lib server.js package.json
git commit -m "build web v1.0.1"
git push
```

Railway `npm install` + `npm start` çalıştırır. `server.js` `/api` isteklerini backend'e proxy eder.

Giriş ekranında `v1.0.1 · API: /api/v1` görünmeli. Eski sürüm görüyorsanız build push edilmemiştir.

## Local release test (CORS olmadan)

```bash
flutter build web --release
npm install
npm start
```

→ http://localhost:8080

## Backend

`https://world-cup-predict-be-production.up.railway.app/api/v1`

Detay: [user_api.md](user_api.md)
