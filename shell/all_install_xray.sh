#!/bin/bash
if [ $# != 9 ] ; then
echo "USAGE: $0 domain_name username password emailaddress uuid realityprivkey grpc_port tcp_port xhttp_port"
echo " e.g.: $0 domain_name username password emailaddress uuid realityprivkey  grpc_port tcp_port xhttp_port"
exit 1;
fi

systemctl stop xray && systemctl disable xray
systemctl stop v2ray && systemctl disable v2ray
ps -ef | grep v2ray | grep -v grep | awk {'print $2'} | xargs kill -9

#used for uuid replacement
#uuid=$(cat /proc/sys/kernel/random/uuid)
echo "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"

curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep "browser_download_url.*fastfetch-linux-amd64.deb\"$" | cut -d '"' -f 4 | xargs curl --connect-timeout 5 -fSL -o /root/fastfetch-linux-amd64.deb
dpkg -i /root/fastfetch-linux-amd64.deb

apt install curl screen net-tools iperf3 ca-certificates git lsof apt-transport-https ca-certificates unzip certbot nginx  -y
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/caddy_install.sh && chmod +x caddy_install.sh && bash caddy_install.sh install
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/across/master/bbr.sh
systemctl stop nginx
#\rm -f /etc/apt/sources.list.d/caddy-fury.list
\chmod -R 777  /var/log/
wget -N --no-check-certificate https://raw.githubusercontent.com/teddysun/across/master/bbr.sh
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/install_ohmyposh.sh
#mkdir -p /usr/local/caddy/
\mkdir -p /var/log/xray/
\mkdir -p /var/log/nginx
\chmod -R 777  /var/log/xray/
\chmod -R 777 /var/log/nginx
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install  --beta
#curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
#chmod +x install-release.sh
#bash install-release.sh
sleep 20

#\mkdir -p /etc/caddy/
\rm -rf /usr/local/etc/xray/*


wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/config_xray.json -O /usr/local/etc/xray/config.json
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/nginx-xray-template.conf -O /etc/nginx/nginx.conf



certbot certonly --standalone -d  $1 -m $4 --agree-tos -n
sed -i "s/xxx\.xxxxxx\.xxx/$1/g" /etc/nginx/nginx.conf

#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/caddy.service -O /lib/systemd/system/caddy.service
sed -i "s/xxx\.xxxxxx\.xxx/$1/g" /usr/local/etc/xray/config.json
sed -i "s/trojanpass/$3/g" /usr/local/etc/xray/config.json
sed -i "s/xxx\@xxx\.xxx/$4/g"   /usr/local/etc/xray/config.json
sed -i "s/xxxxxxxx\-xxxx\-xxxx\-xxxx\-xxxxxxxxxxxx/$5/g"   /usr/local/etc/xray/config.json
sed -i "s/realityprivatekey/$6/g"   /usr/local/etc/xray/config.json
sed -i "s/port_grpc/$7/g"   /usr/local/etc/xray/config.json
sed -i "s/port_tcp/$8/g"   /usr/local/etc/xray/config.json
sed -i "s/port_xhttp/$9/g"   /usr/local/etc/xray/config.json


#chmod -x /etc/systemd/system/xray.service
\chmod -R 777 /etc/letsencrypt
sleep 20

systemctl enable xray && systemctl restart xray
#systemctl disable v2ray
cd ~
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/xrayud.sh
chmod +x xrayud.sh
crontab -l > crontab.bak

#echo "0 1 * * * apt update && apt upgrade -y" >> crontab.bak
sed -i '/v2rayud/d' crontab.bak
sed -i '/xrayud/d' crontab.bak
sed -i '/caddy/d' crontab.bak
echo "0 1 * * * bash xrayud.sh" >> crontab.bak
#echo "30 3 1 * * service caddy restart" >> crontab.bak
crontab crontab.bak
apt install -y expect
wget --no-check-certificate -O install_bbr_expect.sh https://raw.githubusercontent.com/zcluo/vps/master/shell/install_bbr_expect.sh
chmod +x install_bbr_expect.sh
./install_bbr_expect.sh

#cd ~
#wget --no-check-certificate -O mosdns.sh https://raw.githubusercontent.com/zcluo/vps/master/shell/mosdns.sh
#chmod +x mosdns.sh
#bash mosdns.sh $1

cd ~
wget --no-check-certificate -O smartdns.sh https://raw.githubusercontent.com/zcluo/vps/master/shell/smartdns.sh
chmod +x smartdns.sh
bash smartdns.sh $1

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
# nohup /usr/local/bin/v2ray run -c /usr/local/etc/v2ray/config.json > /var/log/xray/nohup.log 2>&1 &
exit 0
EOF
chmod +x /etc/rc.local
systemctl start rc-local
systemctl start nginx


\chmod -R 777  /var/log/
#reboot
cd ~
#bash install_ohmyposh.sh
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
chmod +x /usr/local/bin/oh-my-posh

mkdir ~/themes
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/themes/themes.zip
unzip -o ~/themes/themes.zip -d  ~/themes
chmod u+rw ~/themes/*.omp.*
rm ~/themes/themes.zip
echo 'eval "$(oh-my-posh --init --shell bash --config /root/themes/1_shell.omp.json)"' >> .bashrc

echo "clear" >> .bashrc
echo "fastfetch" >> .bashrc
if [ $(cat ~/.bashrc | grep fastfetch |wc -l) -ge 2 ]
then
    a=$(sed -n "$=" ~/.bashrc )
    let b=a-3+1
    sed -i $(($b)),$(($a))d ~/.bashrc
fi
trap "rm -rf smartdns.tar.gz smartdns.sh smartdns fastfetch-linux-amd64.deb crontab* bbr.sh install-release.sh caddy_install.sh install_bbr_expect.sh all_install.sh all_install_xray.sh install_bbr.log html1.zip v2rayud.sh;reboot" EXIT
