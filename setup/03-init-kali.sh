#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "[*] Updating Kali Linux package list..."
sudo apt-get update -y

echo "[*] Installing core dependencies and Docker Engine..."
sudo apt-get install -y docker.io nmap python3-pip python3-venv git

# CrackMapExec / CME Aliasing & Smart Installation Check
echo "[*] Ensuring CrackMapExec (cme) is correctly installed..."
if ! command -v crackmapexec &> /dev/null && ! command -v cme &> /dev/null; then
    sudo apt-get install -y crackmapexec || pip3 install crackmapexec
fi

# Ensure both commands 'crackmapexec' and 'cme' point to the active binary
if command -v crackmapexec &> /dev/null && ! command -v cme &> /dev/null; then
    sudo ln -s $(which crackmapexec) /usr/local/bin/cme
elif command -v cme &> /dev/null && ! command -v crackmapexec &> /dev/null; then
    sudo ln -s $(which cme) /usr/local/bin/crackmapexec
fi

# Install Modern AD Exploitation Toolkits
echo "[*] Installing Advanced Active Directory Toolkits..."
sudo apt-get install -y certipy-ad impacket-scripts || pip3 install certipy-ad impacket

# Install bloodyAD for GPO/ACL manipulation
pip3 install bloodyAD --break-system-packages 2>/dev/null || pip3 install bloodyAD

# Service Initialization
sudo systemctl enable --now docker

echo "[*] Deploying vulnerable Docker Container (Container Escape Target)..."
sudo docker run -d --name extreme-app \
  --restart always \
  -v /:/host \
  -p 80:80 \
  ubuntu:latest sh -c "sleep infinity"

echo "[*] Creating internal sysadmin leak note on host filesystem..."
sudo mkdir -p /opt/sysadmin_backups
sudo cat << 'EOF' > /opt/sysadmin_backups/notlar.txt
--- INTERNAL SYSADMIN LEAK NOTE ---
Temporary service credentials used during the ADCS deployment phase on DC02:
User: MEKKE\ahmet.sizma
Pass: ZorluSifre123!
Note: Remember to revoke the gPLink delegation on the 'KritikSunucular' OU after testing.
EOF
sudo chmod 644 /opt/sysadmin_backups/notlar.txt

# Inject Docker Escape Flag into the host filesystem
sudo echo "FLAG{d0ck3r_3sc4p3_m4st3r_2026}" > /root/flag_1.txt

echo "[+] Extreme AD Lab Provisioned successfully! Kali IP: 192.168.56.20"