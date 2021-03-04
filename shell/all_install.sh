#!/bin/bash
echo "$1" "$2" "$3"
apt install curl screen net-tools iperf3 ca-certificates git lsof  -y
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/caddy_install.sh && chmod +x caddy_install.sh && bash caddy_install.sh install
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/across/master/bbr.sh
>/etc/apt/sources.list.d/caddy-fury.list
echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" |  tee -a /etc/apt/sources.list.d/caddy-fury.list
apt update
apt install caddy
#\rm -f /etc/apt/sources.list.d/caddy-fury.list
\chmod -R 777  /var/log/
wget -N --no-check-certificate https://raw.githubusercontent.com/teddysun/across/master/bbr.sh
#mkdir -p /usr/local/caddy/
\mkdir -p /var/log/xray/
\chmod -R 777  /var/log/xray/
# curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
# chmod +x install-release.sh
# bash install-release.sh
# bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh)
curl -O https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh
chmod +x install-release.sh
bash install-release.sh
sleep 20
#\mkdir -p /etc/caddy/
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/Caddyfile -O /etc/caddy/Caddyfile
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/config.json -O /usr/local/etc/xray/config.json
sed -e "s/xxx\.xxxxxx\.xxx/$1/g" /etc/caddy/Caddyfile > /etc/caddy/Caddyfile.new
sed -e "s/user/$2/g" /etc/caddy/Caddyfile.new > /etc/caddy/Caddyfile
sed -e "s/pass/$3/g" /etc/caddy/Caddyfile > /etc/caddy/Caddyfile.new
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/caddy.service -O /lib/systemd/system/caddy.service
sed -e "s/xxx\.xxxxxx\.xxx/$1/g" /usr/local/etc/xray/config.json > /usr/local/etc/xray/config.json.new
sed -e "s/pass/$3/g" /usr/local/etc/xray/config.json.new > /usr/local/etc/xray/config.json.new.new
\mv /etc/caddy/Caddyfile.new  /etc/caddy/Caddyfile
\mv /usr/local/etc/xray/config.json.new.new /usr/local/etc/xray/config.json
chmod -x /etc/systemd/system/xray.service
systemctl enable caddy && systemctl restart caddy 
sleep 20
cd /var/lib/caddy
chmod -R 755 .local/
systemctl enable xray && systemctl restart xray
\rm -rf caddy_install.sh
cd ~
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/xrayud.sh
chmod +x xrayud.sh
crontab -l > crontab.bak

#echo "0 1 * * * apt update && apt upgrade -y" >> crontab.bak
echo "0 1 * * * bash xrayud.sh" >> crontab.bak
crontab crontab.bak
apt install -y expect
wget --no-check-certificate -O install_bbr_expect.sh https://raw.githubusercontent.com/zcluo/vps/master/shell/install_bbr_expect.sh
chmod +x install_bbr_expect.sh
./install_bbr_expect.sh
#wget --no-check-certificate -O shadowsocks-all.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh
#chmod +x shadowsocks-all.sh
#wget --no-check-certificate -O install_ss_expect.sh https://raw.githubusercontent.com/zcluo/vps/master/shell/install_ss_expect.sh
#chmod +x install_ss_expect.sh
#./install_ss_expect.sh
mkdir -p /usr/local/caddy/www/file
cd /usr/local/caddy/www/file
dd if=/dev/urandom of=test bs=100M count=1 iflag=fullblock
cat <<EOF >/etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

exit 0
EOF
chmod +x /etc/rc.local
systemctl start rc-local

#增加trojan安装

apt install build-essential devscripts debhelper cmake libboost-system-dev libboost-program-options-dev libssl-dev default-libmysqlclient-dev python3 curl openssl -y
bash -c "$(curl -fsSL https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"

wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/trojan.cfg -O /usr/local/etc/trojan/config.json
sed -e "s/xxx\.xxxxxx\.xxx/$1/g" /usr/local/etc/trojan/config.json > /usr/local/etc/trojan/config.json.new
\mv -f /usr/local/etc/trojan/config.json.new /usr/local/etc/trojan/config.json
systemctl enable trojan && systemctl restart trojan
#cd
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/snell.sh
#chmod +x snell.sh
#./snell.sh
\chmod -R 777  /var/log/
reboot
