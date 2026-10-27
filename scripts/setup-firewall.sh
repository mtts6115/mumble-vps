#!/usr/bin/env bash
# ==============================================================================
# Helper Script: Configure Linux Firewall for Mumble (Port 64738 TCP/UDP)
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo -e "${RED}[ERROR] Please run as root (sudo).${NC}"
    exit 1
fi

PORT="${1:-64738}"

echo -e "${BLUE}[INFO] Configuring firewall rules for Mumble on port ${PORT}...${NC}"

# Check for UFW
if command -v ufw >/dev/null 2>&1; then
    echo -e "${BLUE}[INFO] Detected UFW firewall.${NC}"
    ufw allow "${PORT}/tcp" comment 'Mumble TCP'
    ufw allow "${PORT}/udp" comment 'Mumble UDP'
    ufw reload || true
    echo -e "${GREEN}[SUCCESS] UFW rules updated successfully.${NC}"
# Check for firewalld (RHEL/CentOS/Fedora)
elif command -v firewall-cmd >/dev/null 2>&1; then
    echo -e "${BLUE}[INFO] Detected firewalld.${NC}"
    firewall-cmd --permanent --add-port="${PORT}/tcp"
    firewall-cmd --permanent --add-port="${PORT}/udp"
    firewall-cmd --reload
    echo -e "${GREEN}[SUCCESS] firewalld rules updated successfully.${NC}"
# Check for iptables
elif command -v iptables >/dev/null 2>&1; then
    echo -e "${BLUE}[INFO] Applying rules via iptables...${NC}"
    iptables -A INPUT -p tcp --dport "${PORT}" -j ACCEPT
    iptables -A INPUT -p udp --dport "${PORT}" -j ACCEPT
    echo -e "${GREEN}[SUCCESS] iptables rules applied.${NC}"
else
    echo -e "${RED}[WARN] No supported firewall tool (ufw, firewalld, iptables) found.${NC}"
fi

echo -e "${GREEN}[DONE] Port ${PORT} (TCP/UDP) is now open.${NC}"
