
# Test Document

`cd docker && mkdir -p geoipupdate_data` 

## Download maxmind database file
```bash
cat geo-env
# Change to your account GEOIPUPDATE_LICENSE_KEY GEOIPUPDATE_ACCOUNT_ID
#vi geo-env
docker run --env-file geo-env --rm --entrypoint /bin/sh -it -v $(pwd)/geoipupdate_data:/tmp/ ghcr.io/maxmind/geoipupdate
```

## Run openresty
```bash
# run openresty as daemon
docker run -d -p80:80 --name openresty  --rm -v $(pwd)/../lib/resty/maxminddb.lua:/usr/local/openresty/lualib/resty/maxminddb.lua -v $(pwd)/geoip/:/opt/geoipupdate_data/ -v $(pwd)/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf  openresty/openresty:alpine-fat

# install libmaxminddb 
docker exec -it openresty /bin/sh
apk add --no-cache perl libmaxminddb &&  ln -s /usr/lib/libmaxminddb.so.0 /usr/lib/libmaxminddb.so
```

## Run wrk

```bash
docker run -it --rm -v $(pwd)/wrk-test.lua:/tmp/wrk-test.lua --name wrk williamyeh/wrk:4.0.2 -t50 -c200 -d120s -s /tmp/wrk-test.lua --latency http://127.0.0.1:80

Running 2m test @ http://127.0.0.1:80
  50 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     4.08ms    2.93ms 220.41ms   85.59%
    Req/Sec     0.97k   204.69     3.37k    72.66%
  Latency Distribution
     50%    3.62ms
     75%    5.22ms
     90%    7.02ms
     99%   11.78ms
  4537000 requests in 2.00m, 2.76GB read
Requests/sec:  37777.96
Transfer/sec:     23.52MB
```

