#!/usr/bin/env bash
set -euo pipefail

docker container prune -f
docker image prune -f
docker network prune -f

if [[ "${PRUNE_VOLUMES:-false}" == "true" ]]; then
  docker volume prune -f
fi

docker system df
