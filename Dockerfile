FROM alpine:3.5
ENV NGINX_VERSION 1.12.0
ENV MODULE_VERSION 1.16

RUN apk add --no-cache curl build-base zlib-dev linux-headers pcre-dev
RUN mkdir nginx nginx-vod-module
RUN curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C nginx --strip 1 -xz
RUN curl -sL https://github.com/kaltura/nginx-vod-module/archive/${MODULE_VERSION}.tar.gz | tar -C nginx-vod-module --strip 1 -xz

WORKDIR nginx
RUN ./configure --add-module=../nginx-vod-module --with-file-aio --with-cc-opt="-O3"
RUN make
RUN make install
