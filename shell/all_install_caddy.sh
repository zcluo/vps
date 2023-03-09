#!/bin/bash
if [ $# != 5 ] ; then
echo "USAGE: $0 domain_name username password emailaddress uuid"
echo " e.g.: $0 domain_name username password emailaddress uuid"
exit 1;
fi

systemctl stop xray && systemctl disable xray
systemctl stop v2ray && systemctl disable v2ray
#used for uuid replacement
uuid=$(cat /proc/sys/kernel/random/uuid)
echo "$1" "$2" "$3" "$4" "$5"
apt install curl screen net-tools iperf3 ca-certificates git lsof apt-transport-https ca-certificates neofetch unzip  -y
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/caddy_install.sh && chmod +x caddy_install.sh && bash caddy_install.sh install
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/across/master/bbr.sh
>/etc/apt/sources.list.d/caddy-fury.list
echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" |  tee -a /etc/apt/sources.list.d/caddy-fury.list
apt update
apt install caddy
#\rm -f /etc/apt/sources.list.d/caddy-fury.list
\chmod -R 777  /var/log/
wget -N --no-check-certificate https://raw.githubusercontent.com/teddysun/across/master/bbr.sh
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/install_ohmyposh.sh
#mkdir -p /usr/local/caddy/
\mkdir -p /var/log/xray/
\chmod -R 777  /var/log/xray/
# curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
# chmod +x install-release.sh
# bash install-release.sh
# bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh)
curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
chmod +x install-release.sh
bash install-release.sh
sleep 20

#\mkdir -p /etc/caddy/
\rm -rf /usr/local/etc/v2ray/*
\rm -rf /etc/caddy/*
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/Caddyfile -O /etc/caddy/Caddyfile
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/caddy.json -O /etc/caddy/Caddyfile
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/config.json -O /usr/local/etc/v2ray/config.json
sed -e "s/xxx\.xxxxxx\.xxx/$1/g" /etc/caddy/Caddyfile > /etc/caddy/Caddyfile.new
sed -e "s/user/$2/g" /etc/caddy/Caddyfile.new > /etc/caddy/Caddyfile
sed -e "s/pass/$3/g" /etc/caddy/Caddyfile > /etc/caddy/Caddyfile.new
sed -e "s/xxx\@xxx\.xxx/$4/g" /etc/caddy/Caddyfile.new > /etc/caddy/Caddyfile
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/caddy.service -O /lib/systemd/system/caddy.service
sed -e "s/xxx\.xxxxxx\.xxx/$1/g" /usr/local/etc/v2ray/config.json > /usr/local/etc/v2ray/config.json.new
sed -e "s/trojanpass/$3/g" /usr/local/etc/v2ray/config.json.new > /usr/local/etc/v2ray/config.json
sed -e "s/xxx\@xxx\.xxx/$4/g"   /usr/local/etc/v2ray/config.json > /usr/local/etc/v2ray/config.json.new
sed -e "s/xxxxxxxx\-xxxx\-xxxx\-xxxx\-xxxxxxxxxxxx/$5/g"   /usr/local/etc/v2ray/config.json.new > /usr/local/etc/v2ray/config.json
#\mv /etc/caddy/Caddyfile.new  /etc/caddy/Caddyfile
#\mv /usr/local/etc/xray/config.json.new /usr/local/etc/xray/config.json
chmod -x /etc/systemd/system/v2ray.service
systemctl enable caddy && systemctl restart caddy 
sleep 20
cd /var/lib/caddy
chmod -R 755 .local/
#systemctl enable v2ray && systemctl restart v2ray
systemctl disable v2ray
cd ~
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/v2rayud.sh
chmod +x v2rayud.sh
crontab -l > crontab.bak

#echo "0 1 * * * apt update && apt upgrade -y" >> crontab.bak
sed -e '/v2rayud/d' crontab.bak > crontab.bak.new
sed -e '/xrayud/d' crontab.bak.new > crontab.bak
echo "0 1 * * * bash v2rayud.sh" >> crontab.bak
echo "30 3 1 * * service caddy restart" >> crontab.bak
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
# caddy伪装网页
cd ~
mkdir -p /var/www/html
wget  -N --no-check-certificate  https://raw.githubusercontent.com/zcluo/vps/master/shell/html1.zip
unzip -o html1.zip -d /var/www/html

dd if=/dev/urandom of=/var/www/html/test bs=100M count=1 iflag=fullblock
>/etc/rc.local
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
nohup /usr/local/bin/v2ray run -c /usr/local/etc/v2ray/config.json > /var/log/xray/nohup.log 2>&1 &
exit 0
EOF
chmod +x /etc/rc.local
systemctl start rc-local


#增加trojan安装

#apt install build-essential devscripts debhelper cmake libboost-system-dev libboost-program-options-dev libssl-dev default-libmysqlclient-dev python3 curl openssl -y
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"

#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/trojan.cfg -O /usr/local/etc/trojan/config.json
#sed -e "s/xxx\.xxxxxx\.xxx/$1/g" /usr/local/etc/trojan/config.json > /usr/local/etc/trojan/config.json.new
#\mv -f /usr/local/etc/trojan/config.json.new /usr/local/etc/trojan/config.json
#systemctl enable trojan && systemctl restart trojan
#cd
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/snell.sh
#chmod +x snell.sh
#./snell.sh
\chmod -R 777  /var/log/
#reboot
cd ~
#bash install_ohmyposh.sh
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
chmod +x /usr/local/bin/oh-my-posh

mkdir ~/.poshthemes
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
chmod u+rw ~/.poshthemes/*.omp.*
rm ~/.poshthemes/themes.zip
echo 'eval "$(oh-my-posh --init --shell bash --config /root/.poshthemes/1_shell.omp.json)"' >> .bashrc

echo "clear" >> .bashrc
echo "neofetch" >> .bashrc
trap "rm -rf crontab* bbr.sh install-release.sh caddy_install.sh install_bbr_expect.sh all_install.sh install_bbr.log html1.zip xrayud.sh;reboot" EXIT
