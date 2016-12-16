FROM nginx:stable

ENV NGINX_VERSION 1.10.2
ENV LAST_UPDATED 20161216

# Update system and install required software
RUN apt-get update &&\
    apt-get install -y wget \
                       curl \
                       git \
                       build-essential \
                       autoconf \
                       libtool \
                       libpcre3 \
                       libpcre3-dev \
                       libssl-dev

# Download MaxMind GeoLite2 databases
RUN mkdir -p /usr/share/GeoIP/ &&\
    wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz &&\
    gunzip GeoLite2-City.mmdb.gz &&\
    mv GeoLite2-City.mmdb /usr/share/GeoIP/ &&\
    wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz &&\
    gunzip GeoLite2-Country.mmdb.gz &&\
    mv GeoLite2-Country.mmdb /usr/share/GeoIP/

# Install C library for reading MaxMind DB files
# Resource: https://github.com/maxmind/libmaxminddb
RUN git clone --recursive https://github.com/maxmind/libmaxminddb.git &&\
    cd libmaxminddb &&\
    ./bootstrap &&\
    ./configure &&\
    make &&\
    make check &&\
    make install &&\
    echo /usr/local/lib  >> /etc/ld.so.conf.d/local.conf &&\
    ldconfig

# On Ubuntu you can use:
# RUN apt-get install -y software-properties-common &&\
#     add-apt-repository ppa:maxmind/ppa &&\
#     apt-get update &&\
#     apt-get install -y libmaxminddb0 libmaxminddb-dev mmdb-bin

# Download Nginx and the Nginx geoip2 module
RUN curl http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar xz &&\
    git clone https://github.com/leev/ngx_http_geoip2_module.git

WORKDIR /nginx-$NGINX_VERSION

# Compile Nginx
RUN ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-file-aio \
    --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' \
    --with-ld-opt='-Wl,-z,relro -Wl,--as-needed' \
    --with-ipv6 \
    --add-module=/ngx_http_geoip2_module &&\
    make &&\
    make install

COPY sample-html /usr/share/nginx/html
COPY config/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY config/geoip2.conf /etc/nginx/conf.d/geoip2.conf

# Out-of-the-box, Nginx doesn't support using environment variables inside most configuration blocks. But envsubst may be used as a workaround if you need to generate your nginx configuration dynamically before nginx starts.
CMD /bin/bash -c "envsubst \\\$PORT < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
