# Docker 네트워크

---

## 네트워크 드라이버 종류

```
Docker Host
  │
  ├── bridge (기본)   → 호스트에 가상 브리지(docker0) 생성, NAT으로 외부 통신
  ├── host            → 컨테이너가 호스트 네트워크 스택을 직접 사용
  ├── none            → 네트워크 인터페이스 없음 (격리)
  ├── overlay         → 여러 Docker 호스트 간 컨테이너 통신 (Swarm)
  └── macvlan         → 컨테이너에 MAC 주소 할당, L2 네트워크 직접 연결
```

---

## Bridge 네트워크 (기본)

```
                    인터넷
                      │
              ┌───────┴───────┐
              │   호스트 eth0  │
              │  (192.168.1.x) │
              └───────┬───────┘
                      │ NAT (iptables MASQUERADE)
              ┌───────┴───────┐
              │    docker0    │  ← 가상 브리지 (172.17.0.1/16)
              └──┬────────┬──┘
                 │        │
         container A   container B
         172.17.0.2    172.17.0.3
```

```bash
# 기본 bridge 네트워크 확인
docker network ls
docker network inspect bridge

# 기본 bridge는 컨테이너 이름으로 DNS 조회 불가 (IP 직접 사용)
docker run -d --name web nginx
docker run -it --rm busybox ping web   # 실패: 이름 해석 안 됨
```

> **기본 bridge의 한계**: 컨테이너 이름 기반 DNS가 동작하지 않습니다.
> 컨테이너 간 통신에는 **사용자 정의 bridge** 네트워크를 사용하세요.

---

## 사용자 정의 Bridge 네트워크 (권장)

```bash
# 네트워크 생성
docker network create my-network

# 서브넷 지정
docker network create \
  --driver bridge \
  --subnet 192.168.100.0/24 \
  --gateway 192.168.100.1 \
  my-network

# 컨테이너를 네트워크에 연결하여 실행
docker run -d --name db --network my-network postgres:16
docker run -d --name web --network my-network nginx

# 이름으로 DNS 조회 가능
docker run -it --rm --network my-network busybox ping db   # 성공
```

### 기본 bridge vs 사용자 정의 bridge

| 항목 | 기본 bridge | 사용자 정의 bridge |
|---|---|---|
| 컨테이너 이름 DNS | 불가 | 가능 |
| 컨테이너 간 격리 | 없음 (모두 연결됨) | 네트워크별 격리 |
| 동적 연결/해제 | 불가 (재시작 필요) | 가능 (`docker network connect`) |
| IP 범위 설정 | 불가 | 가능 |

```bash
# 실행 중인 컨테이너를 네트워크에 연결/해제
docker network connect my-network web
docker network disconnect my-network web
```

---

## Host 네트워크

컨테이너가 호스트 네트워크 스택을 직접 사용합니다. 포트 포워딩이 없어 성능이 좋지만 격리는 없습니다.

```bash
docker run -d --network host nginx

# 이제 호스트의 포트 80을 직접 사용
curl http://localhost:80
```

**사용 사례**:
- 네트워크 성능이 중요한 경우 (고성능 데이터 처리)
- 호스트 네트워크 인터페이스를 직접 조작해야 하는 경우

---

## 포트 바인딩

```bash
# 호스트 포트 8080 → 컨테이너 포트 80
docker run -d -p 8080:80 nginx

# 특정 인터페이스에만 바인딩 (보안)
docker run -d -p 127.0.0.1:8080:80 nginx

# 여러 포트 바인딩
docker run -d -p 8080:80 -p 8443:443 nginx

# 랜덤 호스트 포트 (컨테이너 포트만 지정)
docker run -d -p 80 nginx
docker port <container_id>   # 할당된 포트 확인
```

```
호스트:8080 ──iptables DNAT──▶ 컨테이너:80
```

---

## 컨테이너 간 통신 예시

```bash
# app + db 네트워크 구성
docker network create app-net

docker run -d \
  --name postgres \
  --network app-net \
  -e POSTGRES_PASSWORD=secret \
  postgres:16

docker run -d \
  --name app \
  --network app-net \
  -e DATABASE_URL=postgresql://postgres:secret@postgres:5432/mydb \
  myapp:latest
```

```
app 컨테이너
  └── DATABASE_URL에서 hostname = "postgres"
  └── Docker DNS가 postgres 컨테이너 IP로 해석
  └── app-net 내에서 직접 통신
```

---

## 네트워크 관리 명령어

```bash
# 네트워크 목록
docker network ls

# 네트워크 상세 정보 (연결된 컨테이너 포함)
docker network inspect my-network

# 네트워크 삭제
docker network rm my-network

# 사용하지 않는 네트워크 전체 삭제
docker network prune

# 컨테이너의 네트워크 확인
docker inspect web | jq '.[0].NetworkSettings.Networks'
```

---

## 참고 링크

- [Docker 네트워킹 공식 문서](https://docs.docker.com/engine/network/)
- [Bridge 네트워크 드라이버](https://docs.docker.com/engine/network/drivers/bridge/)
- [네트워킹 튜토리얼](https://docs.docker.com/engine/network/tutorials/)
