#!/usr/bin/env bash
set -euo pipefail

docker version || true
docker compose version || true

sudo apt-get update
sudo apt-get install -y --only-upgrade docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl restart docker
docker version
docker compose version
