#!/bin/bash
echo "$1" "$2" "$3"
apt install curl screen net-tools iperf3 ca-certificates git lsof  -y
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/caddy_install.sh && chmod +x caddy_install.sh && bash caddy_install.sh install
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/across/master/bbr.sh
echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" |  tee -a /etc/apt/sources.list.d/caddy-fury.list
apt update
apt install caddy
SYSTEM_ARCH="$(uname -m)"
SYSTEM_ARCH="${SYSTEM_ARCH/x86_64/amd64}"
GO_LATEST_VER="$(curl -sL --retry "5" --retry-delay "3" "https://github.com/golang/go/releases" | grep -Eo "go1\.14\.[0-9]+" | sed -n "1p")"
GO_LATEST_VER="${GO_LATEST_VER:-go1.14.10}"
curl --retry "5" --retry-delay "3" -L "https://golang.org/dl/${GO_LATEST_VER}.linux-${SYSTEM_ARCH}.tar.gz" -o "golang.${GO_LATEST_VER}.tar.gz"
tar -zxf "golang.${GO_LATEST_VER}.tar.gz"
rm -f "golang.${GO_LATEST_VER}.tar.gz"
[ ! -f "./go/bin/go" ] && { __error_msg "Failed to download go binary."; popd; rm -rf "${INSTALL_TEMP_DIR}"; exit 1; }
PATH="$PWD/go/bin:$PATH"
export GOROOT="$PWD/go"
export GOTOOLDIR="$PWD/go/pkg/tool/linux_amd64"
export GOBIN="$PWD/gopath/bin"
export GOCACHE="$PWD/go-cache"
export GOPATH="$PWD/gopath"
export GOMODCACHE="$GOPATH/pkg/mod"
go get -u "github.com/caddyserver/xcaddy/cmd/xcaddy"
"${GOBIN}/xcaddy" build --with "github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive"
mv -f ~/caddy /usr/bin/
\chmod -R 777  /var/log/
wget -N --no-check-certificate https://raw.githubusercontent.com/teddysun/across/master/bbr.sh
#mkdir -p /usr/local/caddy/
\mkdir -p /var/log/v2ray/
\chmod -R 777  /var/log/v2ray/
curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
chmod +x install-release.sh
bash install-release.sh
sleep 20
#\mkdir -p /etc/caddy/
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/Caddyfile -O /etc/caddy/Caddyfile
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/config.json -O /usr/local/etc/v2ray/config.json
sed -e "s/xxx\.xxxxxx\.xxx/$1/g" /etc/caddy/Caddyfile > /etc/caddy/Caddyfile.new
sed -e "s/user/$2/g" /etc/caddy/Caddyfile.new > /etc/caddy/Caddyfile
sed -e "s/pass/$3/g" /etc/caddy/Caddyfile > /etc/caddy/Caddyfile.new
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/caddy.service -O /lib/systemd/system/caddy.service
sed -e "s/xxx\.xxxxxx\.xxx/$1/g" /usr/local/etc/v2ray/config.json > /usr/local/etc/v2ray/config.json.new
\mv /etc/caddy/Caddyfile.new  /etc/caddy/Caddyfile
\mv /usr/local/etc/v2ray/config.json.new /usr/local/etc/v2ray/config.json
chmod -x /etc/systemd/system/v2ray.service
systemctl enable caddy &&  systemctl enable v2ray && systemctl restart caddy && systemctl restart v2ray
\rm -rf caddy_install.sh
wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/v2rayud.sh
chmod +x v2rayud.sh
crontab -l > crontab.bak

echo "0 1 * * * apt update && apt upgrade -y" >> crontab.bak
echo "0 1 * * * bash v2rayud.sh" >> crontab.bak
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
\mv /usr/local/etc/trojan/config.json.new /usr/local/etc/trojan/config.json
systemctl enable trojan && systemctl restart trojan
#cd
#wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/snell.sh
#chmod +x snell.sh
#./snell.sh

reboot
