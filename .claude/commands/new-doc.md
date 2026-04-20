새 Docker 가이드 문서를 생성합니다.

**사용법**: `/new-doc <주제명>`

**예시**: `/new-doc multi-stage-build`

주제 분류:
- 이미지: image, dockerfile, build, multi-stage
- 스토리지: volume, bind-mount, tmpfs
- 네트워크: network, bridge, overlay, host
- 운영: compose, swarm, logging, monitoring

`<주제명>-guide.md` 생성 시 포함 내용:
- CLAUDE.md 환경 설정 반영 (Docker 버전)
- 실제 동작 가능한 Dockerfile 또는 compose.yml
- docker 명령어 예시 (한국어 주석)
- 트러블슈팅 섹션
