# Dünya Kupası Tahmin — Web

Flutter Web ile geliştirilmiş, mobil uyumlu Dünya Kupası tahmin uygulaması.

## Özellikler

- Giriş / kayıt (kanal kodu ile)
- Tahminler: Açık, Bekleyen, Tamamlanan sekmeleri
- Maç skoru ve şampiyon/ikinci/üçüncü tahminleri
- Kanal sıralaması (leaderboard)
- Profil ve çıkış

## API

Backend: `https://world-cup-predict-be-production.up.railway.app/api/v1`

Login örneği:

```bash
curl -X POST 'https://world-cup-predict-be-production.up.railway.app/api/v1/auth/login' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"name":"admin","password":"uysal"}'
```

Detaylı API dokümantasyonu: [user_api.md](user_api.md)

## Yerel Test

### Yöntem 1 — Docker (önerilen, CORS sorunu yok)

Nginx, `/api/v1` isteklerini backend'e proxy eder:

```bash
docker build -t wc-predict-web .
docker run -p 8080:8080 wc-predict-web
```

Tarayıcıda: http://localhost:8080

### Yöntem 2 — `flutter run` (backend CORS gerekir)

```bash
flutter pub get
flutter run -d chrome
```

Chrome, farklı origin'e istek atar. Backend'in `http://localhost:*` origin'ine CORS izni vermesi gerekir. Aksi halde "Sunucuya bağlanılamadı" hatası alırsınız — curl çalışsa bile tarayıcı engeller.

API URL [`lib/config/api_config.dart`](lib/config/api_config.dart) içinde sabittir; `--dart-define` gerekmez.

## Railway Deploy

1. GitHub'a push
2. Railway → New Project → Deploy from GitHub
3. Dockerfile otomatik algılanır
4. Production build nginx proxy kullanır (`/api/v1` → backend)

## Proje Yapısı

```
lib/
├── config/          # API URL (sabit)
├── core/            # API client, router, tema
├── models/          # DTO modelleri
├── repositories/    # API katmanı
├── providers/       # Riverpod state
├── screens/         # UI ekranları
└── widgets/         # Paylaşılan widget'lar
```

## Teknolojiler

Flutter Web · Riverpod · go_router · Dio · shared_preferences
