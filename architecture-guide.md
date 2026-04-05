# Docker 아키텍처

---

## 전체 구조

```
┌──────────────────────────────────────────────────────────────┐
│                        Docker Host                            │
│                                                               │
│   사용자                                                       │
│   docker CLI ──HTTP(Unix socket)──▶ Docker Daemon (dockerd)  │
│   docker compose                          │                   │
│   Docker Desktop                    ┌────┴─────┐             │
│                                     │          │              │
│                               containerd   Docker API         │
│                                     │      (REST)             │
│                               ┌─────┴─────┐                  │
│                               │           │                   │
│                           runc / shim  image store            │
│                               │                               │
│                    ┌──────────┼──────────┐                   │
│                    │          │          │                     │
│                Container A  Container B  Container C          │
│                (PID ns)     (PID ns)     (PID ns)             │
│                (net ns)     (net ns)     (net ns)             │
│                (cgroup)     (cgroup)     (cgroup)             │
│                                                               │
│   ┌──────────┐  ┌──────────┐  ┌──────────────────────┐      │
│   │ Volumes  │  │ Networks │  │  Images (layer cache) │      │
│   └──────────┘  └──────────┘  └──────────────────────┘      │
└──────────────────────────────────────────────────────────────┘
               │
               │ push/pull
               ▼
        Registry (Docker Hub / ECR / Harbor)
```

---

## 핵심 컴포넌트

### Docker Daemon (dockerd)

- Docker API 요청을 처리하는 백그라운드 서비스
- 이미지 빌드, 컨테이너 실행, 네트워크/볼륨 관리
- Unix 소켓(`/var/run/docker.sock`) 또는 TCP로 CLI와 통신

### containerd

- 컨테이너 런타임 (OCI 표준)
- 이미지 pull, 컨테이너 생성/시작/중지 담당
- dockerd 아래에서 동작하지만 독립적으로도 사용 가능 (Kubernetes의 기본 런타임)

### runc

- 리눅스 네임스페이스와 cgroup을 실제로 설정하는 저수준 런타임
- containerd가 호출 → 프로세스 격리 실행

---

## 컨테이너 격리 메커니즘

```
Linux Kernel
  │
  ├── Namespaces (격리)
  │     ├── PID  → 프로세스 ID 공간 분리
  │     ├── NET  → 네트워크 인터페이스 분리
  │     ├── MNT  → 파일시스템 마운트 분리
  │     ├── UTS  → 호스트명/도메인명 분리
  │     ├── IPC  → 프로세스 간 통신 분리
  │     └── USER → 사용자 ID 분리 (Rootless)
  │
  └── cgroups (자원 제한)
        ├── CPU    → 사용량 제한
        ├── Memory → 메모리 상한
        ├── I/O    → 디스크 I/O 제한
        └── Network → 네트워크 대역폭
```

> **VM과의 차이**: 컨테이너는 호스트 OS 커널을 공유하므로 VM보다 가볍고 빠름.
> 단, 커널 레벨 격리는 VM보다 약하므로 보안 요구사항에 따라 선택해야 함.

---

## 이미지 레이어 구조

```
최상위 (Read-Write Layer)  ← 실행 중인 컨테이너의 변경사항
─────────────────────────
Layer 4: COPY app.py .     ← Dockerfile 각 명령 = 1 레이어
Layer 3: RUN pip install   (읽기 전용)
Layer 2: COPY requirements.txt .
Layer 1: FROM python:3.11-slim (베이스 이미지)
```

- 동일한 베이스 이미지 레이어는 **여러 이미지가 공유** → 디스크 절약
- 컨테이너 종료 후 Read-Write 레이어는 삭제 → 데이터 영속성은 Volume 필요

---

## 컨테이너 생명주기

```
docker create  →  [created]
                      │
docker start   →  [running]  ←─────────────┐
                      │                      │
              프로세스 종료            docker restart
                      │                      │
              [exited/stopped] ──────────────┘
                      │
docker rm      →  [deleted]
```

| 상태 | 설명 |
|---|---|
| `created` | 생성됐지만 시작 안 됨 |
| `running` | 실행 중 |
| `paused` | `docker pause`로 일시정지 (cgroup freeze) |
| `exited` | 프로세스 종료 (코드 보존) |
| `dead` | 삭제에 실패한 비정상 상태 |

---

## 주요 명령어 흐름

```
docker run -d -p 8080:80 --name web nginx
     │
     ├─ 1. 이미지 없으면 pull (docker.io/library/nginx:latest)
     ├─ 2. 컨테이너 생성 (namespace + cgroup 설정)
     ├─ 3. 네트워크 연결 (기본 bridge)
     ├─ 4. 볼륨 마운트 (있는 경우)
     └─ 5. 컨테이너 내 PID 1 프로세스 시작 (nginx -g 'daemon off;')
```

```bash
# 실행 중인 컨테이너 목록
docker ps

# 전체 컨테이너 (종료 포함)
docker ps -a

# 컨테이너 로그
docker logs web
docker logs -f web   # follow (tail -f와 동일)

# 컨테이너 내부 접근
docker exec -it web /bin/sh

# 리소스 사용량 실시간 확인
docker stats

# 상세 정보 조회
docker inspect web
```

---

## 참고 링크

- [Docker 아키텍처 공식 문서](https://docs.docker.com/get-started/docker-overview/)
- [OCI Runtime Spec](https://github.com/opencontainers/runtime-spec)
- [containerd 공식 문서](https://containerd.io/docs/)
