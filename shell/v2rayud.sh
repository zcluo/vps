#!/bin/bash
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
systemctl stop v2ray
systemctl disable v2ray
systemctl restart rc-local
