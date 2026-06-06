#!/usr/bin/env bash
# Yerel / manuel Railway build için (opsiyonel)
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter
  export PATH="/tmp/flutter/bin:$PATH"
  flutter config --enable-web --no-analytics
  flutter precache --web
fi

flutter pub get
flutter build web --release
echo "Build tamam: build/web"
