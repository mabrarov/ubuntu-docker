#!/bin/bash

set -e

# Taken from https://docs.docker.com/engine/install/ubuntu/
for pkg in \
  docker.io \
  docker-doc \
  docker-compose \
  docker-compose-v2 \
  podman-docker \
  containerd \
  runc \
  ; do \
  apt -y remove "${pkg}" ; \
done
# Add Docker's official GPG key:
apt -y update
apt -y install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
# Install Docker CE, Docker CLI, Compose Docker plugin
apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

if [[ -n "${DOCKER_USERNAME}" ]]; then
  # Taken from https://docs.docker.com/engine/install/linux-postinstall/
  echo "Adding user ${DOCKER_USERNAME} to docker group"
  usermod -aG docker "${DOCKER_USERNAME}"
fi

# Remote access to Docker Daemon over 2375 TCP port (DOCKER_HOST=tcp://host:2375)
mkdir -p /etc/systemd/system/docker.service.d
echo -e '[Service]\nExecStart=\nExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock -H tcp://0.0.0.0:2375' \
  | tee /etc/systemd/system/docker.service.d/override.conf
systemctl daemon-reload

# Enable and start Docker service
systemctl enable docker
systemctl start docker

# Check Docker
docker version
