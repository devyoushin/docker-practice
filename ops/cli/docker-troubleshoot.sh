#!/usr/bin/env bash
set -euo pipefail

echo "== docker version =="
docker version || true

echo "== docker info =="
docker info || true

echo "== disk usage =="
docker system df || true

echo "== containers =="
docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}' || true

echo "== networks =="
docker network ls || true

echo "== volumes =="
docker volume ls || true

echo "== daemon logs =="
journalctl -u docker -n 100 --no-pager || true
