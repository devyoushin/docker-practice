# 이미지 관리

---

## 이미지 기본 명령어

```bash
# 이미지 검색
docker search nginx

# 이미지 pull
docker pull nginx:alpine
docker pull nginx:1.27

# 로컬 이미지 목록
docker images
docker image ls

# 이미지 상세 정보
docker inspect nginx:alpine

# 이미지 삭제
docker rmi nginx:alpine
docker image rm nginx:alpine

# 사용하지 않는 이미지 전체 삭제
docker image prune -a
```

---

## Dockerfile 작성

### 기본 구조

```dockerfile
# syntax=docker/dockerfile:1

# 1. 베이스 이미지 선택
FROM python:3.11-slim

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. 의존성 파일 먼저 복사 (캐시 활용)
COPY requirements.txt .

# 4. 의존성 설치
RUN pip install --no-cache-dir -r requirements.txt

# 5. 애플리케이션 코드 복사
COPY . .

# 6. 포트 선언 (문서 목적 — 실제 바인딩은 docker run -p로)
EXPOSE 8000

# 7. 컨테이너 시작 명령
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Dockerfile 주요 명령어

| 명령어 | 용도 | 레이어 생성 |
|---|---|---|
| `FROM` | 베이스 이미지 지정 | 예 |
| `RUN` | 빌드 시 명령 실행 | 예 |
| `COPY` | 파일 복사 (빌드 컨텍스트 → 이미지) | 예 |
| `ADD` | COPY + URL/tar 자동 압축해제 지원 | 예 |
| `WORKDIR` | 작업 디렉토리 설정 | 예 |
| `ENV` | 환경 변수 설정 | 예 |
| `ARG` | 빌드 인수 (빌드 시에만 유효) | 아니오 |
| `EXPOSE` | 포트 문서화 | 아니오 |
| `CMD` | 기본 실행 명령 (오버라이드 가능) | 아니오 |
| `ENTRYPOINT` | 고정 실행 명령 (오버라이드 어려움) | 아니오 |

---

## 멀티 스테이지 빌드 (Multi-stage Build)

빌드 도구를 최종 이미지에 포함하지 않아 이미지 크기를 크게 줄일 수 있습니다.

```dockerfile
# ---- Build Stage ----
FROM golang:1.22 AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o server .

# ---- Final Stage ----
FROM gcr.io/distroless/static:nonroot

COPY --from=builder /app/server /server
USER nonroot:nonroot

ENTRYPOINT ["/server"]
```

```
빌드 스테이지: golang:1.22 (수백 MB)
최종 이미지: distroless/static (수 MB) ← 빌드 도구 없음
```

---

## 레이어 캐시 최적화

```dockerfile
# 나쁜 예: 코드 변경 시 pip install이 매번 실행됨
FROM python:3.11-slim
COPY . .
RUN pip install -r requirements.txt

# 좋은 예: requirements.txt가 바뀌지 않으면 pip install 캐시 재사용
FROM python:3.11-slim
COPY requirements.txt .        # 변경 빈도 낮음
RUN pip install -r requirements.txt
COPY . .                       # 변경 빈도 높음
```

**레이어 캐시 원칙**: **변경 빈도가 낮은 것을 위에, 높은 것을 아래에**

---

## 이미지 빌드

```bash
# 기본 빌드
docker build -t myapp:1.0 .

# Dockerfile 경로 지정
docker build -f Dockerfile.prod -t myapp:prod .

# 빌드 인수 전달
docker build --build-arg APP_VERSION=1.0 -t myapp:1.0 .

# 캐시 없이 빌드
docker build --no-cache -t myapp:latest .

# 빌드 후 이미지 크기 확인
docker images myapp
```

---

## .dockerignore

빌드 컨텍스트에서 제외할 파일을 지정 (`.gitignore` 문법과 동일):

```
.git
.gitignore
node_modules/
*.log
.env
.env.*
__pycache__/
*.pyc
dist/
build/
```

---

## 이미지 태그 및 레지스트리

```bash
# 태그 추가
docker tag myapp:1.0 myregistry.io/myapp:1.0
docker tag myapp:1.0 myregistry.io/myapp:latest

# 레지스트리 로그인
docker login myregistry.io

# 이미지 push
docker push myregistry.io/myapp:1.0

# 이미지 pull
docker pull myregistry.io/myapp:1.0
```

### AWS ECR 예시

```bash
# ECR 로그인
aws ecr get-login-password --region ap-northeast-2 | \
  docker login --username AWS --password-stdin \
  <ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com

# 태그 후 push
docker tag myapp:1.0 <ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com/myapp:1.0
docker push <ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com/myapp:1.0
```

---

## 이미지 크기 줄이기

| 방법 | 효과 |
|---|---|
| slim / alpine 베이스 이미지 사용 | 베이스 이미지 크기 감소 |
| 멀티 스테이지 빌드 | 빌드 도구 제거 |
| `RUN` 명령 합치기 | 레이어 수 감소 |
| `--no-cache` 옵션 사용 | 패키지 캐시 미포함 |
| `.dockerignore` 작성 | 불필요한 파일 제외 |
| `distroless` 이미지 사용 | 셸/패키지 매니저 없는 최소 이미지 |

```bash
# 이미지 히스토리로 레이어별 크기 확인
docker history myapp:1.0

# dive 도구로 레이어 상세 분석 (별도 설치 필요)
dive myapp:1.0
```

---

## 참고 링크

- [Dockerfile 레퍼런스](https://docs.docker.com/reference/dockerfile/)
- [멀티 스테이지 빌드](https://docs.docker.com/build/building/multi-stage/)
- [이미지 빌드 모범 사례](https://docs.docker.com/build/building/best-practices/)
- [distroless 이미지](https://github.com/GoogleContainerTools/distroless)
