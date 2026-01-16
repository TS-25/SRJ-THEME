#!/bin/bash
# ==================================================
# PTERODACTYL PANEL AUTO INSTALLER
# Clean UI • One Page • Production Ready
# ==================================================

# ---------------- UI THEME ----------------
C_RESET="\e[0m"
C_RED="\e[1;31m"
C_GREEN="\e[1;32m"
C_YELLOW="\e[1;33m"
C_BLUE="\e[1;34m"
C_PURPLE="\e[1;35m"
C_CYAN="\e[1;36m"
C_WHITE="\e[1;37m"
C_GRAY="\e[1;90m"

line(){ echo -e "${C_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"; }
step(){ echo -e "${C_BLUE}➜ $1${C_RESET}"; }
ok(){ echo -e "${C_GREEN}✔ $1${C_RESET}"; }
warn(){ echo -e "${C_YELLOW}⚠ $1${C_RESET}"; }

banner(){
clear
echo -e "${C_CYAN}"
cat << "EOF"
ooooooooo.                          o8o                          .               oooo  
`888   `Y88.                        `"'                        .o8               `888  
 888   .d88'  .ooooo.  oooo    ooo oooo   .oooo.    .ooooo.  .o888oo oooo    ooo  888  
 888ooo88P'  d88' `88b  `88.  .8'  `888  `P  )88b  d88' `"Y8   888    `88.  .8'   888  
 888`88b.    888ooo888   `88..8'    888   .oP"888  888         888     `88..8'    888  
 888  `88b.  888    .o    `888'     888  d8(  888  888   .o8   888 .    `888'     888  
o888o  o888o `Y8bod8P'     `8'     o888o `Y888""8o `Y8bod8P'   "888"     .8'     o888o 
                                                                     .o..P'            
                                                                     `Y8P'             
                                                                     
        reviactyl PANEL INSTALLER
EOF
echo -e "${C_RESET}"
line
echo -e "${C_GREEN}⚡ Fast • Stable • Production Ready${C_RESET}"
line
}

# ---------------- START ----------------
banner
read -p "🌐 Enter domain (panel.example.com): " DOMAIN

# --- Dependencies ---
apt update && apt install -y curl apt-transport-https ca-certificates gnupg unzip git tar sudo lsb-release

# Detect OS
OS=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

if [[ "$OS" == "ubuntu" ]]; then
    echo "✅ Detected Ubuntu. Adding PPA for PHP..."
    apt install -y software-properties-common
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
elif [[ "$OS" == "debian" ]]; then
    echo "✅ Detected Debian. Skipping PPA and adding PHP repo manually..."
    # Add SURY PHP repo for Debian
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury-php.gpg
    echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/sury-php.list
fi

# Add Redis GPG key and repo
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

apt update

# --- Install PHP + extensions ---
apt install -y php8.3 php8.3-{cli,fpm,common,mysql,mbstring,bcmath,xml,zip,curl,gd,tokenizer,ctype,simplexml,dom} mariadb-server nginx redis-server

# --- Install Composer ---
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# --- Download Pterodactyl Panel ---
mkdir -p /var/www/reviactyl
cd /var/www/reviactyl
curl -Lo panel.tar.gz https://github.com/reviactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/

# --- MariaDB Setup ---
DB_NAME=reviactyl
DB_USER=reviactyl
DB_PASS=reviactyl
mariadb -e "CREATE USER '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';"
mariadb -e "CREATE DATABASE ${DB_NAME};"
mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1' WITH GRANT OPTION;"
mariadb -e "FLUSH PRIVILEGES;"

# --- .env Setup ---

cp .env.example .env
sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|g" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_NAME}|g" .env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USER}|g" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|g" .env
if ! grep -q "^APP_ENVIRONMENT_ONLY=" .env; then
    echo "APP_ENVIRONMENT_ONLY=false" >> .env
fi

# --- Install PHP dependencies ---
echo "✅ Installing PHP dependencies..."
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader

# --- Generate Application Key ---
echo "✅ Generating application key..."
sed -i "s|^APP_KEY=.*|APP_KEY=$(php -r "echo 'base64:'.base64_encode(random_bytes(32));")|" .env

# --- Run Migrations ---
php artisan migrate --seed --force

# --- Permissions ---
chown -R www-data:www-data /var/www/reviactyl/*
apt install -y cron
systemctl enable --now cron
(crontab -l 2>/dev/null; echo "* * * * * php /var/www/reviactyl/artisan schedule:run >> /dev/null 2>&1") | crontab -
# --- Nginx Setup ---
mkdir -p /etc/certs/reviactyl
cd /etc/certs/reviactyl
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
-subj "/C=NA/ST=NA/L=NA/O=NA/CN=Generic SSL Certificate" \
-keyout privkey.pem -out fullchain.pem

tee /etc/nginx/sites-available/reviactyl.conf > /dev/null << EOF
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    root /var/www/reviactyl/public;
    index index.php;

    ssl_certificate /etc/certs/reviactyl/fullchain.pem;
    ssl_certificate_key /etc/certs/reviactyl/privkey.pem;

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_index index.php;
        include /etc/nginx/fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize=100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -s /etc/nginx/sites-available/reviactyl.conf /etc/nginx/sites-enabled/reviactyl.conf || true
nginx -t && systemctl restart nginx
ok "Nginx online"

# --- Queue Worker ---
tee /etc/systemd/system/reviq.service > /dev/null << 'EOF'
[Unit]
Description=Reviactyl Queue Worker
After=redis-server.service
[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/reviactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now redis-server
systemctl enable --now reviq.service
ok "Queue running"
clear
step "Create admin user"
# --- Admin User ---
cd /var/www/reviactyl
sed -i '/^APP_ENVIRONMENT_ONLY=/d' .env
echo "APP_ENVIRONMENT_ONLY=false" >> .env
php artisan p:user:make

# ---------------- DONE ----------------
line
echo -e "${C_GREEN}🎉 INSTALLATION COMPLETED SUCCESSFULLY${C_RESET}"
line
echo -e "${C_CYAN}🌐 Panel URL    : ${C_WHITE}https://${DOMAIN}${C_RESET}"
echo -e "${C_CYAN}🗄 DB User      : ${C_WHITE}${DB_USER}${C_RESET}"
echo -e "${C_CYAN}🔑 DB Password  : ${C_WHITE}${DB_PASS}${C_RESET}"
line
echo -e "${C_PURPLE}🚀 Panel live. Control the servers.${C_RESET}"
line
