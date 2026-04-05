# Docker Compose

여러 컨테이너를 하나의 파일(`compose.yaml`)로 정의하고 함께 관리합니다.

---

## compose.yaml 기본 구조

```yaml
# compose.yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
    depends_on:
      - app

  app:
    build: .                    # 현재 디렉토리 Dockerfile로 빌드
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  pgdata:
```

---

## 기본 명령어

```bash
# 서비스 시작 (백그라운드)
docker compose up -d

# 서비스 시작 + 빌드 강제
docker compose up -d --build

# 서비스 상태 확인
docker compose ps

# 로그 확인
docker compose logs
docker compose logs -f app       # 특정 서비스 follow
docker compose logs --tail=100   # 마지막 100줄

# 서비스 중지 (컨테이너 유지)
docker compose stop

# 서비스 중지 + 컨테이너 삭제
docker compose down

# 볼륨까지 삭제
docker compose down -v

# 서비스 재시작
docker compose restart app

# 특정 서비스만 스케일 조정
docker compose up -d --scale app=3
```

---

## 환경 변수 관리

```bash
# .env 파일 (자동으로 읽힘)
cat .env
```

```ini
# .env
POSTGRES_PASSWORD=mysecretpassword
APP_PORT=8080
IMAGE_TAG=1.0.0
```

```yaml
# compose.yaml에서 참조
services:
  app:
    image: myapp:${IMAGE_TAG}
    ports:
      - "${APP_PORT}:8000"
  db:
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
```

```bash
# 특정 env 파일 지정
docker compose --env-file .env.prod up -d

# 환경 변수 확인
docker compose config   # 변수 치환 결과 확인
```

---

## 멀티 파일 구성 (개발/운영 분리)

```
compose.yaml          ← 공통 설정
compose.override.yaml ← 로컬 개발용 (자동 병합)
compose.prod.yaml     ← 운영용 (명시적 지정)
```

```yaml
# compose.yaml (공통)
services:
  app:
    image: myapp:${IMAGE_TAG:-latest}
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb

  db:
    image: postgres:16
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

```yaml
# compose.override.yaml (개발용 — 자동 병합)
services:
  app:
    build: .
    volumes:
      - ./src:/app/src   # 코드 바인드 마운트
    environment:
      - DEBUG=true

  db:
    ports:
      - "5432:5432"      # 로컬에서 DB 직접 접근 가능
```

```yaml
# compose.prod.yaml (운영용)
services:
  app:
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: "0.5"
          memory: 512M
    restart: always

  db:
    restart: always
```

```bash
# 개발 환경 (compose.yaml + compose.override.yaml 자동 병합)
docker compose up -d

# 운영 환경 (명시적 파일 지정)
docker compose -f compose.yaml -f compose.prod.yaml up -d
```

---

## 헬스 체크 및 의존성

```yaml
services:
  db:
    image: postgres:16
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s     # 체크 간격
      timeout: 5s       # 타임아웃
      retries: 5        # 실패 후 재시도 횟수
      start_period: 30s # 시작 후 대기 시간

  app:
    depends_on:
      db:
        condition: service_healthy   # db가 healthy 상태일 때만 시작
```

---

## 실전 예시: Node.js + Redis + Postgres

```yaml
# compose.yaml
services:
  api:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        NODE_ENV: production
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=postgres
      - REDIS_HOST=redis
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    restart: unless-stopped

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: myuser
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U myuser -d myapp"]
      interval: 10s
      retries: 5
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redisdata:/data
    restart: unless-stopped

volumes:
  pgdata:
  redisdata:
```

---

## 재시작 정책

| 정책 | 동작 |
|---|---|
| `no` | 재시작 안 함 (기본값) |
| `always` | 항상 재시작 (수동 stop 포함) |
| `unless-stopped` | 수동으로 stop하지 않는 한 재시작 |
| `on-failure` | 비정상 종료(exit code != 0)일 때만 재시작 |

```yaml
services:
  app:
    restart: unless-stopped   # 운영 환경 권장
```

---

## 유용한 명령어

```bash
# 서비스 내부에서 명령 실행
docker compose exec app sh
docker compose exec db psql -U user mydb

# 임시 컨테이너로 명령 실행
docker compose run --rm app python manage.py migrate

# 특정 서비스만 빌드
docker compose build app

# 이미지 pull
docker compose pull

# 전체 설정 확인 (변수 치환 포함)
docker compose config
```

---

## 참고 링크

- [Compose 파일 레퍼런스](https://docs.docker.com/reference/compose-file/)
- [Docker Compose 시작하기](https://docs.docker.com/compose/gettingstarted/)
- [Compose 환경 변수](https://docs.docker.com/compose/environment-variables/)
