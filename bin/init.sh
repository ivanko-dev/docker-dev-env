#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd "${script_dir}/.." && pwd)"
ssl_dir="${root_dir}/conf/ssl"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found. Install mkcert and libnss3-tools manually." >&2
  exit 1
fi

sudo apt-get update
sudo apt-get install -y mkcert libnss3-tools

if ! command -v mkcert >/dev/null 2>&1; then
  echo "mkcert not available after install." >&2
  exit 1
fi

mkcert -install

mkdir -p "${ssl_dir}"
umask 077
mkcert -cert-file "${ssl_dir}/dev.pem" -key-file "${ssl_dir}/dev-key.pem" "localhost" "*.localhost" "*.dev.localhost"

echo "Generated ${ssl_dir}/dev.pem and ${ssl_dir}/dev-key.pem"
