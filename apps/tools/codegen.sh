#!/usr/bin/env bash
set -euo pipefail

# Simple helper to run all code generation for the app.
# Usage:
#   sh tools/codegen.sh            # one-shot build
#   sh tools/codegen.sh --watch    # watch mode (build_runner + l10n)
#   sh tools/codegen.sh --repair   # attempt pub cache repair before building
#   sh tools/codegen.sh --no-l10n  # skip gen-l10n step

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

WATCH=0
REPAIR=0
RUN_L10N=1

for arg in "$@"; do
  case "$arg" in
    --watch) WATCH=1 ; shift ;;
    --repair) REPAIR=1 ; shift ;;
    --no-l10n) RUN_L10N=0 ; shift ;;
    *) ;;
  esac
done

cd "$APP_DIR"

echo "[codegen] Flutter: $(flutter --version 2>/dev/null | head -n 1 || echo 'unknown')"
echo "[codegen] Dart: $(dart --version 2>&1 || true)"

if [[ $REPAIR -eq 1 ]]; then
  echo "[codegen] Running flutter pub cache repair..."
  flutter pub cache repair || true
fi

echo "[codegen] flutter pub get"
flutter pub get

if [[ $WATCH -eq 1 ]]; then
  echo "[codegen] starting watchers (build_runner + gen-l10n)"
  if [[ $RUN_L10N -eq 1 ]]; then
    (flutter gen-l10n --watch &)
    L10N_PID=$!
  fi
  dart run build_runner watch --delete-conflicting-outputs
  if [[ ${L10N_PID:-0} -ne 0 ]]; then
    kill "$L10N_PID" 2>/dev/null || true
    wait "$L10N_PID" 2>/dev/null || true
  fi
else
  echo "[codegen] dart run build_runner build --delete-conflicting-outputs"
  dart run build_runner build --delete-conflicting-outputs
  if [[ $RUN_L10N -eq 1 ]]; then
    echo "[codegen] flutter gen-l10n"
    flutter gen-l10n
  fi
fi

echo "[codegen] done"

