#!/bin/bash
apt-get update 
apt install build-essential
apt-get install -y wget tar gcc libpcre3-dev zlib1g-dev make libssl-dev libpcre3-dev libssl-dev perl unzip


cd /tmp
git clone https://github.com/iafboy/nginx-s3-upload-script.git

cd /tmp
wget https://www.lua.org/ftp/lua-5.4.6.tar.gz
tar -zxvf lua-5.4.6.tar.gz
cd /tmp/lua-5.4.6
make linux test
make install

cd /tmp
#wget http://nginx.org/download/nginx-1.17.0.tar.gz -O nginx.tar.gz
wget https://nginx.org/download/nginx-1.25.4.tar.gz -O /tmp/nginx.tar.gz
mkdir /tmp/nginx
tar xf /tmp/nginx.tar.gz -C nginx --strip-components=1
cd /tmp
wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.3.tar.gz -O /tmp/ngx_devel_kit.tar.gz 
mkdir /tmp/ngx_devel_kit
tar xf /tmp/ngx_devel_kit.tar.gz -C /tmp/ngx_devel_kit --strip-components=1
wget https://github.com/openresty/set-misc-nginx-module/archive/v0.33.tar.gz -O /tmp/set-misc-nginx-module.tar.gz 
mkdir /tmp/set-misc-nginx-module
tar xf /tmp/set-misc-nginx-module.tar.gz -C /tmp/set-misc-nginx-module --strip-components=1
wget https://github.com/openresty/lua-nginx-module/archive/v0.10.26.tar.gz -O /tmp/lua-nginx-module.tar.gz
mkdir /tmp/lua-nginx-module
tar xf /tmp/lua-nginx-module.tar.gz -C /tmp/lua-nginx-module --strip-components=1
cd /tmp


apt-get -y install --no-install-recommends wget gnupg ca-certificates lsb-release
wget -O - https://openresty.org/package/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/openresty.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] http://openresty.org/package/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/openresty.list > /dev/null
apt-get update
apt-get -y install openresty

wget https://github.com/openresty/luajit2/archive/refs/tags/v2.1-20240314.tar.gz -O luajit.tar.gz
mkdir /tmp/luajit
tar xf /tmp/luajit.tar.gz -C /tmp/luajit --strip-components=1
cd /tmp/luajit
make &&  make install

export LUAJIT_LIB=/usr/local/lib
export LUAJIT_INC=/usr/local/include/luajit-2.1
echo "/usr/local/lib" >>/etc/ld.so.conf
/sbin/ldconfig
#ln -s /usr/local/openresty/lualib /usr/local/lib/lua
#ln -s /usr/local/openresty/lualib/resty /usr/local/lib

cd /tmp 
wget https://github.com/openresty/lua-resty-core/archive/refs/tags/v0.1.28.tar.gz -O lua-resty-core.tar.gz
mkdir /tmp/lua-resty-core
tar xf /tmp/lua-resty-core.tar.gz -C /tmp/lua-resty-core --strip-components=1
cd /tmp/lua-resty-core
make install PREFIX=/opt/nginx

cd /tmp
wget https://github.com/openresty/lua-resty-lrucache/archive/refs/tags/v0.13.tar.gz -O lua-resty-lrucache.tar.gz
mkdir /tmp/lua-resty-lrucache
tar xf /tmp/lua-resty-lrucache.tar.gz -C /tmp/lua-resty-lrucache --strip-components=1
cd /tmp/lua-resty-lrucache
make install PREFIX=/opt/nginx

cp /tmp/nginx-s3-upload-script/nginx.conf /etc/nginx/nginx.conf

cd /tmp/nginx
./configure --prefix=/opt/nginx \
                --conf-path=/etc/nginx/nginx.conf \
                --pid-path=/var/run/nginx.pid \
                --error-log-path=/var/log/nginx/error.log \
                --http-log-path=/var/log/nginx/access.log \
                --with-ld-opt="-Wl,-rpath,/usr/local/lib" \
                --with-http_ssl_module \
                --with-pcre \
                --with-stream \
                --add-module=/tmp/ngx_devel_kit \
                --add-module=/tmp/set-misc-nginx-module \
                --add-module=/tmp/lua-nginx-module 


make -j2
make install

/opt/nginx/sbin/nginx -c /etc/nginx/nginx.conf

cd /tmp
git clone https://github.com/ledgetech/lua-resty-http
cp /tmp/cd lua-resty-http/lib/resty/* /usr/local/openresty/lualib/resty/
git clone https://github.com/jkeys089/lua-resty-hmac.git
cp /tmp/lua-resty-hmac/lib/resty/* /usr/local/openresty/lualib/resty/

cp -R  /usr/local/openresty/lualib/resty/* /opt/nginx/lib/lua/resty/
/opt/nginx/sbin/nginx -t -c /etc/nginx/nginx.conf
