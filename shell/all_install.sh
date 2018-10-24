#!/bin/bash
echo "$1"
apt install curl screen net-tools iperf3 -y
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/caddy_install.sh && chmod +x caddy_install.sh && bash caddy_install.sh install http.filemanager
wget -N --no-check-certificate https://raw.githubusercontent.com/teddysun/across/master/bbr.sh
mkdir -p /usr/local/caddy/
bash <(curl -L -s https://install.direct/go.sh)
sleep 20
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/Caddyfile -O /usr/local/caddy/Caddyfile
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/config.json -O /etc/v2ray/config.json
sed -e "s/xxx\.xxxxxx\.xxx/$1/g" /usr/local/caddy/Caddyfile > /usr/local/caddy/Caddyfile.new
sed -e "s/xxx\.xxxxxx\.xxx/$1/g" /etc/v2ray/config.json > /etc/v2ray/config.json.new
\mv /usr/local/caddy/Caddyfile.new  /usr/local/caddy/Caddyfile
\mv /etc/v2ray/config.json.new /etc/v2ray/config.json
chmod -x /etc/systemd/system/v2ray.service
systemctl enable caddy &&  systemctl enable v2ray && systemctl restart caddy && systemctl restart v2ray
\rm -rf caddy_install.sh
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/v2rayud.sh
chmod +x v2rayud.sh
crontab -l > crontab.bak
echo "0 0 * * 0 bash v2rayud.sh" >> crontab.bak
crontab crontab.bak
apt install -y expect
wget --no-check-certificate -O install_bbr_expect.sh https://raw.githubusercontent.com/zcluo/vps/master/shell/install_bbr_expect.sh
chmod +x install_bbr_expect.sh
./install_bbr_expect.sh
wget --no-check-certificate -O shadowsocks-all.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh
chmod +x shadowsocks-all.sh
wget --no-check-certificate -O install_ss_expect.sh https://raw.githubusercontent.com/zcluo/vps/master/shell/install_ss_expect.sh
chmod +x install_ss_expect.sh
./install_ss_expect.sh
mkdir -p /usr/local/caddy/www/file
cd /usr/local/caddy/www/file
dd if=/dev/urandom of=test bs=100M count=1 iflag=fullblock
reboot
