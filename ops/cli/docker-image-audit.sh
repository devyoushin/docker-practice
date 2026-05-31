#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?usage: docker-image-audit.sh <image>}"

docker image inspect "${IMAGE}" \
  --format 'Image={{.Id}} Size={{.Size}} Created={{.Created}}'

docker history --no-trunc "${IMAGE}"

if command -v docker >/dev/null 2>&1; then
  docker scout cves "${IMAGE}" || true
fi
