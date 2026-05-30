# Docker 코드 표준 관행

## Dockerfile 필수 패턴

```dockerfile
# 베이스 이미지: 태그 고정 필수 (latest 금지)
FROM node:20-alpine AS builder

WORKDIR /app

# 의존성만 먼저 복사 (레이어 캐시 최적화)
COPY package*.json ./
RUN npm ci --only=production

# 소스 복사
COPY . .

# 멀티 스테이지: 런타임 이미지
FROM node:20-alpine
WORKDIR /app

# non-root 사용자
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY --from=builder --chown=appuser:appgroup /app .

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "server.js"]
```

## compose.yml 필수 패턴

```yaml
services:
  app:
    image: myapp:1.0.0        # latest 금지
    restart: unless-stopped
    env_file: .env            # 환경변수 외부화
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          memory: 512M        # 메모리 제한 필수

volumes:
  data:
    driver: local             # 볼륨 명시적 정의

networks:
  backend:
    driver: bridge            # 네트워크 명시적 정의
```

## .dockerignore 필수 항목

```
.git
node_modules
*.log
.env*
*.md
Dockerfile*
docker-compose*
```

## 절대 하지 말 것
- `FROM <image>:latest` 베이스 이미지 사용
- root 사용자로 컨테이너 실행
- 시크릿/자격증명을 이미지 레이어에 포함
- `docker run --privileged` (특별한 이유 없이)
