# 바이너리 파일을 직접 다운로드하여 설치

### 1. 최신 버전 압축 파일 다운로드
```bash
wget https://download.docker.com/linux/static/stable/x86_64/docker-27.3.1.tgz
```

### 2. 압축 해제
```bash
tar -zxvf docker-27.3.1.tgz
```

### 3. 바이너리 파일을 시스템 실행 경로로 이동
```bash
sudo cp docker/* /usr/bin/
```

### 4. Docker 데몬 실행 (수동)
```bash
sudo dockerd &
```

### 5. Systemd 서비스 등록
```bash
sudo vi /etc/systemd/system/docker.service
```

```bash
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
```

### 6. 서비스 활성화 및 시작
```
sudo systemctl daemon-reload
sudo systemctl enable --now docker
```
