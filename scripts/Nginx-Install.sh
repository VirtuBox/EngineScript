#!/usr/bin/env bash
#----------------------------------------------------------------------------
# EngineScript - High Performance LEMP WordPress Server Installation Tool
#----------------------------------------------------------------------------
# Website:     https://EngineScript.com
# GitHub:      https://github.com/VisiStruct/EngineScript
# Issues:      https://github.com/VisiStruct/EngineScript/issues
#
# Author:      VisiStruct
# Hire Us:     https://VisiStruct.com
# Based On:    https://github.com/VisiStruct/WordPress-LEMP-Server-Ubuntu
# License:     GPL v3.0
# OS:          Ubuntu 16.04 Xenial & Ubuntu 18.04 Biotic
#----------------------------------------------------------------------------

## Variables
source /usr/lib/EngineScript/misc/variables/variables

# Check current users ID. If user is not 0 (root), exit.
if [ "${EUID}" != 0 ];
  then
    echo "EngineScript should be executed as the root user."
    exit
fi

#----------------------------------------------------------------------------
# Main Script Start

# Nginx Source Downloads
cd /usr/src/
sudo wget https://nginx.org/download/nginx-${NGINX_VER}.tar.gz && sudo tar -xzvf nginx-${NGINX_VER}.tar.gz
sudo wget https://github.com/openresty/headers-more-nginx-module/archive/v${NGINX_HEADER_VER}.tar.gz && sudo tar -xzf v${NGINX_HEADER_VER}.tar.gz
sudo wget https://github.com/nginx-modules/ngx_cache_purge/archive/${NGINX_PURGE_VER}.tar.gz && sudo tar -xzf ${NGINX_PURGE_VER}.tar.gz
sudo wget https://www.openssl.org/source/openssl-${OPENSSL_VER}.tar.gz && sudo tar -xzf openssl-${OPENSSL_VER}.tar.gz
sudo wget https://www.zlib.net/zlib-${ZLIB_VER}.tar.gz && sudo tar xzvf zlib-${ZLIB_VER}.tar.gz

# Brotli
sudo rm -rf /usr/src/ngx_brotli
cd /usr/src
sudo git clone https://github.com/eustas/ngx_brotli.git
cd /usr/src/ngx_brotli
sudo git submodule update --init --recursive

# Patch Nginx and OpenSSL
# These patches will change based on Nginx release. Don't assume they will always work with a new release.
cd /usr/src/nginx-${NGINX_VER}
sudo curl https://raw.githubusercontent.com/nginx-modules/ngx_http_tls_dyn_size/master/nginx__dynamic_tls_records_1.15.5%2B.patch | patch -p1
sudo curl https://raw.githubusercontent.com/centminmod/centminmod/123.09beta01/patches/cloudflare/nginx-1.15.3_http2-hpack.patch | patch -p1
sudo curl https://raw.githubusercontent.com/kn007/patch/master/nginx_auto_using_PRIORITIZE_CHACHA.patch | patch -p1
cd /usr/src/openssl-${OPENSSL_VER}
sudo curl https://raw.githubusercontent.com/hakasenyang/openssl-patch/master/openssl-equal-1.1.1.patch | patch -p1
sudo curl https://raw.githubusercontent.com/centminmod/centminmod/master/patches/openssl/OpenSSL-1.1.1-reset-tls1.3-ciphers-SSL_CTX_set_ssl_version.patch | patch -p1
sudo curl https://raw.githubusercontent.com/centminmod/centminmod/master/patches/openssl/OpenSSL-1.1.1-sni-fix-delay-sig-algs.patch | patch -p1

# Compile Nginx
cd /usr/src/nginx-${NGINX_VER}
sudo ./configure \
  --with-cc-opt='-m64 -O3 -g -march=native -mtune=native -fcode-hoisting -flto -fstack-protector-strong -fuse-ld=gold -Werror=format-security -Wformat -Wimplicit-fallthrough=0 -Wno-cast-function-type -Wno-deprecated-declarations -Wno-error=strict-aliasing --param=ssp-buffer-size=4 -Wp,-D_FORTIFY_SOURCE=2' \
  --with-ld-opt='-ljemalloc -Wl,-z,relro -Wl,--as-needed' \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --http-client-body-temp-path=/var/lib/nginx/body \
  --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
  --http-log-path=/var/log/nginx/access.log \
  --http-proxy-temp-path=/var/lib/nginx/proxy \
  --lock-path=/var/lock/nginx.lock \
  --modules-path=/usr/lib/nginx/modules \
  --pid-path=/var/run/nginx.pid \
  --prefix=/usr/local/nginx \
  --sbin-path=/usr/sbin/nginx \
  --build=nginx-enginescript \
  --group=www-data \
  --user=www-data \
  --add-module=/usr/src/headers-more-nginx-module-${NGINX_HEADER_VER} \
  --add-module=/usr/src/ngx_brotli \
  --add-module=/usr/src/ngx_cache_purge-${NGINX_PURGE_VER} \
  --without-http_browser_module \
  --without-http_empty_gif_module \
  --without-http_memcached_module \
  --without-http_scgi_module \
  --without-http_split_clients_module \
  --without-http_ssi_module \
  --without-http_userid_module \
  --without-http_uwsgi_module \
  --without-mail_imap_module \
  --without-mail_pop3_module \
  --without-mail_smtp_module \
  --with-file-aio \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_realip_module \
  --with-http_ssl_module \
  --with-http_v2_hpack_enc \
  --with-http_v2_module \
  --with-libatomic \
  --with-openssl=/usr/src/openssl-${OPENSSL_VER} \
  --with-openssl-opt='enable-ec_nistp_64_gcc_128 enable-tls1_3 no-nextprotoneg no-psk no-srp no-ssl2 no-ssl3 no-weak-ssl-ciphers zlib -ljemalloc -march=native -Wl,-flto' \
  --with-pcre-jit \
  --with-threads \
  --with-zlib=/usr/src/zlib-cf

sudo make -j ${CPU_COUNT}
sudo make install

# Remove .default Files
sudo rm -rf /etc/nginx/*.default

# Nginx Service Start Dance
sudo rm -rf /lib/systemd/system/nginx.service
sudo cat <<EOT >> /lib/systemd/system/nginx.service
  # Stop dance for nginx
  # =======================
  #
  # ExecStop sends SIGSTOP (graceful stop) to the nginx process.
  # If, after 5s (--retry QUIT/5) nginx is still running, systemd takes control
  # and sends SIGTERM (fast shutdown) to the main process.
  # After another 5s (TimeoutStopSec=5), and if nginx is alive, systemd sends
  # SIGKILL to all the remaining processes in the process group (KillMode=mixed).
  #
  # nginx signals reference doc:
  # https://nginx.org/en/docs/control.html
  #
  [Unit]
  Description=A high performance web server and a reverse proxy server
  After=network.target

  [Service]
  Type=forking
  PIDFile=/run/nginx.pid
  ExecStartPre=/usr/sbin/nginx -t -q -g 'daemon on; master_process on;'
  ExecStart=/usr/sbin/nginx -g 'daemon on; master_process on;'
  ExecReload=/usr/sbin/nginx -g 'daemon on; master_process on;' -s reload
  ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /var/run/nginx.pid
  TimeoutStopSec=5
  KillMode=mixed

  [Install]
  WantedBy=multi-user.target
EOT

# Create Nginx Directories
sudo mkdir -p /etc/nginx/conf.d
sudo mkdir -p /etc/nginx/globals
sudo mkdir -p /etc/nginx/scripts
sudo mkdir -p /etc/nginx/sites-available
sudo mkdir -p /etc/nginx/sites-enabled
sudo mkdir -p /etc/nginx/ssl
sudo mkdir -p /etc/nginx/ssl/cloudflare
sudo mkdir -p /usr/lib/nginx/modules
sudo mkdir -p /var/cache/nginx
sudo mkdir -p /var/lib/nginx/body
sudo mkdir -p /var/lib/nginx/fastcgi
sudo mkdir -p /var/lib/nginx/proxy
sudo mkdir -p /var/log/domains
sudo mkdir -p /var/www/admin/tools
sudo mkdir -p /var/www/error

# Assign Nginx Log Permissions
sudo chown -hR www-data:www-data /var/log/domains

# Custom Error Pages
sudo rm -rf /var/www/error
sudo git clone https://github.com/alexphelps/server-error-pages.git /var/www/error

# EngineScript Nginx .conf Files
echo ""
echo ""
echo "Backing up existing nginx.conf. Backups can be found in /home/EngineScript/user-data/config-backups/nginx"
sudo cp -r /etc/nginx/nginx.conf /home/EngineScript/user-data/config-backups/nginx/
sudo cp -r /etc/nginx/globals /home/EngineScript/user-data/config-backups/nginx/
sleep 3

# Retrieve EngineScript Nginx .conf Files
sudo wget https://raw.githubusercontent.com/VisiStruct/EngineScript/master/nginx/nginx.conf -O /etc/nginx/nginx.conf
sudo wget https://raw.githubusercontent.com/VisiStruct/EngineScript/master/nginx/conf.d/default.conf -O /etc/nginx/conf.d/default.conf
sudo wget https://raw.githubusercontent.com/VisiStruct/EngineScript/master/nginx/globals/errorpages.conf -O /etc/nginx/globals/errorpages.conf
sudo wget https://raw.githubusercontent.com/VisiStruct/EngineScript/master/nginx/globals/fileheaders.conf -O /etc/nginx/globals/fileheaders.conf
sudo wget https://raw.githubusercontent.com/VisiStruct/EngineScript/master/nginx/globals/phpwpcommon.conf -O /etc/nginx/globals/phpwpcommon.conf
sudo wget https://raw.githubusercontent.com/VisiStruct/EngineScript/master/nginx/globals/wpsecurity.conf -O /etc/nginx/globals/wpsecurity.conf
sudo wget https://raw.githubusercontent.com/VisiStruct/EngineScript/master/logrotate/nginx -O /etc/logrotate.d/nginx

# Cloudflare
# Run Cloudflare Script and Write .conf File
sudo wget https://raw.githubusercontent.com/VisiStruct/EngineScript/master/nginx/scripts/cloudflare-nginx-ip-updater.sh -P /etc/nginx/scripts
sudo chmod x /etc/nginx/scripts/cloudflare-nginx-ip-updater.sh
sudo bash /etc/nginx/scripts/cloudflare-nginx-ip-updater.sh

# Retrieve Cloudflare Origin Pull Cert
sudo wget -O /etc/nginx/ssl/cloudflare/origin-pull-ca.pem https://support.cloudflare.com/hc/en-us/article_attachments/201243967/origin-pull-ca.pem

# Create Cron Jobs
sudo cat > /etc/cron.monthly/cfipopc.sh <<EOF
#!/usr/bin/env bash

sudo wget -O /etc/nginx/ssl/cloudflare/origin-pull-ca.pem https://support.cloudflare.com/hc/en-us/article_attachments/201243967/origin-pull-ca.pem
sudo bash /etc/nginx/scripts/cloudflare-nginx-ip-updater.sh
EOF

# Cloudflare Origin Pull Certificate
echo ""
echo ""
echo "Please note, Cloudflare's Origin Pull Certificate has an expiration date."
echo "We've set a monthly cronjob to retrive the latest certificate."
echo ""
echo "Current Certificate expiration:"
echo "$(openssl x509 -startdate -enddate -noout -in /etc/nginx/ssl/cloudflare/origin-pull-ca.pem)"
echo ""
echo ""
sleep 5

# SSL DHParam
cd /etc/nginx/ssl
sudo openssl dhparam -dsaparam -out dhparam.pem 2048

# Start Nginx Service
sudo systemctl enable nginx.service
sudo systemctl start nginx.service

echo ""
echo "============================================================="
echo ""
echo "        Nginx setup completed."
echo ""
echo "============================================================="
echo ""
sleep 5

# Cleanup
cd /usr/src
rm -rf *.tar.gz*
