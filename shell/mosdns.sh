#!/bin/bash
systemctl stop mosdns
systemctl disable mosdns
rm -rf /root/mosdns
mkdir -p /root/mosdns
curl -s https://api.github.com/repos/IrineSistiana/mosdns/releases/latest | grep "browser_download_url.*linux-amd64.zip\"$" | cut -d '"' -f 4 | xargs curl --connect-timeout 5 -fSL -o /root/mosdns/mosdns-linux-amd64.zip
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/mosdns.yaml -O /root/mosdns/mosdns.yaml
sed -i "s/xxx\.xxxxxx\.xxx/$1/g" /root/mosdns/mosdns.yaml
cd /root/mosdns
unzip mosdns-linux-amd64.zip
chmod +x mosdns
./mosdns service install -d /root/mosdns -c /root/mosdns/mosdns.yaml
systemctl enable mosdns
systemctl restart mosdns
