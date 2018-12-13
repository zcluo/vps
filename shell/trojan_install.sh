#!/bin/bash
echo "$1"
apt update && apt -y install build-essential cmake libboost-system-dev libboost-program-options-dev libssl-dev default-libmysqlclient-dev
cd
git clone https://github.com/trojan-gfw/trojan.git
cd trojan/
mkdir build
cd build/
cmake ..
make
ctest
make install

mkdir -p /etc/trojan/
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/trojan.cfg -O /etc/trojan/trojan.cfg
sed -e "s/xxx\.xxxxxx\.xxx/$1/g" /etc/trojan/trojan.cfg > /etc/trojan/trojan.cfg.new
\mv /etc/trojan/trojan.cfg.new /etc/trojan/trojan.cfg


sed -i '/exit 0/i nohup trojan -c /etc/trojan/trojan.cfg -l /var/log/trojan.log > trojan.out 2>&1 &' /etc/rc.local

reboot
