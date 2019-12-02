#!/bin/bash
echo "$1"
apt install curl screen net-tools iperf3 -y
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/caddy_install.sh && chmod +x caddy_install.sh && bash caddy_install.sh install
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/across/master/bbr.sh
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

echo "0 1 * * * apt update && apt upgrade -y" >> crontab.bak
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
#apt update && apt -y install git build-essential cmake libboost-system-dev libboost-program-options-dev libssl-dev default-libmysqlclient-dev
#cd
#git clone https://github.com/trojan-gfw/trojan.git
#cd trojan/
#mkdir build
#cd build/
#cmake ..
#make
#ctest
#make install

#mkdir -p /etc/trojan/
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/trojan.cfg -O /etc/trojan/trojan.cfg
#sed -e "s/xxx\.xxxxxx\.xxx/$1/g" /etc/trojan/trojan.cfg > /etc/trojan/trojan.cfg.new
#\mv /etc/trojan/trojan.cfg.new /etc/trojan/trojan.cfg


#sed -i '/exit 0/i nohup trojan -c /etc/trojan/trojan.cfg -l /var/log/trojan.log > trojan.out 2>&1 &' /etc/rc.local

#cd
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/snell.sh
#chmod +x snell.sh
#./snell.sh

reboot
