# 트러블슈팅 가이드

---

## 진단 명령어 모음

```bash
# 컨테이너 상태 확인
docker ps -a

# 로그 확인 (가장 먼저 확인)
docker logs <container>
docker logs --tail=50 <container>
docker logs --since=1h <container>

# 컨테이너 상세 정보
docker inspect <container>

# 컨테이너 리소스 사용량
docker stats <container>
docker stats --no-stream   # 현재 스냅샷만

# 컨테이너 내부 접근
docker exec -it <container> sh
docker exec -it <container> bash

# 파일시스템 변경 사항 확인
docker diff <container>

# 이미지 레이어 히스토리
docker history <image>

# 시스템 전체 상태
docker system df
docker system events   # 이벤트 스트림
```

---

## 자주 발생하는 문제

### 컨테이너가 즉시 종료됨 (Exited)

```bash
# 종료 코드 확인
docker ps -a
# STATUS에서 Exited (코드) 확인
# Exited (0) = 정상 종료 (포그라운드 프로세스 없음)
# Exited (1) = 오류로 종료
# Exited (137) = OOM Kill 또는 SIGKILL

# 로그 확인
docker logs <container>
```

**원인별 해결:**

| 종료 코드 | 원인 | 해결 방법 |
|---|---|---|
| `0` | 포그라운드 프로세스가 없음 | `CMD`가 데몬 모드 없이 즉시 종료되는 명령인지 확인 |
| `1` | 애플리케이션 오류 | `docker logs`로 에러 메시지 확인 |
| `137` | OOM Kill 또는 강제 종료 | 메모리 제한 확인, `docker inspect`에서 `OOMKilled` 확인 |
| `139` | Segfault | 이미지 호환성, 커널 버전 확인 |

```bash
# OOM Kill 여부 확인
docker inspect <container> | jq '.[0].State.OOMKilled'
```

---

### 이미지 Pull 실패

```bash
# 증상
Error response from daemon: pull access denied for myimage

# 확인 사항
docker login                         # 로그인 여부
docker info | grep -A5 "Registry"    # 기본 레지스트리
docker pull myregistry.io/myimage    # 전체 경로로 시도

# ECR 토큰 만료 (12시간)
aws ecr get-login-password ... | docker login ...
```

---

### 포트 바인딩 실패

```bash
# 증상
Error: Bind for 0.0.0.0:8080 failed: port is already allocated

# 사용 중인 포트 확인
sudo lsof -i :8080
sudo ss -tlnp | grep 8080

# 점유 프로세스 종료 또는 다른 포트 사용
docker run -p 8081:80 nginx
```

---

### 컨테이너 간 통신 안 됨

```bash
# 증상: ping/curl이 timeout
docker exec -it app ping db  # 실패

# 확인: 같은 네트워크인지
docker inspect app | jq '.[0].NetworkSettings.Networks'
docker inspect db | jq '.[0].NetworkSettings.Networks'

# 해결: 같은 사용자 정의 네트워크에 연결
docker network create my-net
docker network connect my-net app
docker network connect my-net db

# DNS 해석 확인
docker exec -it app nslookup db
docker exec -it app cat /etc/resolv.conf
```

---

### 볼륨 권한 문제

```bash
# 증상
Permission denied: '/app/data/...'

# 컨테이너 내 실행 사용자 확인
docker exec -it app whoami
docker exec -it app id

# Dockerfile에서 권한 설정
RUN mkdir -p /app/data && chown -R appuser:appuser /app/data

# 또는 볼륨 마운트 후 권한 변경
docker run --rm -v mydata:/data busybox chown -R 1000:1000 /data
```

---

### 메모리/CPU 부족

```bash
# 리소스 사용량 확인
docker stats --no-stream

# 컨테이너 리소스 제한 설정
docker run -d \
  --memory=512m \
  --memory-swap=512m \
  --cpus=0.5 \
  myapp

# Compose에서 리소스 제한
services:
  app:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: "0.5"
```

---

### 디스크 공간 부족

```bash
# Docker가 사용하는 공간 확인
docker system df

# 정리 (사용하지 않는 리소스)
docker container prune     # 종료된 컨테이너
docker image prune -a      # 사용하지 않는 이미지
docker volume prune        # 사용하지 않는 볼륨
docker network prune       # 사용하지 않는 네트워크

# 전체 일괄 정리 (주의: 실행 중 아닌 모든 것 삭제)
docker system prune -a --volumes
```

---

### Docker 빌드 느림

```bash
# 빌드 컨텍스트 크기 확인 (첫 줄에 출력됨)
docker build -t test .
# Sending build context to Docker daemon  500MB  ← 너무 크면 .dockerignore 점검

# 레이어 캐시 미스 원인 파악
docker build --progress=plain -t test . 2>&1 | grep -E "CACHED|RUN"

# BuildKit 캐시 마운트 사용 (pip, npm 등)
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
```

---

### DNS 해석 실패

```bash
# 증상: 컨테이너 내부에서 외부 도메인 해석 안 됨
docker exec -it app nslookup google.com  # 실패

# 확인
docker exec -it app cat /etc/resolv.conf

# 해결: daemon.json에 DNS 서버 지정
# /etc/docker/daemon.json
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
sudo systemctl restart docker
```

---

## 디버그용 임시 컨테이너

```bash
# 네트워크 디버그
docker run -it --rm --network <network> nicolaka/netshoot

# 다른 컨테이너의 네트워크 공유
docker run -it --rm --network container:<target> nicolaka/netshoot

# 볼륨 내용 확인
docker run -it --rm -v myvolume:/data busybox ls -la /data

# 실행 중 컨테이너 스냅샷 이미지로 저장 (디버그용)
docker commit <container> debug-snapshot:latest
```

---

## 참고 링크

- [Docker 로그 드라이버](https://docs.docker.com/config/containers/logging/)
- [컨테이너 리소스 제한](https://docs.docker.com/config/containers/resource_constraints/)
- [Docker 스토리지 관리](https://docs.docker.com/storage/)
