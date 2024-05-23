#!/bin/bash
systemctl stop smartdns
systemctl disable smartdns
rm -rf /root/smartdns

curl -s https://api.github.com/repos/pymumu/smartdns/releases/latest | grep "browser_download_url.*x86_64-linux-all.tar.gz\"$"| cut -d '"' -f 4 | xargs curl --connect-timeout 5 -fSL -o /root/smartdns.tar.gz



cd /root/
tar xvf smartdns.tar.gz

cd /root/smartdns 
chmod +x ./install
./install -i

mkdir -p /etc/smartdns
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/smartdns.conf -O /etc/smartdns/smartdns.conf
sed -i "s/xxx\.xxxxxx\.xxx/$1/g" /etc/smartdns/smartdns.conf

systemctl enable smartdns
systemctl restart smartdns
