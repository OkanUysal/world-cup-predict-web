# Dünya Kupası Tahmin — Web

Flutter Web ile geliştirilmiş, mobil uyumlu Dünya Kupası tahmin uygulaması.

## Özellikler

- Giriş / kayıt (kanal kodu ile)
- Tahminler: Açık, Bekleyen, Tamamlanan sekmeleri
- Maç skoru ve şampiyon/ikinci/üçüncü tahminleri
- Kanal sıralaması (leaderboard)
- Profil ve çıkış

## Gereksinimler

- Flutter 3.x (stable)
- Chrome (web geliştirme için)

## Yerel Geliştirme

```bash
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=https://world-cup-predict-be-production.up.railway.app/api/v1
```

## API

Backend base URL: `https://world-cup-predict-be-production.up.railway.app/api/v1`

Detaylı API dokümantasyonu: [user_api.md](user_api.md)

## Railway Deploy

1. Repo'yu GitHub'a push edin
2. [Railway](https://railway.app) → New Project → Deploy from GitHub
3. Bu repo'yu seçin — Dockerfile otomatik algılanır
4. Deploy tamamlandığında public URL alın
5. **CORS:** Backend'in frontend origin'ine izin verdiğinden emin olun

### Ortam Değişkenleri

API URL build sırasında `--dart-define=API_BASE_URL=...` ile gömülür. Farklı bir backend için Dockerfile'daki `ARG` veya build komutunu güncelleyin.

## Proje Yapısı

```
lib/
├── config/          # API yapılandırması
├── core/            # API client, router, tema, widget'lar
├── models/          # DTO modelleri
├── repositories/    # API repository katmanı
├── providers/       # Riverpod state
├── screens/         # UI ekranları
└── widgets/         # Paylaşılan widget'lar
```

## Teknolojiler

- Flutter Web
- Riverpod (state management)
- go_router (routing)
- Dio (HTTP client)
- shared_preferences (token saklama)
