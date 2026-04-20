# 모니터링 지침 — docker-practice

## 컨테이너 상태 확인

```bash
# 실행 중 컨테이너 목록
docker ps

# 리소스 사용량 (실시간)
docker stats

# 컨테이너 상세 정보
docker inspect <container>

# 로그 확인
docker logs --tail 100 -f <container>

# 헬스 체크 상태
docker inspect <container> | jq '.[].State.Health'
```

## compose 환경 모니터링

```bash
# 서비스 상태
docker compose ps

# 로그 (전체)
docker compose logs --tail 50 -f

# 특정 서비스 로그
docker compose logs --tail 50 -f app
```

## 리소스 이슈 확인

```bash
# 디스크 사용량
docker system df

# 사용하지 않는 리소스 확인 (삭제 전 확인용)
docker system df -v

# 이미지 레이어 확인
docker history <image>
```

## Node Exporter + cAdvisor (Prometheus 수집)

컨테이너 메트릭을 Prometheus로 수집하려면 cAdvisor 연동:

```yaml
# compose.yml에 추가
cadvisor:
  image: gcr.io/cadvisor/cadvisor:v0.47.0
  volumes:
    - /:/rootfs:ro
    - /var/run:/var/run:ro
    - /sys:/sys:ro
    - /var/lib/docker/:/var/lib/docker:ro
  ports:
    - "8080:8080"
```
