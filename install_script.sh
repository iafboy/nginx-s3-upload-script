#!/bin/bash
apt-get update 
apt install build-essential
apt-get install -y wget tar gcc libpcre3-dev zlib1g-dev make libssl-dev 

cd /tmp
git clone https://github.com/jamescmartinez/nginx-s3-upload.git

cd /tmp
wget https://www.lua.org/ftp/lua-5.4.6.tar.gz
tar -zxvf lua-5.4.6.tar.gz
cd /tmp/lua-5.4.6
make linux test
make install

# Download Nginx
cd /tmp
#wget http://nginx.org/download/nginx-1.17.0.tar.gz -O nginx.tar.gz
wget https://nginx.org/download/nginx-1.25.4.tar.gz -O nginx.tar.gz
mkdir /tmp/nginx
tar xf nginx.tar.gz -C nginx --strip-components=1
cd /tmp
# Download Nginx modules
wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.3.tar.gz -O ngx_devel_kit.tar.gz 
mkdir /tmp/ngx_devel_kit
tar xf ngx_devel_kit.tar.gz -C /tmp/ngx_devel_kit --strip-components=1
wget https://github.com/openresty/set-misc-nginx-module/archive/v0.33.tar.gz -O set-misc-nginx-module.tar.gz 
mkdir /tmp/set-misc-nginx-module
tar xf set-misc-nginx-module.tar.gz -C /tmp/set-misc-nginx-module --strip-components=1
wget https://github.com/openresty/lua-nginx-module/archive/v0.10.26.tar.gz -O lua-nginx-module.tar.gz
mkdir /tmp/lua-nginx-module
tar xf lua-nginx-module.tar.gz -C /tmp/lua-nginx-module --strip-components=1
cd /tmp
git clone https://luajit.org/git/luajit.git
cd /tmp/luajit
make && sudo make install

export LUAJIT_LIB=/usr/local/lib
export LUAJIT_INC=/usr/local/include/luajit-2.1

cd /tmp/nginx
./configure --sbin-path=/usr/local/sbin \
                --conf-path=/etc/nginx/nginx.conf \
                --pid-path=/var/run/nginx.pid \
                --error-log-path=/var/log/nginx/error.log \
                --http-log-path=/var/log/nginx/access.log \
                --with-http_ssl_module \
                --add-module=/tmp/ngx_devel_kit \
                --add-module=/tmp/set-misc-nginx-module \
                --add-module=/tmp/lua-nginx-module 
make 
make install

# Apply Nginx config
cp /tmp/nginx-s3-upload/config/nginx.conf /etc/nginx/nginx.conf
nginx -C /etc/nginx/nginx.conf
