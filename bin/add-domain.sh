#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd "${script_dir}/.." && pwd)"
domains_file="${root_dir}/conf/domains.local.txt"
ssl_dir="${root_dir}/conf/ssl"

if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [domain]" >&2
  exit 1
fi

domain="${1:-}"
if [[ -z "${domain}" ]]; then
  read -r -p "Enter domain to add: " domain
fi

domain="$(printf '%s' "${domain}" | xargs)"
if [[ -z "${domain}" ]]; then
  echo "Domain is required." >&2
  exit 1
fi

if [[ ! "${domain}" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]]; then
  echo "Invalid domain: ${domain}" >&2
  exit 1
fi

mkdir -p "$(dirname "${domains_file}")"
touch "${domains_file}"

if ! grep -Fxq "${domain}" "${domains_file}"; then
  printf '%s\n' "${domain}" >> "${domains_file}"
fi

mapfile -t domains < <(grep -Ev '^\s*(#|$)' "${domains_file}" | awk '!seen[$0]++')
if [[ ${#domains[@]} -eq 0 ]]; then
  echo "No domains found in ${domains_file}" >&2
  exit 1
fi

if ! command -v mkcert >/dev/null 2>&1; then
  echo "mkcert not found. Run ./bin/init.sh first." >&2
  exit 1
fi

mkdir -p "${ssl_dir}"
umask 077
mkcert -cert-file "${ssl_dir}/dev.pem" -key-file "${ssl_dir}/dev-key.pem" \
  "localhost" "*.localhost" "${domains[@]}"

managed_start="# BEGIN local-dev domains (managed by bin/add-domain.sh)"
managed_end="# END local-dev domains (managed by bin/add-domain.sh)"
hosts_line="127.0.0.1 ${domains[*]}"

tmp_file="$(mktemp)"
if [[ -f /etc/hosts ]]; then
  awk -v start="${managed_start}" -v end="${managed_end}" '
    $0==start {in_block=1; next}
    $0==end {in_block=0; next}
    !in_block {print}
  ' /etc/hosts > "${tmp_file}"
fi

{
  echo "${managed_start}"
  echo "${hosts_line}"
  echo "${managed_end}"
} >> "${tmp_file}"

sudo cp "${tmp_file}" /etc/hosts
rm -f "${tmp_file}"

if command -v docker >/dev/null 2>&1; then
  if docker ps --format '{{.Names}}' | grep -qx 'nginx'; then
    docker exec nginx nginx -s reload >/dev/null 2>&1 || docker container restart nginx >/dev/null 2>&1
  fi
fi

echo "Added ${domain} and refreshed certificate."
