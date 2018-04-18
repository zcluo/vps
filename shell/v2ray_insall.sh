#!/bin/bash
echo "$1"
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/caddy_install.sh
chmod +x caddy_install.sh
bash caddy_install.sh install http.filemanager,http.forwardproxy,http.proxyprotocol
mkdir -p /usr/local/caddy/
bash <(curl -L -s https://install.direct/go.sh)
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/Caddyfile -O /usr/local/caddy/Caddyfile
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/config.json -O /etc/v2ray/config.json
sed -e "s/xxx\.xxxxxx\.xxx/$1/g" /usr/local/caddy/Caddyfile > /usr/local/caddy/Caddyfile.new
sed -e "s/xxx\.xxxxxx\.xxx/$1/g" /etc/v2ray/config.json > /etc/v2ray/config.json.new
\mv /usr/local/caddy/Caddyfile.new  /usr/local/caddy/Caddyfile
\mv /etc/v2ray/config.json.new /etc/v2ray/config.json
systemctl enable caddy &&  systemctl enable v2ray && systemctl restart caddy && systemctl restart v2ray
\rm -rf caddy_install.sh
crontab -l > crontab.bak
echo "0 0 * * 0 bash v2rayud.sh" >> crontab.bak
crontab crontab.bak
reboot



