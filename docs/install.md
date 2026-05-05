# Docker 설치

---

## Ubuntu 22.04 / 24.04

### 1. 기존 버전 제거

```bash
# 구버전 패키지 제거
sudo apt-get remove -y docker docker-engine docker.io containerd runc
```

### 2. 저장소 설정

```bash
# 필수 패키지 설치
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Docker 공식 GPG 키 추가
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 저장소 추가
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 3. Docker 설치

```bash
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
```

### 4. 서비스 시작 및 활성화

```bash
sudo systemctl start docker
sudo systemctl enable docker

# 설치 확인
docker version
docker compose version
```

---

## Amazon Linux 2023

```bash
sudo dnf update -y
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# Docker Compose (플러그인 방식)
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

docker compose version
```

---

## sudo 없이 Docker 사용 (권장)

```bash
# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 그룹 적용 (재로그인 또는 아래 명령 실행)
newgrp docker

# 확인
docker run --rm hello-world
```

> **보안 주의**: `docker` 그룹 멤버십은 사실상 root 권한에 준합니다.
> 운영 환경에서는 [Rootless Docker](https://docs.docker.com/engine/security/rootless/) 사용을 검토하세요.

---

## 설치 확인

```bash
# 버전 확인
docker version

# 데몬 상태 확인
sudo systemctl status docker

# Hello World 테스트
docker run --rm hello-world

# 시스템 정보 확인
docker info
```

---

## Docker 데몬 설정 (`/etc/docker/daemon.json`)

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "default-address-pools": [
    {"base": "172.17.0.0/16", "size": 24}
  ],
  "storage-driver": "overlay2"
}
```

```bash
# 설정 적용
sudo systemctl restart docker
```

| 항목 | 설명 |
|---|---|
| `log-driver` | 로그 드라이버 (`json-file`, `journald`, `fluentd`) |
| `max-size` | 로그 파일 최대 크기 |
| `max-file` | 보관할 로그 파일 수 |
| `storage-driver` | 스토리지 드라이버 (기본: `overlay2`) |

---

## 삭제

```bash
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

# Docker 데이터 전체 삭제 (이미지, 컨테이너, 볼륨 포함)
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```
