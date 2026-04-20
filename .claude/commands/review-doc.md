Docker 가이드 문서 또는 Dockerfile을 검토합니다.

**사용법**: `/review-doc <파일 경로>`

**예시**: `/review-doc image-guide.md`

검토 기준:

**Dockerfile**
- [ ] 베이스 이미지 태그 고정 (latest 금지)
- [ ] 멀티 스테이지 빌드로 이미지 크기 최소화
- [ ] non-root 사용자로 실행 (USER 명령)
- [ ] `.dockerignore` 활용
- [ ] RUN 레이어 최소화 (명령어 체인)
- [ ] HEALTHCHECK 설정

**compose.yml**
- [ ] `healthcheck` 설정
- [ ] `restart` 정책 (unless-stopped)
- [ ] 볼륨 명시적 정의
- [ ] 환경변수 `.env` 파일 분리

**보안**
- [ ] 하드코딩된 시크릿 없음
- [ ] 불필요한 포트 노출 없음
- [ ] read-only 파일시스템 설정 고려
