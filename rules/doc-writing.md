# 문서 작성 원칙 — docker-practice

## 언어
- 본문은 한국어, 기술 용어(Dockerfile, compose.yml, volume)는 영어
- 서술체: `~다.`, `~한다.`

## 문서 구조
1. **개요** — 이 기능이 무엇을 해결하는지
2. **Dockerfile/compose 예시** — 실제 동작 가능한 코드
3. **실행 방법** — docker build/run/compose up
4. **확인** — docker ps, inspect, logs
5. **트러블슈팅** — 자주 겪는 문제

## 코드 블록
- Dockerfile 명령어에 한국어 주석
- docker 명령어에 `# 설명` 추가
- `--help` 참조 링크 포함

## 주의사항
- 데이터 삭제 위험: `> **데이터 주의**:` 경고
- 보안 위험: `> **보안 주의**:` 경고
