FROM alpine:3.5 as build
ENV NGINX_VERSION 1.12.0
ENV MODULE_VERSION 1.16

RUN apk add --no-cache curl build-base openssl openssl-dev zlib-dev linux-headers pcre-dev
RUN mkdir nginx nginx-vod-module
RUN curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C nginx --strip 1 -xz
RUN curl -sL https://github.com/kaltura/nginx-vod-module/archive/${MODULE_VERSION}.tar.gz | tar -C nginx-vod-module --strip 1 -xz

WORKDIR nginx
RUN ./configure --prefix=/usr/local/nginx --add-module=../nginx-vod-module --with-file-aio --with-cc-opt="-O3"
RUN make
RUN make install

FROM alpine:3.5
RUN apk add --no-cache ca-certificates openssl pcre zlib
COPY --from=build /usr/local/nginx /usr/local/nginx
ENTRYPOINT ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
