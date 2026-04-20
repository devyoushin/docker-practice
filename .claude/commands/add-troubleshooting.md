Docker 트러블슈팅 케이스를 추가합니다.

**사용법**: `/add-troubleshooting <증상 설명>`

**예시**: `/add-troubleshooting 컨테이너가 OOM으로 반복 재시작`

다음 형식으로 작성하고 `troubleshooting-guide.md`에 추가하세요:

```markdown
### <증상>

**원인**: <근본 원인>

**확인 방법**:
\`\`\`bash
docker stats <container>
docker inspect <container> | jq '.[].State'
docker logs --tail 100 <container>
\`\`\`

**해결**: <해결 방법>
**예방**: <재발 방지>
```
