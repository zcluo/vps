#!/bin/bash
apt update && apt upgrade -y
download_url=$(curl --silent "https://api.github.com/repos/v2ray/v2ray-core/releases/latest" |grep browser_download_url|grep v2ray-linux-64.zip|awk -F: '{print $2":"$3}'|sed 's/\"//g' )
wget $download_url
mkdir v2ray
\mv -f v2ray-linux-64.zip* v2ray
cd v2ray
unzip v2ray-linux-64.zip
\cp -f v2ctl v2ray geoip.dat geosite.dat  ~/lede/files/usr/bin/v2ray/
cd ..
\rm -rf v2ray
cd /root/lede
git pull
./scripts/feeds update -a && ./scripts/feeds install -a
make -j3 V=s
