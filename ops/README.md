# Docker Ops

Docker 운영 보조 자료와 실습 자산을 두는 공간입니다.

| 폴더 | 내용 |
|------|------|
| `install/` | Ubuntu/Amazon Linux Docker 설치 스크립트 |
| `upgrade/` | Docker Engine/Compose 업그레이드 스크립트 |
| `cli/` | Docker 진단과 이미지 점검 CLI 스크립트 |
| `compose/` | Docker Compose 예제 |
| `dockerfiles/` | Dockerfile 예제 |
| `scripts/` | 점검과 자동화 스크립트 |

## 주요 파일

| 파일 | 내용 |
|------|------|
| `compose/web-postgres.yaml` | Nginx, App, PostgreSQL 기본 Compose 예제 |
| `compose/node-redis-postgres.yaml` | Node.js API, Redis, PostgreSQL Compose 예제 |
| `compose/monitoring-stack.yaml` | Prometheus, Grafana Compose 예제 |
| `cli/docker-troubleshoot.sh` | Docker daemon/container/network/volume 진단 |
| `cli/docker-image-audit.sh` | Docker image history/metadata 점검 |
| `dockerfiles/python-fastapi.Dockerfile` | Python/FastAPI 기본 Dockerfile |
| `dockerfiles/go-distroless.Dockerfile` | Go multi-stage + distroless Dockerfile |
| `scripts/docker-cleanup.sh` | 사용하지 않는 Docker 리소스 정리 스크립트 |

Docker 원리를 설명하는 문서는 `docs/`에 두고, 실제 예시 파일과 운영 보조 자료는 `ops/`에 둡니다.
