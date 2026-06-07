# Docker 업그레이드 가이드

Docker Engine 업그레이드는 패키지 매니저로 `docker-ce`, CLI, containerd, Buildx, Compose plugin을 함께 갱신합니다. 운영 호스트에서는 컨테이너 재시작 영향과 daemon 설정 변경 여부를 먼저 확인합니다.

## 1. 사전 점검

```bash
docker version
docker compose version
docker ps
sudo systemctl status docker
```

중요 컨테이너가 있다면 재시작 정책과 compose 파일 위치를 확인합니다.

```bash
docker inspect --format '{{.Name}} {{.HostConfig.RestartPolicy.Name}}' $(docker ps -q)
docker info
```

## 2. Ubuntu 업그레이드

이 저장소의 실행 스크립트를 사용합니다.

```bash
./ops/upgrade/upgrade-docker-ubuntu.sh
```

직접 실행하려면 아래 명령을 사용합니다.

```bash
sudo apt-get update
sudo apt-get install -y --only-upgrade \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

sudo systemctl restart docker
```

## 3. RHEL/Rocky/Alma 계열 업그레이드

```bash
sudo dnf upgrade -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

sudo systemctl restart docker
```

특정 버전으로 고정하려면 먼저 설치 가능한 버전을 확인합니다.

```bash
dnf list docker-ce --showduplicates | sort -r
sudo dnf install -y docker-ce-<VERSION> docker-ce-cli-<VERSION>
```

## 4. 확인

```bash
docker version
docker compose version
sudo systemctl status docker
docker ps
docker run --rm hello-world
```

업그레이드 후 bridge network, published port, log driver, storage driver가 정상인지 `docker info`와 애플리케이션 헬스 체크로 확인합니다.

## 5. 롤백

패키지 매니저 캐시나 내부 저장소에 이전 버전 패키지가 있어야 롤백할 수 있습니다.

```bash
# Ubuntu 예시
apt-cache madison docker-ce
sudo apt-get install -y docker-ce=<VERSION> docker-ce-cli=<VERSION>
sudo systemctl restart docker

# RHEL 계열 예시
dnf list docker-ce --showduplicates | sort -r
sudo dnf downgrade -y docker-ce-<VERSION> docker-ce-cli-<VERSION>
sudo systemctl restart docker
```

`/var/lib/docker` 데이터는 패키지 downgrade와 별개입니다. Engine 메이저 버전 변경 후 downgrade가 필요한 환경은 사전 백업 또는 호스트 교체 방식이 더 안전합니다.

