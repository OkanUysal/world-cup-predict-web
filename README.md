# Dünya Kupası Tahmin — Web

Flutter Web · Riverpod · Dio

Backend: `https://world-cup-predict-be-production.up.railway.app/api/v1`

## Yerel geliştirme

```bash
flutter pub get
flutter run -d chrome
```

Console'da `API base URL: https://...` görünmeli.

> **CORS:** `flutter run` ile Chrome farklı origin'den istek atar. Backend'in `http://localhost:*` için CORS açması gerekir. curl çalışsa bile tarayıcı engelleyebilir.

## Railway deploy (Docker yok — doğrudan build)

1. GitHub'a push
2. Railway → bu repo → deploy
3. Nixpacks `scripts/railway-build.sh` ile Flutter web build alır
4. `serve` ile `build/web` static serve edilir

Railway servis ayarında **Builder: Nixpacks** olmalı (Dockerfile değil).

### Backend CORS (önemli)

Frontend Railway URL'iniz (örn. `https://world-cup-predict-web-xxx.up.railway.app`) backend CORS listesinde olmalı. Aksi halde tarayıcı isteği engeller.

## API

Detay: [user_api.md](user_api.md)

Login örneği:

```bash
curl -X POST 'https://world-cup-predict-be-production.up.railway.app/api/v1/auth/login' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"name":"admin","password":"uysal"}'
```
