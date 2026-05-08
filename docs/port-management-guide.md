# Docker 포트 관리

> **카테고리**: 네트워크
> **관련 버전**: Docker 26.x 이상
> **작성일**: 2026-05-08

---

## 1. 개요

Docker 컨테이너는 기본적으로 외부에서 접근할 수 없는 격리된 네트워크에 존재합니다.
포트 바인딩(포워딩)을 통해 호스트의 특정 포트를 컨테이너 포트에 연결해야 외부 트래픽이 컨테이너에 도달할 수 있습니다.
잘못된 포트 관리는 서비스 충돌, 보안 취약점, 디버깅 어려움으로 이어지므로 명확한 원칙이 필요합니다.

---

## 2. 포트 바인딩 동작 원리

```
외부 클라이언트
      │
      ▼
호스트 eth0 (예: 0.0.0.0:8080)
      │
   iptables DNAT 규칙
      │
      ▼
docker-proxy (userland proxy)
      │
      ▼
컨테이너 내부 포트 (예: 80)
```

- `-p` 옵션을 사용하면 Docker가 자동으로 **iptables DNAT** 규칙을 추가합니다.
- `docker-proxy` 프로세스가 호스트↔컨테이너 간 트래픽을 중계합니다.
- EXPOSE는 문서화 목적이며, 실제 포트 개방은 `-p` 옵션으로만 이루어집니다.

---

## 3. 포트 바인딩 문법

```
-p [호스트_IP:]<호스트_포트>:<컨테이너_포트>[/프로토콜]
```

| 예시 | 의미 |
|---|---|
| `-p 8080:80` | 호스트 모든 인터페이스 8080 → 컨테이너 80 |
| `-p 127.0.0.1:8080:80` | 루프백(로컬)에서만 접근 가능 |
| `-p 8080:80/tcp` | TCP 명시 (기본값) |
| `-p 5353:53/udp` | UDP 포트 바인딩 |
| `-p 80` | 호스트 랜덤 포트 → 컨테이너 80 |
| `-P` | EXPOSE된 모든 포트를 랜덤 포트로 바인딩 |

---

## 4. 기본 포트 바인딩 예시

```bash
# 단일 포트 바인딩
docker run -d -p 8080:80 nginx

# 여러 포트 바인딩
docker run -d \
  -p 8080:80 \
  -p 8443:443 \
  nginx

# 루프백 전용 바인딩 (외부 노출 차단)
docker run -d -p 127.0.0.1:5432:5432 postgres:16

# UDP 포트 바인딩
docker run -d -p 5353:53/udp my-dns-server

# 랜덤 포트 자동 할당
docker run -d -p 80 nginx
docker port <container_id>   # 할당된 포트 확인
```

---

## 5. 포트 확인 명령어

```bash
# 컨테이너의 포트 매핑 확인
docker port <container_name>

# 실행 중인 컨테이너 포트 목록 확인
docker ps --format "table {{.Names}}\t{{.Ports}}"

# 호스트에서 점유 중인 포트 확인
ss -tlnp | grep docker
lsof -i :<포트번호>

# 컨테이너 상세 포트 정보 (JSON)
docker inspect <container_name> \
  --format '{{json .NetworkSettings.Ports}}' | jq .

# iptables에서 Docker 포트 포워딩 규칙 확인
sudo iptables -t nat -L DOCKER -n --line-numbers
```

---

## 6. Docker Compose에서 포트 관리

```yaml
# compose.yml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"           # 문자열 형식 (권장)
      - "8443:443"
      - "127.0.0.1:9090:9090"  # 루프백 전용

  db:
    image: postgres:16
    # 외부 노출 없이 내부 네트워크에서만 접근
    expose:
      - "5432"
    # ports 를 사용하지 않으면 호스트에서 직접 접근 불가

  redis:
    image: redis:7-alpine
    ports:
      - "127.0.0.1:6379:6379"  # 로컬 개발 시 디버깅용
```

```bash
# Compose 서비스 포트 확인
docker compose ps
docker compose port web 80    # web 서비스의 컨테이너 80 포트 → 호스트 포트 출력
```

### EXPOSE vs ports

| 항목 | `expose` | `ports` |
|---|---|---|
| 외부 접근 | 불가 | 가능 |
| 컨테이너 간 접근 | 가능 | 가능 |
| 용도 | 내부 서비스 (DB, 캐시) | 외부 접근 필요 서비스 (웹) |

---

## 7. 포트 관리 보안 원칙

### 최소 노출 원칙

```bash
# 나쁜 예: 모든 인터페이스에 DB 노출
docker run -d -p 5432:5432 postgres:16

# 좋은 예: 루프백에만 바인딩
docker run -d -p 127.0.0.1:5432:5432 postgres:16

# 더 좋은 예: 포트 노출 없이 내부 네트워크만 사용
docker network create app-net
docker run -d --name db --network app-net postgres:16
docker run -d --name app --network app-net -p 8080:3000 myapp
```

### 권장 포트 구성

```
인터넷
  │
  └──▶ 80/443 (리버스 프록시: nginx/traefik)
              │
              │ 내부 네트워크
              ├──▶ :3000 (앱 서버, 외부 미노출)
              ├──▶ :5432 (DB, 외부 미노출)
              └──▶ :6379 (Redis, 외부 미노출)
```

---

## 8. 포트 충돌 방지

```bash
# 특정 포트 사용 여부 확인
ss -tlnp | grep :8080
lsof -i :8080

# Docker가 사용 중인 포트 전체 목록
docker ps --format "{{.Ports}}" | tr ',' '\n' | sort -u

# 사용 가능한 포트 범위 확인 (Linux)
cat /proc/sys/net/ipv4/ip_local_port_range
```

---

## 9. 트러블슈팅

### 포트가 이미 사용 중 (bind: address already in use)

**원인**: 호스트의 해당 포트를 다른 프로세스 또는 컨테이너가 점유 중

**해결**:
```bash
# 점유 프로세스 확인
lsof -i :8080
ss -tlnp | grep :8080

# 충돌 컨테이너 확인 및 정리
docker ps -a --format "{{.Names}}\t{{.Ports}}" | grep 8080

# 다른 호스트 포트 사용
docker run -d -p 8081:80 nginx
```

---

### 컨테이너 포트에 외부 접근이 안 됨

**원인**: 잘못된 바인딩 주소 또는 방화벽 설정

**해결**:
```bash
# 현재 바인딩 주소 확인
docker inspect <container> \
  --format '{{json .NetworkSettings.Ports}}' | jq .

# 127.0.0.1 → 0.0.0.0 으로 변경하여 재실행
docker run -d -p 0.0.0.0:8080:80 nginx

# 방화벽 포트 허용 (UFW)
sudo ufw allow 8080/tcp

# 방화벽 포트 허용 (firewalld)
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

---

### `-P` 사용 시 포트를 찾을 수 없음

**원인**: Dockerfile에 EXPOSE 선언 누락

**해결**:
```dockerfile
# Dockerfile에 EXPOSE 추가
FROM node:20-alpine
EXPOSE 3000
CMD ["node", "server.js"]
```

```bash
# EXPOSE 선언 후 -P 로 자동 바인딩
docker run -d -P myapp
docker port <container_id>
```

---

### iptables 규칙 꼬임 (포트 포워딩 동작 안 함)

**원인**: Docker 재시작 없이 iptables 직접 수정, 또는 다른 방화벽 도구와 충돌

**해결**:
```bash
# Docker 재시작으로 iptables 규칙 재생성
sudo systemctl restart docker

# Docker chain 확인
sudo iptables -t nat -L DOCKER -n -v
```

---

## 10. 구현 체크리스트

- [ ] DB, 캐시 서비스는 `ports` 대신 `expose` 또는 내부 네트워크만 사용
- [ ] 외부 노출 포트는 `127.0.0.1:` 또는 `0.0.0.0:` 바인딩 주소 명시
- [ ] 포트 충돌 여부 배포 전 확인 (`ss -tlnp`)
- [ ] Compose 파일에 포트를 문자열 형식으로 작성 (`"8080:80"`)
- [ ] 프로덕션에서 DB 포트 외부 노출 없음 확인
- [ ] YAML 문법 검증 완료 (`docker compose config`)
- [ ] 트러블슈팅 섹션 포함
