FROM alpine:3.8 AS base_image

FROM base_image AS build

RUN apk add --no-cache curl build-base openssl openssl-dev zlib-dev linux-headers pcre-dev ffmpeg ffmpeg-dev
RUN mkdir nginx nginx-vts-module

ENV NGINX_VERSION 1.16.0
ENV VTS_MODULE_VERSION v0.1.18

RUN curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C nginx --strip 1 -xz
RUN curl -sL https://github.com/vozlt/nginx-module-vts/archive/${VTS_MODULE_VERSION}.tar.gz  | tar -C nginx-vts-module --strip 1 -xz

WORKDIR nginx
RUN ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
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
    --add-module=../nginx-vts-module \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-compat \
    --with-file-aio \
    --with-http_v2_module \
    --with-cc-opt="-O3"
RUN make
RUN make install

FROM base_image
RUN apk add --no-cache \
    ca-certificates \
    gettext \
    openssl \
    pcre \
    tini

RUN addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx

COPY docker-entrypoint.sh /

COPY --from=build /usr/sbin/nginx /usr/sbin/nginx
COPY --from=build /etc/nginx /etc/nginx

RUN rm -rf /etc/nginx/*.default
COPY nginx.conf /etc/nginx/nginx.conf.tmpl

RUN mkdir -p /cache /log /etc/certs.d /var/log/nginx
COPY bad.* /etc/certs.d/

VOLUME ["/cache", "/log", "/etc/certs.d"]

ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
CMD ["cache"]

ARG VERSION=unknown
RUN echo "$VERSION" > /version.txt