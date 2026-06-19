#!/bin/bash
echo "[*] Updating Attacker Toolsets and Repositories..."
apt-get update && apt-get install -y docker.io python3-pip pipx nmap smbclient
pipx install git+https://github.com/CravateRouge/bloodyAD.git
pipx install certipy-ad

echo "[*] Crafting Phase 1 Vulnerable Docker Configuration..."
mkdir -p /opt/extreme-app
cd /opt/extreme-app

# Docker kaçış senaryosu için ana host'un root klasörünü container içine acık mount edecek docker-compose kurgusu
cat << 'EOF' > docker-compose.yml
version: '3.8'
services:
  webapp:
    image: ubuntu:latest
    container_name: extreme-app
    volumes:
      - /:/host
    command: tail -f /dev/null
    network_mode: "host"
EOF

sudo docker-compose up -d

echo "[*] Setting up Host Infrastructure Credentials & Flag 1..."
mkdir -p /opt/sysadmin_backups
echo "Credentials Leaked: MEKKE\ahmet.sizma : ZorluSifre123!" > /opt/sysadmin_backups/notlar.txt
echo "Notice: Active Directory gPLink rights delegated to ahmet.sizma over KritikSunucular OU." >> /opt/sysadmin_backups/notlar.txt
echo "FLAG{d0ck3r_3sc4p3_m4st3r_2026}" > /root/flag_1.txt

echo "[*] Kali Linux Environment Deployment Completed Successfully."
