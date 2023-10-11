#!/bin/bash

# Scrit abaixo foi retirado do site abaixo:
# https://verdanadesk.com/como-instalar-glpi-10/

# Atualiza Lista de Pacotes
sudo apt update

# Pacotes Manuputação de arquivos
sudo apt install -y xz-utils bzip2 unzip curl
    
# Instalar dependências no sistema
sudo apt install -y apache2 libapache2-mod-php php-soap php-cas php php-{apcu,cli,common,curl,gd,imap,ldap,mysql,xmlrpc,xml,mbstring,bcmath,intl,zip,redis,bz2}
    
# Resolvendo Problema de Acesso WEB ao Diretório
sudo cat > /etc/apache2/conf-available/verdanadesk.conf << EOF
<Directory "/temp/public/">
    AllowOverride All
    RewriteEngine On
    RewriteCond %%{REQUEST_FILENAME} !-f
    RewriteRule ^(.*)$ index.php [QSA,L]
    Options -Indexes
    Options -Includes -ExecCGI
    Require all granted
 
    <IfModule mod_php7.c>
        php_value max_execution_time 600
        php_value always_populate_raw_post_data -1
    </IfModule>
 
    <IfModule mod_php8.c>
        php_value max_execution_time 600
        php_value always_populate_raw_post_data -1
    </IfModule>
 
</Directory>
EOF
 
# Habilitar o módulo rewrite do apache
sudo a2enmod rewrite
 
# Habilita a configuração criada
sudo a2enconf verdanadesk.conf
 
# Reinicia o servidor web considerando a nova configuração
sudo systemctl restart apache2

# Criar diretório onde o GLPi será instalado
sudo mkdir /var/www/verdanadesk

# Baixar o sistema GLPi
sudo wget -O- https://github.com/glpi-project/glpi/releases/download/10.0.2/glpi-10.0.2.tgz | sudo tar -zxv -C /var/www/verdanadesk/


# Movendo diretórios "files" e "config" para fora do GLPi 
sudo mv /var/www/verdanadesk/glpi/files /var/www/verdanadesk/
sudo mv /var/www/verdanadesk/glpi/config /var/www/verdanadesk/

# Ajustando código do GLPi para o novo local dos diretórios
sudo sed -i 's/\/config/\/..\/config/g' /var/www/verdanadesk/glpi/inc/based_config.php
sudo sed -i 's/\/files/\/..\/files/g' /var/www/verdanadesk/glpi/inc/based_config.php

# Ajustar propriedade de arquivos da aplicação GLPi
sudo chown root:root /var/www/verdanadesk/glpi -Rf
 
# Ajustar propriedade de arquivos files, config e marketplace
sudo chown www-data:www-data /var/www/verdanadesk/files -Rf
sudo chown www-data:www-data /var/www/verdanadesk/config -Rf
sudo chown www-data:www-data /var/www/verdanadesk/glpi/marketplace -Rf
 
# Ajustar permissões gerais
sudo find /var/www/verdanadesk/ -type d -exec chmod 755 {} \;
sudo find /var/www/verdanadesk/ -type f -exec chmod 644 {} \;

# Criando link simbólico para o sistema GLPi dentro do diretório defalt do apache
sudo ln -s /var/www/verdanadesk/glpi /var/www/html/glpi

# Instalando o Serviço MySQL
sudo apt install -y mariadb-server

# Criando base de dados
#sudo mysql -e "create database verdanadesk_glpi character set utf8"
sudo mysql -e "create database ${GLPI_DB_NAME} character set utf8"
 
# Criando usuário
#sudo mysql -e "create user 'verdanatech'@'localhost' identified by '123456'"
sudo mysql -e "create user '${GLPI_DB_USER}'@'${GLPI_DB_SERVER}' identified by '${GLPI_DB_PASS}'"
 
# Dando privilégios ao usuário
#sudo mysql -e "grant all privileges on verdanadesk_glpi.* to 'verdanatech'@'localhost' with grant option";
sudo mysql -e "grant all privileges on ${GLPI_DB_NAME}.* to '${GLPI_DB_USER}'@'${GLPI_DB_SERVER}' with grant option";

#Criando usuário e senha
sudo mysql -e "INSERT INTO glpi_users (name, password, authtype, language) VALUES ('glpi', '0915bd0a5c6e56d8f38ca2b390857d4949073f41', 1, 'pt_BR');"
sudo mysql -e "INSERT INTO glpi_profiles_users (users_id, profiles_id)  SELECT id, 4 from glpi_users WHERE name = 'glpi';"

# Remover arquivo install.php
sudo rm -f  /var/www/verdanadesk/glpi/install/install.php