#!/bin/bash

##### Repositório #####
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb

sudo apt update
sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mariadb-server

##### MariaDB #####
#sudo systemctl start mariadb

##### Ajustes no BD #####

sudo mysql -h${ZABBIX_DB_SERVER} -u${ZABBIX_DB_USER} -p${ZABBIX_DB_PASS} -e "create database ${ZABBIX_DB_NAME} character set utf8mb4 collate utf8mb4_bin"
sudo mysql -h${ZABBIX_DB_SERVER} -u${ZABBIX_DB_USER} -p${ZABBIX_DB_PASS} -e "create user '${ZABBIX_DB_USER}'@'${ZABBIX_DB_SERVER}' identified by '${ZABBIX_DB_PASS}'"
sudo mysql -h${ZABBIX_DB_SERVER} -u${ZABBIX_DB_USER} -p${ZABBIX_DB_PASS} -e "grant all privileges on ${ZABBIX_DB_USER}.* to '${ZABBIX_DB_NAME}'@'${ZABBIX_DB_SERVER}'"
sudo mysql -h${ZABBIX_DB_SERVER} -u${ZABBIX_DB_USER} -p${ZABBIX_DB_PASS} -e "set global log_bin_trust_function_creators = 1"

sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -h${ZABBIX_DB_SERVER} -D${ZABBIX_DB_NAME} -u${ZABBIX_DB_USER} -p${ZABBIX_DB_PASS}

##### Ajuste .conf #####
sudo sed -i 's/DBUser=.*/DBUser=${ZABBIX_DB_USER}/' /etc/zabbix/zabbix_server.conf
sudo sed -i 's/.*DBPassword=.*/DBPassword=${ZABBIX_DB_PASS}/' /etc/zabbix/zabbix_server.conf
sudo sed -i 's/.*DBHost=.*/DBHost=${ZABBIX_DB_SERVER}/' /etc/zabbix/zabbix_server.conf
sudo sed -i 's/.*DBName=.*/DBName=${ZABBIX_DB_NAME}/' /etc/zabbix/zabbix_server.conf
sudo sed -i 's/.*php_value date.timezone Europe.*/php_value date.timezone America\/Sao_Paulo/' /etc/zabbix/apache.conf

##### Serviço #####
sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2
