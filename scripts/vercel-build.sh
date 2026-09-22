#!/usr/bin/env bash
set -euo pipefail

flutter_version="$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .fvmrc)"
flutter_version="${flutter_version:-stable}"
flutter_root="${FLUTTER_ROOT:-$PWD/.flutter-sdk}"

if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -x "$flutter_root/bin/flutter" ]; then
    rm -rf "$flutter_root"
    git clone --depth 1 --branch "$flutter_version" https://github.com/flutter/flutter.git "$flutter_root"
  fi
  export PATH="$flutter_root/bin:$PATH"
fi

flutter config --no-analytics
flutter pub get
flutter build web --release
