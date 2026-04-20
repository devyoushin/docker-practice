# 보안 체크리스트 — docker-practice

## Dockerfile 보안
- [ ] non-root 사용자 실행 (`USER 1000` 또는 `USER appuser`)
- [ ] 베이스 이미지 태그 고정 (latest 금지)
- [ ] 멀티 스테이지 빌드로 빌드 도구 제거
- [ ] `HEALTHCHECK` 설정
- [ ] `.dockerignore`로 민감 파일 제외

## 런타임 보안
- [ ] `--cap-drop ALL` + 필요한 capability만 추가
- [ ] `--read-only` 파일시스템 + tmpfs
- [ ] `--security-opt no-new-privileges:true`
- [ ] 메모리/CPU 제한 (`--memory`, `--cpus`)

## 네트워크 보안
- [ ] 필요한 포트만 `-p` 또는 `expose`
- [ ] `0.0.0.0` 바인딩 최소화
- [ ] 내부 통신은 컨테이너 네트워크 사용

## 시크릿 관리
- [ ] 환경변수 `.env` 파일 — `.gitignore` 추가
- [ ] `docker history`로 시크릿 레이어 누출 확인
- [ ] Docker Secrets 또는 외부 Vault 활용

## 이미지 취약점
- [ ] `docker scout` 또는 `trivy image <name>` 스캔
- [ ] Critical/High 취약점 패치 후 배포
