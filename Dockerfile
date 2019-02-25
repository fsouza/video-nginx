FROM alpine:3.9 as build

RUN apk add --no-cache curl build-base openssl openssl-dev zlib-dev linux-headers pcre-dev luajit luajit-dev ffmpeg ffmpeg-dev libjpeg-turbo libjpeg-turbo-dev
RUN mkdir nginx nginx-vod-module nginx-lua-module ngx_devel_kit nginx-rtmp-module nginx-thumb-module

ENV NGINX_VERSION 1.14.2
ENV VOD_MODULE_VERSION 1.24
ENV LUA_MODULE_VERSION v0.10.14
ENV DEV_MODULE_VERSION v0.3.0
ENV RTMP_MODULE_VERSION v1.2.1
ENV THUMB_MODULE_VERSION 0.9.0

RUN curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C nginx --strip 1 -xz
RUN curl -sL https://github.com/kaltura/nginx-vod-module/archive/${VOD_MODULE_VERSION}.tar.gz | tar -C nginx-vod-module --strip 1 -xz
RUN curl -sL https://github.com/openresty/lua-nginx-module/archive/${LUA_MODULE_VERSION}.tar.gz | tar -C nginx-lua-module --strip 1 -xz
RUN curl -sL https://github.com/simpl/ngx_devel_kit/archive/${DEV_MODULE_VERSION}.tar.gz | tar -C ngx_devel_kit --strip 1 -xz
RUN curl -sL https://github.com/arut/nginx-rtmp-module/archive/${RTMP_MODULE_VERSION}.tar.gz | tar -C nginx-rtmp-module --strip 1 -xz
RUN curl -sL https://github.com/wandenberg/nginx-video-thumbextractor-module/archive/${THUMB_MODULE_VERSION}.tar.gz | tar -C nginx-thumb-module --strip 1 -xz

ENV LUAJIT_INC /usr/include/luajit-2.1/
ENV LUAJIT_LIB /usr/lib

WORKDIR /nginx
RUN ./configure --prefix=/usr/local/nginx \
	--with-ld-opt="-Wl,-rpath,/usr/lib/libluajit-5.1.so" \
	--add-module=../nginx-vod-module \
	--add-module=../ngx_devel_kit \
	--add-module=../nginx-lua-module \
	--add-module=../nginx-thumb-module \
	--add-module=../nginx-rtmp-module \
	--with-file-aio \
	--with-threads \
	--with-cc-opt="-O3"
RUN make
RUN make install

FROM alpine:3.9
RUN apk add --no-cache ca-certificates openssl pcre zlib luajit ffmpeg libjpeg-turbo
COPY --from=build /usr/local/nginx /usr/local/nginx
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
RUN rm -rf /usr/local/nginx/html /usr/loca/nginx/conf/*.default
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
