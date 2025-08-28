
# Test Document

> CPU Intel(R) Core(TM) Ultra 9 185H (2.30 GHz)
> Wsl Memory limit 8G
> Windows 11 + Wsl2

`cd docker && mkdir -p geoipupdate_data` 

## Download maxmind database file
```bash
cat geo-env
# Change to your account GEOIPUPDATE_LICENSE_KEY GEOIPUPDATE_ACCOUNT_ID
#vi geo-env
docker run --env-file geo-env --rm --name geoipupdate -v $(pwd)/geoipupdate_data/:/usr/local/share/GeoIP/ ghcr.io/maxmind/geoipupdate
# docker run --env-file geo-env --rm --name geoipupdate --entrypoint /bin/sh -it -v $(pwd)/geoipupdate_data/:/usr/local/share/GeoIP/ ghcr.io/maxmind/geoipupdate
# HTTPS_PROXY=http://127.0.0.1:1080 HTTP_PROXY=http://127.0.0.1:1080 geoipupdate
```

## Run openresty

Alpine image (libmaxminddb 1.9.1-r0 && 1.12.2)

```bash
# run openresty as daemon
docker run -d -p80:80 --name openresty  --rm -v $(pwd)/../lib/resty/maxminddb.lua:/usr/local/openresty/lualib/resty/maxminddb.lua -v $(pwd)/geoipupdate_data/:/opt/geoipupdate_data/ -v $(pwd)/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf  openresty/openresty:alpine-fat

# install libmaxminddb 
docker exec -it openresty /bin/bash
# 1.9.1-r0
apk add --no-cache perl libmaxminddb &&  ln -s /usr/lib/libmaxminddb.so.0 /usr/lib/libmaxminddb.so
# 1.12.2
cd /tmp/
wget https://github.com/maxmind/libmaxminddb/releases/download/1.12.2/libmaxminddb-1.12.2.tar.gz && \
  tar zxf libmaxminddb-1.12.2.tar.gz && \
  cd libmaxminddb-1.12.2 && \
  ./configure && \
  make -j && \
  make check && \
  make install && \
  ldconfig && \
  rm -rf /tmp/*
  
openresty -s reload
```

Ubuntu image (1.12.2-0+maxmind1~jammy)

```bash
# run openresty as daemon
docker run -d -p80:80 --name openresty  --rm -v $(pwd)/../lib/resty/maxminddb.lua:/usr/local/openresty/lualib/resty/maxminddb.lua -v $(pwd)/geoipupdate_data/:/opt/geoipupdate_data/ -v $(pwd)/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf  openresty/openresty:jammy

# install libmaxminddb 
docker exec -it openresty /bin/bash
apt update && apt install -y software-properties-common && add-apt-repository ppa:maxmind/ppa -y && apt update && apt install -y libmaxminddb0 libmaxminddb-dev mmdb-bin
openresty -s reload
```

## Run wrk

```bash
docker run -it --rm -v $(pwd)/wrk-test.lua:/tmp/wrk-test.lua --name wrk williamyeh/wrk:4.0.2 -t50 -c200 -d120s -s /tmp/wrk-test.lua --latency http://127.0.0.1:80

# alpine image (old version libmaxminddb 1.9.1-r0)
Running 2m test @ http://127.0.0.1:80
  50 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.85ms    3.39ms 260.04ms   92.83%
    Req/Sec     1.02k   210.85     3.26k    75.24%
  Latency Distribution
     50%    3.40ms
     75%    4.90ms
     90%    6.59ms
     99%   10.91ms
  4488000 requests in 2.00m, 2.73GB read
Requests/sec:  37368.74
Transfer/sec:     23.27MB

# alpine image (libmaxminddb 1.12.2 cmake install)
Running 2m test @ http://127.0.0.1:80
  50 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.89ms    2.57ms 211.34ms   81.24%
    Req/Sec     1.02k   210.32     3.21k    73.80%
  Latency Distribution
     50%    3.48ms
     75%    5.00ms
     90%    6.71ms
     99%   11.04ms
  4482809 requests in 2.00m, 2.73GB read
Requests/sec:  37325.96
Transfer/sec:     23.24MB

# Ubuntu image (1.12.2-0+maxmind1~jammy)
Running 2m test @ http://127.0.0.1:80
  50 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.84ms    3.47ms 204.31ms   92.95%
    Req/Sec     1.05k   222.28     3.15k    71.39%
  Latency Distribution
     50%    3.31ms
     75%    4.85ms
     90%    6.63ms
     99%   11.45ms
  4410000 requests in 2.00m, 2.68GB read
Requests/sec:  36719.95
Transfer/sec:     22.87MB
```

