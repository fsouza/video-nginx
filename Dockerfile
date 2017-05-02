FROM alpine:3.5 as build

RUN apk add --no-cache curl build-base openssl openssl-dev zlib-dev linux-headers pcre-dev lua lua-dev
RUN mkdir nginx nginx-vod-module nginx-lua-module ngx_devel_kit

ENV NGINX_VERSION 1.11.10
ENV VOD_MODULE_VERSION 1.16
ENV LUA_MODULE_VERSION 0.10.8
ENV DEV_MODULE_VERSION 0.3.0

RUN curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C nginx --strip 1 -xz
RUN curl -sL https://github.com/kaltura/nginx-vod-module/archive/${VOD_MODULE_VERSION}.tar.gz | tar -C nginx-vod-module --strip 1 -xz
RUN curl -sL https://github.com/openresty/lua-nginx-module/archive/v${LUA_MODULE_VERSION}.tar.gz | tar -C nginx-lua-module --strip 1 -xz
RUN curl -sL https://github.com/simpl/ngx_devel_kit/archive/v${DEV_MODULE_VERSION}.tar.gz | tar -C ngx_devel_kit --strip 1 -xz

WORKDIR nginx
RUN ./configure --prefix=/usr/local/nginx \
	--add-module=../nginx-vod-module \
	--add-module=../ngx_devel_kit \
	--add-module=../nginx-lua-module \
	--with-file-aio \
	--with-cc-opt="-O3"
RUN make
RUN make install

FROM alpine:3.5
RUN apk add --no-cache ca-certificates openssl pcre zlib lua
COPY --from=build /usr/local/nginx /usr/local/nginx
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
RUN rm -rf /usr/local/nginx/html /usr/loca/nginx/conf/*.default
ENTRYPOINT ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
