#!/usr/bin/env bash
# ==============================================================================
# Helper Script: Install Docker and Docker Compose on Ubuntu / Debian VPS
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check root privileges
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    log_error "This script must be run as root (use sudo)."
fi

# Check if Docker is already installed
if command -v docker >/dev/null 2>&1; then
    log_success "Docker is already installed: $(docker --version)"
    if docker compose version >/dev/null 2>&1; then
        log_success "Docker Compose is also installed: $(docker compose version)"
        exit 0
    fi
fi

log_info "Updating system package index..."
apt-get update -y

log_info "Installing prerequisite packages..."
apt-get install -y ca-certificates curl gnupg lsb-release

log_info "Adding Docker official GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Detect distribution
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)

log_info "Detected OS: $DISTRO ($CODENAME)"

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRO \
  $CODENAME stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

log_info "Installing Docker Engine and Docker Compose plugin..."
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log_info "Starting and enabling Docker service..."
systemctl start docker
systemctl enable docker

log_success "Docker installation completed successfully!"
docker --version
docker compose version
