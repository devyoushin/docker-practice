# AGENTS.md — docker-practice Codex 작업 지침

이 저장소는 Docker, Dockerfile, Compose, CLI 운영 지식 베이스입니다. Codex 작업 시 `CLAUDE.md`와 `docs/rules/`의 규칙을 동일하게 따릅니다.

## 공통 원칙

- 개념/가이드 문서는 `docs/`에 둡니다.
- Dockerfile, Compose, CLI 스크립트, 설치/업그레이드 스크립트는 `ops/`에 둡니다.
- Compose 예제는 실제 실행 가능한 형태를 우선합니다.
- Dockerfile 예제는 multi-stage, non-root, cache 최적화, image size를 고려합니다.

## Claude와의 싱크

- Claude용 상세 지침은 `CLAUDE.md`를 참고합니다.
- Codex 작업도 `docs/rules/`의 문서/코드 규칙을 따릅니다.
- Docker 실행 자산이 늘어나면 `ops/README.md`도 함께 갱신합니다.

## 작업 체크리스트

- `git status --short` 확인
- shell script는 `bash -n` 검사
- Compose/YAML 파일은 YAML 문법 검사
- Dockerfile은 가능하면 `docker build` 또는 정적 검토
- 링크 검사와 `git diff --check` 수행
