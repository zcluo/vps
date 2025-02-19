#!/bin/bash
set -euo pipefail

# 初始化配置
LOG_FILE="/var/log/xray_install.log"
TMP_DIR=$(mktemp -d -t xray-install-XXXXXX)
# trap 'rm -rf "$TMP_DIR"' EXIT
startTime=$(date +%Y%m%d-%H:%M)
cleanup() {
    local exit_status=$?
    if [ $exit_status -eq 0 ]; then
        echo "Start Installed at $startTime successfully!" >>~/install.log
        rm -rf "$TMP_DIR"
        rm -rf smartdns.tar.gz smartdns.sh smartdns fastfetch-linux-amd64.deb crontab* bbr.sh install-release.sh caddy_install.sh install_bbr_expect.sh all_install.sh all_install_xray.sh install_bbr.log html1.zip v2rayud.sh
        reboot
    else
        echo "[DEBUG] 捕获退出信号，状态码: $exit_status"
        echo "Start Installed at $startTime failed!" >> ~/install.log
        rm -rf "$TMP_DIR"
        rm -rf smartdns.tar.gz smartdns.sh smartdns fastfetch-linux-amd64.deb crontab* bbr.sh install-release.sh caddy_install.sh install_bbr_expect.sh all_install.sh all_install_xray.sh install_bbr.log html1.zip v2rayud.sh
        

    fi
    exit $exit_status

    
}
trap cleanup EXIT INT TERM

# 日志记录函数
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 错误处理函数
die() {
  log "错误: $1"
  exit 1
}

# 架构检测
detect_arch() {
  case $(uname -m) in
    x86_64|amd64) ARCH="amd64" ARCH_XRAY="64" ARCH_POSH="amd64" ;;
    aarch64)      ARCH="aarch64" ARCH_XRAY="arm64-v8a" ARCH_POSH="arm64" ;;
    *)            die "不支持的架构: $(uname -m)" ;;
  esac
  log "检测到架构: $ARCH"
}



# 包管理器检测
detect_pkg_mgr() {
  declare -A managers=(
    [apt]="/etc/debian_version"
    [apt]="/etc/os-release"
    [yum]="/etc/redhat-release"
    [dnf]="/etc/fedora-release"
    [dnf]="/etc/almalinux-release"
    [dnf]="/etc/rocky-release"
    [apk]="/etc/alpine-release"
    [zypper]="/etc/SuSE-release"
    [pacman]="/etc/arch-release"
  )

  for mgr in "${!managers[@]}"; do
    if [[ -e ${managers[$mgr]} ]]; then
      PKG_MGR="$mgr"
      break
    fi
  done

  [[ -n "$PKG_MGR" ]] || die "无法检测包管理器"
  log "检测到包管理器: $PKG_MGR"
}

# 安装依赖
install_deps() {
  log "安装系统依赖..."
  case $PKG_MGR in
    apt)
      apt update && apt install -y curl tar gzip jq openssl gnupg2 ca-certificates nginx certbot uuid-runtime
      ;;
    yum|dnf)
      $PKG_MGR install -y curl tar gzip jq openssl ca-certificates nginx certbot
      ;;
    apk)
      apk add --no-cache curl tar gzip jq openssl nginx certbot
      ;;
    zypper)
      zypper in -y curl tar gzip jq openssl ca-certificates nginx certbot
      ;;
    pacman)
      pacman -Sy --noconfirm curl tar gzip jq openssl nginx certbot
      ;;
  esac || die "依赖安装失败"
}

init_logdirs() {
    chmod -R 777 /var/log/
    mkdir -p /var/log/xray/
    mkdir -p /var/log/nginx
    chmod -R 777 /var/log/xray/
    chmod -R 777 /var/log/nginx
}

# 安装Fastfetch
install_fastfetch() {
  local VERSION TAG_URL="https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest"
  
  log "获取Fastfetch最新版本..."
  VERSION=$(curl -sSL "$TAG_URL" | jq -r '.tag_name') || die "获取版本失败"
  
  local URL="https://github.com/fastfetch-cli/fastfetch/releases/download/${VERSION}/fastfetch-linux-${ARCH}.tar.gz"
  
  log "下载Fastfetch: $URL"
  curl -fSL "$URL" -o "$TMP_DIR/fastfetch-linux-${ARCH}.tar.gz" || die "下载失败"
  
  tar -xzf "$TMP_DIR/fastfetch-linux-${ARCH}.tar.gz" -C "$TMP_DIR"
  cp "$TMP_DIR/fastfetch-linux-${ARCH}/usr/bin/fastfetch" /usr/bin && chmod +x /usr/bin/fastfetch
  cp -rf "$TMP_DIR/fastfetch-linux-${ARCH}/usr/share/" /usr/share/
  log "Fastfetch ${VERSION} 安装成功"
}

# 安装Xray核心
install_xray() {
  log "获取Xray最新版本..."
  local TAG_URL="https://api.github.com/repos/XTLS/Xray-core/releases/latest"
  local VERSION=$(curl -sSL "$TAG_URL" | jq -r '.tag_name') || die "获取版本失败"
  
  local URL="https://github.com/XTLS/Xray-core/releases/download/${VERSION}/Xray-linux-${ARCH_XRAY}.zip"
  
  log "下载Xray: $URL"
  curl -fSL "$URL" -o "$TMP_DIR/Xray.zip" || die "下载失败"
  # curl -fSL "${URL}.dgst" -o "$TMP_DIR/Xray.zip.dgst" || die "下载签名失败"
  
  # GPG验证
  # curl -sSL https://raw.githubusercontent.com/XTLS/Xray-core/main/Release/PublicKey/ReleaseKey.pem | gpg --import
  # gpg --verify "$TMP_DIR/Xray.zip.dgst" "$TMP_DIR/Xray.zip" || die "签名验证失败"
  
  # 安装文件
  unzip -q "$TMP_DIR/Xray.zip" -d "$TMP_DIR/xray"
  install -m 755 "$TMP_DIR/xray/xray" /usr/local/bin/
  install -d /usr/local/etc/xray/
  # install -m 644 "$TMP_DIR/xray/*.json" /usr/local/etc/xray/
  
  # 服务配置
  detect_init_system() {
    if [[ -d /run/systemd/system ]]; then
      INIT_SYSTEM="systemd"
    elif [[ -x /sbin/openrc-run ]]; then
      INIT_SYSTEM="openrc"
    elif [[ -f /etc/init.d/cron && -x /usr/sbin/update-rc.d ]]; then
      INIT_SYSTEM="sysvinit"
    else
      die "无法检测初始化系统"
    fi
    log "检测到初始化系统: $INIT_SYSTEM"
  }

  detect_init_system

  case $INIT_SYSTEM in
    systemd)
      cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
After=network.target

[Service]
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
      systemctl daemon-reload
      systemctl enable --now xray
      ;;

    openrc)
      cat > /etc/init.d/xray <<EOF
#!/sbin/openrc-run
name="Xray proxy service"
description="Xray Service"

command="/usr/local/bin/xray"
command_args="run -config /usr/local/etc/xray/config.json"
command_background=true
pidfile="/run/xray.pid"
start_stop_daemon_args="--background --make-pidfile"

depend() {
  after net
}

start() {
  ebegin "Starting \$name"
  start-stop-daemon --start \\
    --exec \$command \\
    -- \$command_args
  eend \$?
}

stop() {
  ebegin "Stopping \$name"
  start-stop-daemon --stop \\
    --exec \$command \\
    --retry 5
  eend \$?
}
EOF
      chmod +x /etc/init.d/xray
      rc-update add xray default
      service xray start
      ;;

    sysvinit)
      cat > /etc/init.d/xray <<EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          xray
# Required-Start:    \$network \$local_fs \$remote_fs
# Required-Stop:     \$network \$local_fs \$remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Xray proxy service
### END INIT INFO

DAEMON=/usr/local/bin/xray
CONFIG=/usr/local/etc/xray/config.json
PIDFILE=/var/run/xray.pid

case "\$1" in
  start)
    echo -n "Starting Xray: "
    start-stop-daemon --start --quiet --background --make-pidfile \\
      --pidfile \$PIDFILE --exec \$DAEMON -- run -config \$CONFIG
    echo "OK"
    ;;
  stop)
    echo -n "Stopping Xray: "
    start-stop-daemon --stop --quiet --pidfile \$PIDFILE --exec \$DAEMON
    echo "OK"
    ;;
  restart)
    \$0 stop
    sleep 1
    \$0 start
    ;;
  *)
    echo "Usage: \$0 {start|stop|restart}"
    exit 1
esac

exit 0
EOF
      chmod +x /etc/init.d/xray
      update-rc.d xray defaults
      service xray start
      ;;
  esac
  
  log "Xray ${VERSION} 安装成功"
}

# 配置生成
generate_config() {
  log "生成配置文件..."
  rm -rf /usr/local/etc/xray/*


  wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/config_xray.json -O /usr/local/etc/xray/config.json
  wget -N --no-check-certificate https://raw.githubusercontent.com/zcluo/vps/master/shell/nginx-xray-template.conf -O /etc/nginx/nginx.conf


 

  log "文件替换..."
  sed -i "s/xxx\.xxxxxx\.xxx/$1/g" /etc/nginx/nginx.conf
  sed -i "s/xxx\.xxxxxx\.xxx/$1/g" /usr/local/etc/xray/config.json
  sed -i "s/trojanpass/$3/g" /usr/local/etc/xray/config.json
  sed -i "s/xxx\@xxx\.xxx/$4/g"   /usr/local/etc/xray/config.json
  sed -i "s/xxxxxxxx\-xxxx\-xxxx\-xxxx\-xxxxxxxxxxxx/$5/g"   /usr/local/etc/xray/config.json
  sed -i "s/realityprivatekey/$6/g"   /usr/local/etc/xray/config.json
  sed -i "s/port_grpc/$7/g"   /usr/local/etc/xray/config.json
  sed -i "s/port_tcp/$8/g"   /usr/local/etc/xray/config.json
  sed -i "s/port_xhttp/$9/g"   /usr/local/etc/xray/config.json

}

install_ohmyposh() {
  cd ~ || exit
  #bash install_ohmyposh.sh
  wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${ARCH_POSH} -O /usr/local/bin/oh-my-posh
  chmod +x /usr/local/bin/oh-my-posh

  mkdir -p ~/themes
  wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/themes/themes.zip
  unzip -o ~/themes/themes.zip -d  ~/themes
  chmod u+rw ~/themes/*.omp.*
  rm ~/themes/themes.zip
}

generate_cron() {
  log "新增更新定时任务..."
  cd ~ || exit
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
}

init_bashrc() {
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
}

restart_service() {
  case $INIT_SYSTEM in
    systemd) systemctl restart xray && systemctl restart nginx ;;
    openrc) rc-service xray restart && rc-service nginx restart ;;
    sysvinit) service xray restart && service nginx restart ;;
  esac
}

apply_cert() {
    certbot certonly --standalone -d "$1" -m "$4" --agree-tos -n
    chmod -R 777 /etc/letsencrypt
}

usage() {
  echo "USAGE: $0 domain_name username password emailaddress uuid realityprivkey grpc_port tcp_port xhttp_port"
  echo " e.g.: $0 abbc.com user_a password aa@abbc.com $(uuidgen) realityprivkey 8001 9001 7001"
}

# 主安装流程
main() {
  usage "$@"
  [[ $# -eq 9 ]] || die "参数数量错误"
  
  log "探测CPU架构..."
  detect_arch
  log "探测安装器..."
  detect_pkg_mgr
  log "初始化日志目录..."
  init_logdirs
  log "安装依赖..."
  install_deps
  log "安装fastfetch..."
  install_fastfetch
  log "安装XRAY..."
  install_xray
  log "生成配置文件..."
  generate_config "$@"
  
  log "证书申请..."
  apply_cert "$@"
  
  log "重启服务..."
  restart_service

  log "安装oh-my-posh..."
  install_ohmyposh

  log "初始化.bashrc..."
  init_bashrc
  
  log "安装完成! "
}

main "$@"
