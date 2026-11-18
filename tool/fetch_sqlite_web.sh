#!/usr/bin/env bash
# Vendored release assets; run only when preparing/upgrading the build, never at app runtime.
set -euo pipefail
cd "$(dirname "$0")/../web/sqlite"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
for file in sqlite3.wasm drift_worker.js; do
  curl -fsSL --retry 3 "https://github.com/simolus3/drift/releases/download/drift-2.35.4/$file" -o "$tmp/$file"
done
(cd "$tmp" && sha256sum -c - <<'SUMS'
e7451780e78c56ff864fe9317a0fbcd6aeb2e8de3beba7f5efd963202f7ec3d9  sqlite3.wasm
48c950cd8e3bc3cddb34816c860e228be8832bef07a297c27e9907c057ff8162  drift_worker.js
SUMS
)
cp "$tmp/sqlite3.wasm" "$tmp/drift_worker.js" .
