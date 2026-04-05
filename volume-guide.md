# 볼륨 (데이터 관리)

컨테이너는 종료되면 Read-Write 레이어가 삭제됩니다. 데이터를 영속 보관하려면 볼륨 또는 바인드 마운트를 사용해야 합니다.

---

## 스토리지 유형 비교

```
Docker Host 파일시스템
  │
  ├── Named Volume (/var/lib/docker/volumes/<name>/_data)
  │     → Docker가 관리, 이식성 높음, 운영 환경 권장
  │
  ├── Bind Mount (호스트 경로 직접 지정)
  │     → 개발 환경에서 코드 실시간 반영에 적합
  │
  └── tmpfs Mount (메모리)
        → 임시 민감 데이터 저장 (재시작 시 삭제)
```

| 항목 | Named Volume | Bind Mount | tmpfs |
|---|---|---|---|
| 관리 주체 | Docker | 사용자 (호스트 경로) | Docker |
| 경로 | Docker 관리 디렉토리 | 임의 호스트 경로 | 메모리 |
| 이식성 | 높음 | 낮음 (경로 의존) | 높음 |
| 성능 | 높음 | 높음 | 최고 |
| 용도 | DB, 운영 데이터 | 개발 코드 마운트 | 민감 임시 데이터 |

---

## Named Volume

```bash
# 볼륨 생성
docker volume create mydata

# 볼륨 목록
docker volume ls

# 볼륨 상세 정보
docker volume inspect mydata

# 볼륨 마운트하여 컨테이너 실행
docker run -d \
  --name postgres \
  -v mydata:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=secret \
  postgres:16

# 컨테이너 삭제 후에도 볼륨 데이터 유지
docker rm postgres
docker volume ls   # mydata 볼륨 여전히 존재

# 볼륨 삭제
docker volume rm mydata

# 사용하지 않는 볼륨 전체 삭제
docker volume prune
```

---

## Bind Mount

```bash
# 현재 디렉토리를 컨테이너에 마운트 (개발 환경)
docker run -d \
  --name dev-app \
  -v $(pwd)/src:/app/src \
  -p 8000:8000 \
  myapp:dev

# 읽기 전용 마운트 (설정 파일 등)
docker run -d \
  --name nginx \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  -p 80:80 \
  nginx

# 절대 경로로 지정
docker run -d \
  -v /data/logs:/var/log/app \
  myapp:latest
```

> **개발 환경 팁**: 코드 파일을 bind mount하면 컨테이너 재빌드 없이 변경사항이 즉시 반영됩니다.

---

## tmpfs Mount

```bash
# 메모리에 임시 디렉토리 마운트 (컨테이너 종료 시 삭제)
docker run -d \
  --name app \
  --tmpfs /tmp:rw,size=100m \
  myapp:latest

# 또는 --mount 플래그 사용
docker run -d \
  --mount type=tmpfs,target=/tmp,tmpfs-size=100m \
  myapp:latest
```

**사용 사례**: 세션 토큰, 임시 암호화 키 등 디스크에 저장되면 안 되는 데이터

---

## --volume vs --mount 플래그

`--mount` 플래그가 더 명시적이고 오류 감지가 쉬워 권장합니다.

```bash
# --volume (축약형)
docker run -v mydata:/app/data myapp

# --mount (명시적, 권장)
docker run \
  --mount type=volume,source=mydata,target=/app/data \
  myapp

# Bind mount
docker run \
  --mount type=bind,source=$(pwd)/config,target=/app/config,readonly \
  myapp
```

---

## 볼륨 데이터 백업 및 복원

```bash
# 볼륨 데이터 백업 (tar 아카이브)
docker run --rm \
  -v mydata:/data \
  -v $(pwd):/backup \
  busybox \
  tar czf /backup/mydata-backup.tar.gz -C /data .

# 백업 복원
docker run --rm \
  -v mydata:/data \
  -v $(pwd):/backup \
  busybox \
  tar xzf /backup/mydata-backup.tar.gz -C /data

# 볼륨 간 데이터 복사
docker run --rm \
  -v source-volume:/from \
  -v dest-volume:/to \
  busybox cp -r /from/. /to/
```

---

## Compose에서 볼륨 사용

```yaml
# compose.yaml
services:
  db:
    image: postgres:16
    volumes:
      - pgdata:/var/lib/postgresql/data   # named volume
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro  # bind mount

  app:
    image: myapp:latest
    volumes:
      - ./src:/app/src   # 개발용 bind mount

# 볼륨 선언 (명시적으로 선언해야 공유 가능)
volumes:
  pgdata:
    driver: local
```

---

## 관리 명령어 요약

```bash
# 볼륨 전체 삭제 (사용 중인 것 제외)
docker volume prune

# 컨테이너 + 볼륨 함께 삭제
docker rm -v my-container

# 시스템 전체 정리 (이미지, 컨테이너, 네트워크, 볼륨)
docker system prune -a --volumes

# 디스크 사용량 확인
docker system df
```

---

## 참고 링크

- [Docker 볼륨 공식 문서](https://docs.docker.com/engine/storage/volumes/)
- [Bind Mount 공식 문서](https://docs.docker.com/engine/storage/bind-mounts/)
- [tmpfs Mount](https://docs.docker.com/engine/storage/tmpfs/)
