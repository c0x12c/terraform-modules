#!/bin/bash

apt update
apt install -y openvpn

# Prepare OpenVPN certificates
mkdir -p /etc/openvpn/server/

echo '${ca_cert}' > /etc/openvpn/server/ca.crt
echo '${server_cert}' > /etc/openvpn/server/server.crt
echo '${server_private_key}' > /etc/openvpn/server/server.key

# Configure OpenVPN server.conf
echo 'port 1194
port 1194
proto udp
dev tun

dh none
topology subnet

server ${openvpn_ip_pool} 255.255.255.0
ifconfig-pool-persist /var/log/openvpn/ipp.txt
keepalive 10 120
data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305:AES-128-CBC
data-ciphers-fallback AES-128-CBC
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
verb 3
explicit-exit-notify 1
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 208.67.220.220"

%{~ for cidr in route_network_cidrs ~}
push "route ${cidr}"
%{~ endfor ~}

ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/server.crt
key /etc/openvpn/server/server.key

# Setup OAuth 2.0
verify-client-cert none
auth-user-pass-optional
management 127.0.0.1 8081
management-client-auth

# Renegotiating keys after 8h
reneg-sec 28800
auth-gen-token 28800 external-auth' > /etc/openvpn/server/server.conf

# Enable and start OpenVPN server
systemctl enable --now openvpn-server@server.service

# Enable packet forwarding
echo 'net.ipv4.ip_forward=1' >/etc/sysctl.d/99-openvpn.conf
sysctl --system

# Iptable rules for OpenVPN
echo "[Unit]
Description=iptables rules for OpenVPN
After=network-online.target openvpn.service openvpn@.service openvpn-server@.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/sh -c '/usr/sbin/iptables -t nat -A POSTROUTING --src ${openvpn_ip_pool}/24 ! --out-interface tun0 -j MASQUERADE'

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/iptables-openvpn.service

systemctl daemon-reload
systemctl enable --now iptables-openvpn.service

# Install and configure openvpn-auth-oauth2
curl -o openvpn-auth-oauth2.deb --output-dir /tmp -L "https://github.com/jkroepke/openvpn-auth-oauth2/releases/download/v${openvpn_auth_oauth2_version}/openvpn-auth-oauth2_${openvpn_auth_oauth2_version}_linux_amd64.deb"
dpkg -i /tmp/openvpn-auth-oauth2.deb

echo 'CONFIG_OPENVPN_ADDR=tcp://127.0.0.1:8081
CONFIG_HTTP_LISTEN=:9000
CONFIG_HTTP_SECRET=${management_password}

CONFIG_HTTP_BASEURL=https://${openvpn_fqdn}
CONFIG_OAUTH2_PROVIDER=google
CONFIG_OAUTH2_ISSUER=https://accounts.google.com
CONFIG_OAUTH2_CLIENT_ID=${oauth2_client_id}
CONFIG_OAUTH2_CLIENT_SECRET=${oauth2_client_secret}' > /etc/sysconfig/openvpn-auth-oauth2

systemctl enable --now openvpn-auth-oauth2.service

# Setup nginx and cerbot for the Google OAuth 2.0 callback
apt install -y nginx certbot python3-certbot-nginx

echo '
server {
    listen 80;
    server_name ${openvpn_fqdn};
    location / {
        proxy_pass http://127.0.0.1:9000;
    }
}' > /etc/nginx/sites-available/openvpn-auth-oauth2

ln -fs /etc/nginx/sites-available/openvpn-auth-oauth2 /etc/nginx/sites-enabled/default
systemctl restart nginx
certbot --nginx -d '${openvpn_fqdn}' --non-interactive --agree-tos --register-unsafely-without-email
