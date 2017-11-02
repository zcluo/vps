#!/bin/bash
yum install -y python-ipaddr
wget http://soft.vpser.net/security/denyhosts/denyhosts-3.1.tar.gz
tar -zxvf denyhosts-3.1.tar.gz
cd denyhosts-3.1
python setup.py install
cp /usr/bin/daemon-control-dist /usr/bin/daemon-control
echo "daemon-control start" >> /etc/rc.local
chmod +x /etc/rc.d/rc.local
sed -e '14c DENYHOSTS_BIN   = "/usr/bin/denyhosts.py"' /usr/bin/daemon-control > /usr/bin/daemon-control.new
\mv /usr/bin/daemon-control /usr/bin/daemon-control.bak
\mv  /usr/bin/daemon-control.new /usr/bin/daemon-control
chown root /usr/bin/daemon-control
chmod 700 /usr/bin/daemon-control
touch /var/log/auth.log
sed -e '60c PURGE_DENY = 5d' /etc/denyhosts.conf > /etc/denyhosts.conf.new
\mv /etc/denyhosts.conf /etc/denyhosts.conf.bak
\mv /etc/denyhosts.conf.new /etc/denyhosts.conf
sed -e '131c DENY_THRESHOLD_ROOT = 5' /etc/denyhosts.conf > /etc/denyhosts.conf.new
\mv /etc/denyhosts.conf /etc/denyhosts.conf.bak
\mv /etc/denyhosts.conf.new /etc/denyhosts.conf