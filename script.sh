#!/bin/bash

yum install mc nano lynx epel-release mailx -y
yum install nginx -y
systemctl start nginx
systemctl enable nginx

echo "0 */1 * * * /opt/myscript.sh" >> /etc/crontab
cp /vagrant/myscript.sh /opt
chmod +x /opt/myscript.sh

# Если нужны данные для тестирования, раскомментировать:
#/vagrant/access.log_tmp /var/log/nginx/access.log