# docker-practice — 프로젝트 가이드

## 프로젝트 설정
- 환경: 로컬 (Ubuntu 22.04 / Amazon Linux 2023)
- Docker 버전: 26.x 이상
- Docker Compose: v2 (플러그인 방식)

---

## 디렉토리 구조

```
docker-practice/
├── CLAUDE.md                  # 이 파일 (자동 로드)
├── .claude/
│   ├── settings.json
│   └── commands/              # /new-doc, /new-runbook, /review-doc, /add-troubleshooting, /search-kb
├── agents/                    # doc-writer, dockerfile-reviewer, compose-designer, security-auditor
├── templates/                 # service-doc, runbook, incident-report
├── rules/                     # doc-writing, docker-conventions, security-checklist, monitoring
└── *-guide.md                 # 주제별 가이드 문서
```

---

## 커스텀 슬래시 명령어

| 명령어 | 설명 | 사용 예시 |
|--------|------|---------|
| `/new-doc` | 새 가이드 문서 생성 | `/new-doc multi-stage-build` |
| `/new-runbook` | 새 런북 생성 | `/new-runbook 컨테이너 긴급 로그 수집` |
| `/review-doc` | Dockerfile/문서 검토 | `/review-doc image-guide.md` |
| `/add-troubleshooting` | 트러블슈팅 케이스 추가 | `/add-troubleshooting OOM 반복 재시작` |
| `/search-kb` | 지식베이스 검색 | `/search-kb 볼륨 퍼미션 문제` |

---

## 가이드 문서 목록

| 문서 | 주제 |
|------|------|
| `install.md` | Docker 설치 (Ubuntu/AL2023) |
| `architecture-guide.md` | Docker 아키텍처 (daemon, containerd, runc) |
| `image-guide.md` | 이미지 빌드, 레이어, 멀티 스테이지 |
| `volume-guide.md` | 볼륨 종류, 마운트, 퍼미션 |
| `network-guide.md` | 네트워크 드라이버, DNS, 포트 포워딩 |
| `compose-guide.md` | Docker Compose v2 실전 |
| `troubleshooting-guide.md` | 트러블슈팅 |

---

## 핵심 명령어

```bash
# 컨테이너 상태 확인
docker ps
docker stats

# 이미지 취약점 스캔
docker scout cves <image>
# 또는
trivy image <image>

# Dockerfile 베스트 프랙티스 확인
docker build --no-cache -t test .
docker history test
```
