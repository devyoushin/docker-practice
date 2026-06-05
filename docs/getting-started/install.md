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

## RHEL / Rocky Linux / AlmaLinux 계열

RHEL 계열에서는 두 가지 방식으로 Docker Engine을 설치할 수 있습니다.

| 방식 | 권장 상황 | 특징 |
|---|---|---|
| Docker 공식 RPM 저장소 | 일반 서버, 운영 환경 | 설치와 업그레이드가 `dnf`로 관리되어 가장 편함 |
| RPM 파일 직접 설치 | 폐쇄망, 망분리, 내부 저장소 환경 | 필요한 RPM과 의존성을 직접 맞춰야 함 |

### 1. 기존 충돌 패키지 제거

배포판 기본 패키지나 Podman 계열 패키지가 Docker 공식 패키지와 충돌할 수 있습니다.

```bash
sudo dnf remove -y \
  docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-engine \
  podman \
  runc
```

> `/var/lib/docker`의 이미지, 컨테이너, 볼륨, 네트워크 데이터는 패키지 제거만으로 삭제되지 않습니다.

### 2. 저장소에서 설치 (권장)

```bash
# dnf 저장소 관리 명령 제공
sudo dnf install -y dnf-plugins-core

# Docker 공식 RPM 저장소 추가
sudo dnf config-manager --add-repo \
  https://download.docker.com/linux/rhel/docker-ce.repo

# Docker Engine, CLI, containerd, Buildx, Compose v2 설치
sudo dnf install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# 서비스 시작 및 부팅 시 자동 시작
sudo systemctl enable --now docker

# 확인
sudo docker run --rm hello-world
docker version
docker compose version
```

GPG 키 확인 메시지가 나오면 Docker 공식 키 지문이 `060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35`인지 확인한 뒤 승인합니다.

### 3. 특정 버전 설치

운영 환경에서는 최신 버전 자동 설치보다 검증된 버전을 고정하는 것이 더 안전할 수 있습니다.

```bash
# 설치 가능한 버전 확인
dnf list docker-ce --showduplicates | sort -r

# 예시: VERSION_STRING은 dnf list 결과의 버전 문자열로 교체
VERSION_STRING="3:29.0.0-1.el9"

sudo dnf install -y \
  docker-ce-${VERSION_STRING} \
  docker-ce-cli-${VERSION_STRING} \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
```

### 4. RPM 파일 직접 설치

인터넷이 없는 서버에서는 Docker RPM 저장소에서 필요한 패키지를 내려받아 대상 서버로 복사한 뒤 설치합니다.

필요 패키지:

| 패키지 | 역할 |
|---|---|
| `docker-ce` | Docker Engine 데몬 |
| `docker-ce-cli` | `docker` CLI |
| `containerd.io` | 컨테이너 런타임 |
| `docker-buildx-plugin` | Buildx 빌드 플러그인 |
| `docker-compose-plugin` | Compose v2 플러그인 |

다운로드 가능한 서버에서:

```bash
sudo dnf install -y dnf-plugins-core

mkdir -p docker-rpms
cd docker-rpms

dnf download --resolve \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
```

대상 서버에서:

```bash
sudo dnf install -y ./*.rpm
sudo systemctl enable --now docker
sudo docker run --rm hello-world
```

`dnf install ./*.rpm`은 로컬 RPM을 설치하면서 OS 저장소에서 가능한 의존성을 함께 해결합니다. 완전 폐쇄망이면 `dnf download --resolve`로 받은 의존성 RPM도 모두 함께 복사해야 합니다.

### 5. 의존성 맞추는 방법

| 상황 | 처리 방법 |
|---|---|
| 인터넷 가능 | Docker 공식 저장소를 추가하고 `dnf install` 사용 |
| 폐쇄망이지만 내부 yum/dnf 저장소 있음 | Docker RPM과 의존성 RPM을 내부 저장소에 등록 |
| 완전 폐쇄망 | 동일 OS/아키텍처에서 `dnf download --resolve`로 RPM 전체 확보 |
| 버전 고정 필요 | `dnf list --showduplicates`로 버전 확인 후 같은 버전의 `docker-ce`, `docker-ce-cli` 설치 |

주의할 점:

- OS 메이저 버전이 다르면 RPM 의존성이 달라질 수 있습니다. 예를 들어 RHEL 8용 RPM을 RHEL 9 서버에 섞어 쓰지 않습니다.
- CPU 아키텍처가 다르면 설치할 수 없습니다. `uname -m`으로 `x86_64`, `aarch64` 등을 확인합니다.
- `docker-ce`와 `docker-ce-cli`는 같은 버전으로 맞추는 것이 좋습니다.
- `containerd.io`, Buildx, Compose 플러그인은 Docker Engine과 함께 검증한 버전으로 관리합니다.

### 6. 업그레이드

저장소 설치 방식:

```bash
sudo dnf upgrade -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

sudo systemctl restart docker
docker version
docker compose version
```

수동 RPM 설치 방식:

```bash
# 새 RPM 파일이 있는 디렉터리에서 실행
sudo dnf upgrade -y ./*.rpm
sudo systemctl restart docker
docker version
docker compose version
```

운영 서버에서는 업그레이드 전에 다음을 확인합니다.

```bash
docker ps
docker images
docker volume ls
docker network ls
docker info
```

업그레이드 중 Docker 데몬이 재시작되면 컨테이너가 중단될 수 있습니다. 중요한 서비스는 점검 창을 잡고, Compose/Swarm/Kubernetes 등 실행 방식별 재기동 절차를 먼저 준비합니다.

---

## 방화벽 백엔드: iptables와 nftables

Docker는 Linux에서 bridge 네트워크, 포트 게시(`-p`), NAT/masquerade를 구현하기 위해 호스트 방화벽 규칙을 생성합니다.

### 기본 동작

- Docker Engine은 기본적으로 iptables 백엔드를 사용합니다.
- Docker Engine 29.0.0부터 nftables 백엔드를 지원하지만, 공식 문서 기준으로 아직 실험적 기능입니다.
- bridge 네트워크에서는 iptables와 nftables가 같은 기능을 제공합니다.
- Swarm overlay 네트워크 규칙은 아직 nftables로 완전히 이전되지 않았으므로 Swarm 모드에서는 nftables 백엔드를 사용할 수 없습니다.

### nftables 백엔드 사용

`/etc/docker/daemon.json`에 다음 설정을 추가합니다.

```json
{
  "firewall-backend": "nftables"
}
```

적용:

```bash
sudo systemctl restart docker
docker info
sudo nft list ruleset
```

기존 `daemon.json`에 로그, 스토리지 설정이 있다면 JSON 객체 안에 `"firewall-backend": "nftables"` 항목만 추가합니다.

### nftables 전환 시 주의사항

| 항목 | 설명 |
|---|---|
| IP forwarding | nftables 백엔드에서는 Docker가 IP forwarding을 자동 활성화하지 않습니다. |
| `DOCKER-USER` | nftables에는 iptables의 `DOCKER-USER` 체인이 없습니다. 별도 nftables table/base chain으로 이전해야 합니다. |
| 기존 iptables 정책 | iptables `FORWARD` 정책이 `DROP`이면 nftables 규칙이 허용해도 패킷이 드롭될 수 있습니다. |
| Docker 관리 테이블 | Docker가 만든 nftables table은 직접 수정하지 않습니다. 재시작이나 네트워크 변경 시 사라질 수 있습니다. |

IP forwarding이 필요한 bridge 네트워크를 사용한다면 호스트에서 명시적으로 활성화합니다.

```bash
cat <<'EOF' | sudo tee /etc/sysctl.d/99-docker-forwarding.conf
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF

sudo systemctl restart systemd-sysctl
```

물리 서버처럼 여러 NIC가 있는 호스트에서는 Docker와 무관한 인터페이스 간 forwarding이 열리지 않도록 nftables나 firewalld 정책을 별도로 둡니다.

### Docker 방화벽 규칙 비활성화 주의

`daemon.json`에서 `"iptables": false` 또는 `"ip6tables": false`를 설정하면 Docker가 대부분의 방화벽 규칙을 만들지 않습니다. 이름은 iptables지만 nftables 백엔드에도 영향을 줍니다.

이 설정은 대부분의 환경에서 권장하지 않습니다. bridge 네트워크의 외부 통신, NAT, 포트 게시 동작이 깨질 수 있고, 의도치 않게 컨테이너 포트가 로컬 네트워크에 노출될 수 있습니다.

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

---

## 참고 링크

- [Install Docker Engine on RHEL](https://docs.docker.com/engine/install/rhel/)
- [Packet filtering and firewalls](https://docs.docker.com/engine/network/packet-filtering-firewalls/)
- [Docker with nftables](https://docs.docker.com/engine/network/firewall-nftables/)
