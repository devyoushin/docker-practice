# Docker 실습 저장소

Docker를 처음부터 운영 수준까지 학습하는 실습 저장소입니다.

---

## 어디서 시작할까

- 문서 지도: `docs/README.md`
- 첫 문서: `docs/install.md`
- 운영 보조 자료: `ops/README.md`
- AI 작업 지침: `CLAUDE.md`

## 구조

| 경로 | 내용 |
|------|------|
| `docs/` | 설치, 이미지, Compose, 네트워크, 볼륨, 트러블슈팅 문서 |
| `ops/` | Compose 예제, Dockerfile 예제, 운영 보조 스크립트 |
| `CLAUDE.md` | 이 레포에서 Claude가 참고할 작업 지침 |

---

## 환경 정보

| 항목 | 값 |
|---|---|
| 플랫폼 | Linux (Ubuntu 22.04 / Amazon Linux 2023) |
| Docker 버전 | `26.x` 이상 권장 |
| Docker Compose | `v2` (플러그인 방식) |
| 실습 방식 | 로컬 또는 EC2 인스턴스 |

---

## 빠른 시작 (Quick Start)

```bash
# Docker 설치 확인
docker version
docker compose version

# Hello World
docker run --rm hello-world

# 컨테이너 실행 예시
docker run -d -p 8080:80 --name my-nginx nginx:alpine
curl http://localhost:8080
```

---

## 학습 경로

### 1단계: 설치
- [Docker 설치](./docs/install.md)

### 2단계: 핵심 개념
- [아키텍처 개요](./docs/architecture-guide.md)
- [이미지 관리](./docs/image-guide.md)
- [네트워크](./docs/network-guide.md)
- [볼륨 (데이터 관리)](./docs/volume-guide.md)

### 3단계: 멀티 컨테이너
- [Docker Compose](./docs/compose-guide.md)

### 4단계: 문제 해결
- [트러블슈팅 가이드](./docs/troubleshooting-guide.md)

---

## 상세 구조

```
docker-practice/
├── README.md
├── CLAUDE.md
├── docs/
│   ├── README.md
│   ├── install.md
│   ├── architecture-guide.md
│   ├── image-guide.md
│   ├── compose-guide.md
│   └── troubleshooting-guide.md
└── ops/
    └── README.md
```

---

## 아키텍처 요약

```
┌─────────────────────────────────────────────────────┐
│                    Docker Host                       │
│                                                      │
│  docker CLI ──▶ Docker Daemon (dockerd)              │
│                       │                              │
│              ┌────────┴─────────┐                   │
│              │                  │                    │
│         containerd          Docker API               │
│              │                                       │
│      ┌───────┴──────────┐                           │
│      │                  │                            │
│  Container A        Container B                      │
│  (namespace +        (namespace +                    │
│   cgroup)             cgroup)                        │
│                                                      │
│  Images ──▶ Registry (Docker Hub / ECR / Harbor)    │
│  Volumes ──▶ /var/lib/docker/volumes/               │
│  Networks ──▶ bridge0 / custom bridge / host        │
└─────────────────────────────────────────────────────┘
```

| 개념 | 설명 |
|---|---|
| **Image** | 컨테이너의 읽기 전용 템플릿 (Dockerfile로 빌드) |
| **Container** | 이미지를 실행한 격리된 프로세스 |
| **Volume** | 컨테이너 외부에 데이터를 영속 저장하는 공간 |
| **Network** | 컨테이너 간 통신을 위한 가상 네트워크 |
| **Registry** | 이미지를 저장하고 배포하는 저장소 |

---

## 참고 링크

- [Docker 공식 문서](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Dockerfile 레퍼런스](https://docs.docker.com/reference/dockerfile/)
- [Compose 파일 레퍼런스](https://docs.docker.com/reference/compose-file/)
