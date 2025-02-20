#!/bin/bash
set -e
startTime=$(date +%Y%m%d-%H:%M)
cleanup() {
    local exit_status=$?
    if [ $exit_status -eq 0 ]; then
        echo "Start Installed at $startTime successfully!" >>~/install.log
        rm -rf smartdns.tar.gz smartdns.sh smartdns fastfetch-linux-amd64.deb crontab* bbr.sh install-release.sh caddy_install.sh install_bbr_expect.sh all_install.sh all_install_xray.sh install_bbr.log html1.zip v2rayud.sh
        reboot
    else
        echo "[DEBUG] 捕获退出信号，状态码: $exit_status"
        echo "Start Installed at $startTime failed!" >> ~/install.log
        rm -rf smartdns.tar.gz smartdns.sh smartdns fastfetch-linux-amd64.deb crontab* bbr.sh install-release.sh caddy_install.sh install_bbr_expect.sh all_install.sh all_install_xray.sh install_bbr.log html1.zip v2rayud.sh
        

    fi
    exit $exit_status

    
}
trap cleanup EXIT INT TERM
if [ $# -ne 9 ]; then
echo "USAGE: $0 domain_name username password emailaddress uuid realityprivkey grpc_port tcp_port xhttp_port"
echo " e.g.: $0 domain_name username password emailaddress uuid realityprivkey  grpc_port tcp_port xhttp_port"
exit 1;
fi

systemctl stop xray && systemctl disable xray
systemctl stop v2ray && systemctl disable v2ray
#ps -ef | grep v2ray | grep -v grep | awk '{print $2}' | xargs kill -9

if pgrep -f v2ray > /dev/null; then
    pgrep -f v2ray|xargs kill -9
fi

#used for uuid replacement
#uuid=$(cat /proc/sys/kernel/random/uuid)
echo "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"

apt install wget curl screen net-tools iperf3 ca-certificates git lsof apt-transport-https ca-certificates unzip certbot nginx  -y

curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep "browser_download_url.*fastfetch-linux-amd64.deb\"$" | cut -d '"' -f 4 | xargs curl --connect-timeout 5 -fSL -o /root/fastfetch-linux-amd64.deb
dpkg -i /root/fastfetch-linux-amd64.deb



systemctl stop nginx

chmod -R 777 /var/log/


mkdir -p /var/log/xray/
mkdir -p /var/log/nginx
chmod -R 777 /var/log/xray/
chmod -R 777 /var/log/nginx
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install  --beta

sleep 20


rm -rf /usr/local/etc/xray/*


wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/config_xray.json -O /usr/local/etc/xray/config.json
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/nginx-xray-template.conf -O /etc/nginx/nginx.conf



certbot certonly --standalone -d  $1 -m $4 --agree-tos -n
sed -i "s/xxx\.xxxxxx\.xxx/$1/g" /etc/nginx/nginx.conf


sed -i "s/xxx\.xxxxxx\.xxx/$1/g" /usr/local/etc/xray/config.json
sed -i "s/trojanpass/$3/g" /usr/local/etc/xray/config.json
sed -i "s/xxx\@xxx\.xxx/$4/g"   /usr/local/etc/xray/config.json
sed -i "s/xxxxxxxx\-xxxx\-xxxx\-xxxx\-xxxxxxxxxxxx/$5/g"   /usr/local/etc/xray/config.json
sed -i "s/realityprivatekey/$6/g"   /usr/local/etc/xray/config.json
sed -i "s/port_grpc/$7/g"   /usr/local/etc/xray/config.json
sed -i "s/port_tcp/$8/g"   /usr/local/etc/xray/config.json
sed -i "s/port_xhttp/$9/g"   /usr/local/etc/xray/config.json



chmod -R 777 /etc/letsencrypt
sleep 20

systemctl enable xray && systemctl restart xray

cd ~ || exit
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/xrayud.sh
chmod +x xrayud.sh

crontab_file="/var/spool/cron/crontabs/$(whoami)"

if [[ -f "$crontab_file" ]]; then
    cp "$crontab_file" crontab.bak
    
else
    echo "" > crontab.bak
fi



sed -i '/v2rayud/d' crontab.bak
sed -i '/xrayud/d' crontab.bak
sed -i '/caddy/d' crontab.bak
echo "0 1 * * * bash xrayud.sh" >> crontab.bak

crontab crontab.bak






# caddy伪装网页
cd ~ || exit
mkdir -p /var/www/html
wget  -N --no-check-certificate  https://raw.githubusercontent.com/zcluo/vps/master/shell/html1.zip
unzip -o html1.zip -d /var/www/html

dd if=/dev/urandom of=/var/www/html/test bs=100M count=1 iflag=fullblock
echo "" >/etc/rc.local
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


chmod -R 777 /var/log/
#reboot
cd ~ || exit
#bash install_ohmyposh.sh
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
chmod +x /usr/local/bin/oh-my-posh

mkdir -p ~/themes
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/themes/themes.zip
unzip -o ~/themes/themes.zip -d  ~/themes
chmod u+rw ~/themes/*.omp.*
rm ~/themes/themes.zip
echo '[ -z "$PS1" ] && return' >> .bashrc
echo 'eval "$(oh-my-posh --init --shell bash --config /root/themes/1_shell.omp.json)"' >> .bashrc
echo "clear" >> .bashrc
echo "fastfetch" >> .bashrc
# 计算包含 "fastfetch" 的行数
fastfetch_count=$(grep -c "fastfetch" ~/.bashrc)

# 判断是否有多余的 "fastfetch" 行
if [ "$fastfetch_count" -ge 2 ]; then
    # 获取文件总行数
    total_lines=$(wc -l < ~/.bashrc)
    
    # 计算需要删除的行范围
    start_line=$((total_lines - 4 + 1))
    end_line=$total_lines
    
    # 删除多余的行
    sed -i "${start_line},${end_line}d" ~/.bashrc
fi
