#!/usr/bin/env bash
# ==============================================================================
# Bare-Metal Automated Installer: Mumble Server (Murmur) for Ubuntu / Debian
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Verify Root
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    log_error "Please run this installer as root: sudo bash $0"
fi

echo -e "${CYAN}"
echo "=========================================================="
echo "      Mumble Server (Murmur) Automated Native Installer   "
echo "=========================================================="
echo -e "${NC}"

# Ask for SuperUser Password
if [ -z "${MUMBLE_PASSWORD:-}" ]; then
    echo -ne "${YELLOW}Enter desired password for 'SuperUser' (admin): ${NC}"
    read -r -s MUMBLE_PASSWORD
    echo ""
    if [ -z "$MUMBLE_PASSWORD" ]; then
        log_warn "No password provided. Generating a random secure password..."
        MUMBLE_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9_ | head -c 16)
        log_info "Generated Password: ${GREEN}$MUMBLE_PASSWORD${NC}"
    fi
fi

log_info "Step 1: Updating APT repositories..."
apt-get update -y

log_info "Step 2: Installing mumble-server..."
DEBIAN_FRONTEND=noninteractive apt-get install -y mumble-server ufw

log_info "Step 3: Configuring SuperUser password..."
mumble-server -supw "$MUMBLE_PASSWORD"

log_info "Step 4: Configuring /etc/mumble-server.ini defaults..."
CONFIG_FILE="/etc/mumble-server.ini"
if [ -f "$CONFIG_FILE" ]; then
    # Backup original config
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%F_%T)"
    
    # Optimize bandwidth to 96kbps
    sed -i 's/^bandwidth=.*/bandwidth=96000/' "$CONFIG_FILE" || true
    # Allow 100 users
    sed -i 's/^users=.*/users=100/' "$CONFIG_FILE" || true
    # Set welcome text
    sed -i 's/^welcometext=.*/welcometext="<br \/>Welcome to our <b>Mumble Server<\/b>!<br \/>"/' "$CONFIG_FILE" || true
fi

log_info "Step 5: Configuring Firewall (UFW)..."
if command -v ufw >/dev/null 2>&1; then
    ufw allow 64738/tcp comment 'Mumble Control' || true
    ufw allow 64738/udp comment 'Mumble Voice' || true
    log_success "UFW rules added for port 64738 (TCP/UDP)."
fi

log_info "Step 6: Enabling and starting mumble-server service..."
systemctl enable mumble-server
systemctl restart mumble-server

# Retrieve Public IP
PUBLIC_IP=$(curl -s -4 https://ifconfig.me || curl -s -4 https://api.ipify.org || echo "YOUR_VPS_IP")

echo ""
echo -e "${GREEN}==========================================================${NC}"
echo -e "${GREEN}         Mumble Server Successfully Installed!            ${NC}"
echo -e "${GREEN}==========================================================${NC}"
echo -e "Server Address : ${CYAN}${PUBLIC_IP}${NC}"
echo -e "Port           : ${CYAN}64738${NC}"
echo -e "Admin Username : ${CYAN}SuperUser${NC}"
echo -e "Admin Password : ${CYAN}${MUMBLE_PASSWORD}${NC}"
echo "----------------------------------------------------------"
echo "To connect:"
echo "1. Open Mumble client on your PC/Mobile."
echo "2. Add Server -> Address: ${PUBLIC_IP}, Port: 64738"
echo "3. Log in as 'SuperUser' with your password to manage channels."
echo "=========================================================="
