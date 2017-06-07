video-nginx
===========

This repository contains a Dockerfile for building nginx optimized for
video-delivery. It contains:

- [lua-nginx-module](https://github.com/openresty/lua-nginx-module) (with
  luajit) for Lua scripting
- [nginx-rtmp-module](https://github.com/arut/nginx-rtmp-module) for live
  streaming (with on-the-fly HLS/DASH segmenting)
- [nginx-video-thumbextractor-module](https://github.com/wandenberg/nginx-video-thumbextractor-module)
  for thumb generation
- [nginx-vod-module](https://github.com/kaltura/nginx-vod-module) for
  on-the-fly video segmenting

Please notice that in order to build this locally you need Docker 17.05.

The image is available on Docker Hub:
https://hub.docker.com/r/fsouza/video-nginx/.
