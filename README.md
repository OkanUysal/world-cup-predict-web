# Dünya Kupası Tahmin — Web

Flutter Web · Riverpod · Dio

Backend: `https://world-cup-predict-be-production.up.railway.app/api/v1`

## Yerel geliştirme

```bash
flutter pub get
flutter run -d chrome
```

## Railway deploy

Build localde, Railway `package.json` ile `build/web` dosyalarını serve eder.

```bash
flutter build web --release
git add build/web package.json
git commit -m "build web"
git push
```

Railway otomatik algılar: `npm install` → `npm start`

Local test:

```bash
flutter build web --release
npm install
npm start
```

## Backend CORS

Frontend Railway URL'iniz backend CORS listesinde olmalı.

## API

Detay: [user_api.md](user_api.md)
