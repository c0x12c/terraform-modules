#!/bin/bash
set -e

LOG_FILE="/var/log/desktop-setup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting Ubuntu Desktop installation"

log "Updating package list"
apt-get update -y

log "Upgrading installed packages"
apt-get upgrade -y

log "Installing Ubuntu desktop environment (XFCE - lightweight)"
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 \
    xfce4-goodies \
    firefox \
    dbus-x11

log "Installing XRDP for remote desktop access"
apt-get install -y xrdp

log "Configuring XRDP"
systemctl enable xrdp
adduser xrdp ssl-cert

log "Setting up XFCE as default desktop for XRDP"
echo "xfce4-session" > /etc/skel/.xsession
cat <<EOF > /etc/xrdp/startwm.sh
#!/bin/sh
if [ -r /etc/default/locale ]; then
  . /etc/default/locale
  export LANG LANGUAGE
fi
startxfce4
EOF
chmod +x /etc/xrdp/startwm.sh

log "Installing TigerVNC server (alternative remote access)"
apt-get install -y tigervnc-standalone-server tigervnc-common

log "Installing essential tools"
apt-get install -y \
    vim \
    curl \
    wget \
    git \
    htop \
    net-tools \
    unzip

log "Creating default user 'ubuntu' if not exists"
if ! id -u ubuntu > /dev/null 2>&1; then
    useradd -m -s /bin/bash ubuntu
    echo "ubuntu:ubuntu" | chpasswd
    usermod -aG sudo ubuntu
    log "User 'ubuntu' created with password 'ubuntu'"
else
    log "User 'ubuntu' already exists"
fi

log "Setting up VNC for ubuntu user"
mkdir -p /home/ubuntu/.vnc
cat <<EOF > /home/ubuntu/.vnc/xstartup
#!/bin/bash
xrdb \$HOME/.Xresources
startxfce4 &
EOF
chmod +x /home/ubuntu/.vnc/xstartup
chown -R ubuntu:ubuntu /home/ubuntu/.vnc

log "Creating VNC password for ubuntu user"
echo "ubuntu" | vncpasswd -f > /home/ubuntu/.vnc/passwd
chmod 600 /home/ubuntu/.vnc/passwd
chown ubuntu:ubuntu /home/ubuntu/.vnc/passwd

log "Creating systemd service for VNC"
cat <<EOF > /etc/systemd/system/vncserver@.service
[Unit]
Description=Start TigerVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu

PIDFile=/home/ubuntu/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1920x1080 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF

log "Starting XRDP service"
systemctl start xrdp
systemctl status xrdp --no-pager

log "Enabling VNC service on display :1"
systemctl enable vncserver@1.service
systemctl start vncserver@1.service

log "Installing Chrome browser"
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
apt-get install -y /tmp/chrome.deb || true
rm /tmp/chrome.deb

log "Installing VS Code"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
apt-get update -y
apt-get install -y code

log "Cleaning up"
apt-get autoremove -y
apt-get clean

log "Desktop installation complete!"
log "==========================================="
log "Connection Information:"
log "RDP: Use port 3389 with credentials ubuntu/ubuntu"
log "VNC: Use port 5900 with password 'ubuntu'"
log "SSH: Use your key pair"
log "==========================================="
log "IMPORTANT: Change the default password immediately!"
log "==========================================="

cat <<EOF > /home/ubuntu/Desktop/README.txt
Welcome to Ubuntu Desktop on AWS EC2!

Connection Methods:
1. RDP (Remote Desktop Protocol) - Port 3389
   - Use any RDP client (Microsoft Remote Desktop, Remmina, etc.)
   - Username: ubuntu
   - Password: ubuntu

2. VNC (Virtual Network Computing) - Port 5900
   - Use any VNC client (TigerVNC Viewer, RealVNC, etc.)
   - Password: ubuntu

3. SSH - Port 22
   - Use your SSH key pair

SECURITY WARNING:
The default password is 'ubuntu'. Please change it immediately by running:
  passwd

Installed Software:
- XFCE Desktop Environment
- Firefox Browser
- Google Chrome
- Visual Studio Code
- Git, Vim, Curl, Wget, and other developer tools

Enjoy your Ubuntu Desktop!
EOF

chown ubuntu:ubuntu /home/ubuntu/Desktop/README.txt || true

log "User data script completed successfully"
