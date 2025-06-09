#!/bin/bash
set -e

# Install Docker if not present
if ! command -v docker &> /dev/null; then
  apt-get update
  apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
  apt-get update
  apt-get install -y docker-ce
fi

# Install docker-compose if not present
if ! command -v docker-compose &> /dev/null; then
  curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Install AWS CLI if not present
if ! command -v aws &> /dev/null; then
  apt-get install -y unzip python3-pip
  pip3 install awscli
fi

# Log in to ECR for each microservice
%{ for svc, url in ecr_repo_urls ~}
$(aws ecr get-login-password --region ${aws_region}) | docker login --username AWS --password-stdin ${url}
%{ endfor ~}

# Create docker-compose.yml
cat > /home/ubuntu/docker-compose.yml <<EOL
version: '3'
services:
%{ for svc, url in ecr_repo_urls ~}
  ${svc}:
    image: ${url}:latest
    restart: always
    ports:
      - "8${svc == "web" ? "0" : index(ecr_repo_urls, svc) + 1}:80"
%{ endfor ~}
EOL

# Start microservices
cd /home/ubuntu
docker-compose up -d