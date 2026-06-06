# Dünya Kupası Tahmin — Web

[outcome_flutter](https://github.com/OkanUysal/outcome_flutter) ile aynı proxy mantığı:

```dart
final target = '${ApiConfig.backendUrl}/auth/login';
final proxy = '${ApiConfig.proxyUrl}?target=${Uri.encodeComponent(target)}';
await http.post(Uri.parse(proxy), ...);
```

Tarayıcı doğrudan backend'e gitmez; `server.js` üzerindeki `/api/v1/proxy` isteği backend'e iletir.

## Ortamlar

| Ortam | Proxy URL |
|-------|-----------|
| `flutter run -d chrome` | `http://localhost:8080/api/v1/proxy` (`npm start` gerekir) |
| Railway / `npm start` (release) | `/api/v1/proxy` (aynı origin) |

## Local debug

Terminal 1 — proxy sunucusu:

```bash
npm install
npm start
```

Terminal 2 — Flutter:

```bash
flutter run -d chrome
```

Giriş ekranında `v1.0.2 · http://localhost:8080/api/v1/proxy` görünmeli.

## Railway deploy

```bash
flutter build web --release
git add build/web lib server.js package.json
git commit -m "build web v1.0.2"
git push
```

Railway `npm install` + `npm start` çalıştırır.

Giriş ekranında `v1.0.2 · /api/v1/proxy` görünmeli. Eski sürüm görüyorsanız build push edilmemiştir.

## Local release test

```bash
flutter build web --release
npm install
npm start
```

→ http://localhost:8080

## Backend

`https://world-cup-predict-be-production.up.railway.app/api/v1`

Detay: [user_api.md](user_api.md)
