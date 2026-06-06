#!/usr/bin/env bash
set -euo pipefail

echo "==> Flutter kurulumu..."
if ! command -v flutter >/dev/null 2>&1; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter
  export PATH="/tmp/flutter/bin:$PATH"
  flutter config --enable-web
  flutter precache --web
fi

flutter --version
echo "==> Bağımlılıklar..."
flutter pub get

echo "==> Web build..."
flutter build web --release

echo "==> Build tamam: build/web"
