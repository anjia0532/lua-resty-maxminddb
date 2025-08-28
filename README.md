Name
---
lua-resty-maxminddb - A Lua library for reading [MaxMind's Geolocation database format](https://maxmind.github.io/MaxMind-DB/)  (aka mmdb or geoip2).

[Original multi database support](https://github.com/linuxgemini/lua-resty-maxminddb/)

Prerequisites
---

**Note**
- [maxmind/libmaxminddb][]

- [openresty][]

- [GeoLite2 Free Downloadable Databases][linkGeolite2FreeDownloadableDatabases]

- [maxmind/geoipupdate][]


**New Features**

- **Multiple Database Support**: Initialize and use multiple MaxMind databases simultaneously
- **Profile Selection**: Choose which database to query using profile names
- **Automatic Fallback**: Uses first available database if no profile specified

**Bug fixed**

- [Error at lookup IP](https://github.com/anjia0532/lua-resty-maxminddb/issues/5)

- [bad argument #1 to 'concat' (table expected, got nil)](https://github.com/anjia0532/lua-resty-maxminddb/issues/4)

- [Memory leak](https://github.com/anjia0532/lua-resty-maxminddb/issues/6)

- [Multiple subdivisions](https://github.com/anjia0532/lua-resty-maxminddb/issues/7)

**API Reference**

**Functions:**
- `geo.init(profiles)`: Initialize databases with profile names and file paths
- `geo.lookup(ip, lookup_path, profile)`: Lookup IP address, optionally specify profile
- `geo.initted()`: Check if databases are initialized
- `geo.get_profiles()`: Get list of available profile names
- `geo.has_profile(profile)`: Check if a specific profile exists

**Apology for infringement**
- https://github.com/anjia0532/lua-resty-maxminddb/issues/25

Installation
---
```bash

# opm (manual install libmaxminddb and download GeoLite2-City.mmdb)
# openresty/openresty:alpine and apache/apisix:2.13.0-alpine docker image need to install perl libmaxminddb
# e.g. apk --no-cache add perl libmaxminddb && ln -s /usr/lib/libmaxminddb.so.0  /usr/lib/libmaxminddb.so
opm get anjia0532/lua-resty-maxminddb

# luarocks (manual download GeoLite2-City.mmdb)
# openresty/openresty:alpine-fat docker image
luarocks install lua-resty-maxminddb

# openresty/openresty:alpine docker image need to install luarocks (ref https://github.com/openresty/docker-openresty/blob/master/alpine/Dockerfile.fat)

# special apache/apisix:2.xx.0-alpine luarocks install lua-resty-maxminddb UNZIP=/usr/bin/unzip
# e.g. apk --no-cache add perl alpine-sdk && luarocks install lua-resty-maxminddb UNZIP=/usr/bin/unzip
```

Synopsis
---

**Basic Usage (Single Database)**
```lua
local geo = require 'resty.maxminddb'
if not geo.initted() then
    geo.init("/path/to/GeoLite2-City.mmdb")
end
local res, err = geo.lookup("8.8.8.8")
```

**Multiple Database Support**
```lua
local geo = require 'resty.maxminddb'
if not geo.initted() then
    geo.init({
        city = "/path/to/GeoLite2-City.mmdb",
        country = "/path/to/GeoLite2-Country.mmdb",
        asn = "/path/to/GeoLite2-ASN.mmdb"
    })
end

-- Lookup using default profile (first one)
local res, err = geo.lookup("8.8.8.8")

-- Or specify a specific profile
local city_data, err = geo.lookup("8.8.8.8", nil, "city")
local country_data, err = geo.lookup("8.8.8.8", nil, "country")
local asn_data, err = geo.lookup("8.8.8.8", nil, "asn")
```

**Complete Nginx Example**
```lua
server {
    listen 80;
    server_name localhost;
    location / {
        content_by_lua_block{
            local cjson = require 'cjson'
            local geo = require 'resty.maxminddb'
            if not geo.initted() then
                geo.init({
                    city = "/path/to/GeoLite2-City.mmdb",
                    country = "/path/to/GeoLite2-Country.mmdb"
                })
            end

            -- Lookup using default profile (first one)
            local res,err = geo.lookup(ngx.var.arg_ip or ngx.var.remote_addr)

            -- Multi database support
            -- local res,err = geo.lookup(ngx.var.arg_ip or ngx.var.remote_addr, nil, ngx.var.arg_type or 'city')

            if not res then
                ngx.log(ngx.ERR,'failed to lookup by ip ,reason:',err)
            end
            ngx.say("full :",cjson.encode(res))
            if ngx.var.arg_node then
               ngx.say("node name:",ngx.var.arg_node," ,value:", cjson.encode(res[ngx.var.arg_node] or {}))
            end
        }
    }
}
```

```bash
  #ipv4
  $ curl localhost/?ip=114.114.114.114&node=city&type=city

  #ipv6
  #$ curl localhost/?ip=2001:4860:0:1001::3004:ef68&node=country

  full :{"city":{"geoname_id":1799962,"names":{"en":"Nanjing","ru":"Нанкин","fr":"Nankin","pt-BR":"Nanquim","zh-CN":"南京","es":"Nankín","de":"Nanjing","ja":"南京市"}},"subdivisions":[{"geoname_id":1806260,"names":{"en":"Jiangsu","fr":"Province de Jiangsu","zh-CN":"江苏省"},"iso_code":"32"}],"country":{"geoname_id":1814991,"names":{"en":"China","ru":"Китай","fr":"Chine","pt-BR":"China","zh-CN":"中国","es":"China","de":"China","ja":"中国"},"iso_code":"CN"},"registered_country":{"geoname_id":1814991,"names":{"en":"China","ru":"Китай","fr":"Chine","pt-BR":"China","zh-CN":"中国","es":"China","de":"China","ja":"中国"},"iso_code":"CN"},"location":{"time_zone":"Asia\/Shanghai","longitude":118.7778,"accuracy_radius":50,"latitude":32.0617},"continent":{"geoname_id":6255147,"names":{"en":"Asia","ru":"Азия","fr":"Asie","pt-BR":"Ásia","zh-CN":"亚洲","es":"Asia","de":"Asien","ja":"アジア"},"code":"AS"}}
  node name:city ,value:{"geoname_id":1799962,"names":{"en":"Nanjing","ru":"Нанкин","fr":"Nankin","pt-BR":"Nanquim","zh-CN":"南京","es":"Nankín","de":"Nanjing","ja":"南京市"}}
```

prettify
```json
full: {
    "city": {
        "geoname_id": 1799962,
        "names": {
            "en": "Nanjing",
            "ru": "Нанкин",
            "fr": "Nankin",
            "pt-BR": "Nanquim",
            "zh-CN": "南京",
            "es": "Nankín",
            "de": "Nanjing",
            "ja": "南京市"
        }
    },
    "subdivisions": [{
            "geoname_id": 1806260,
            "names": {
                "en": "Jiangsu",
                "fr": "Province de Jiangsu",
                "zh-CN": "江苏省"
            },
            "iso_code": "32"
        }
    ],
    "country": {
        "geoname_id": 1814991,
        "names": {
            "en": "China",
            "ru": "Китай",
            "fr": "Chine",
            "pt-BR": "China",
            "zh-CN": "中国",
            "es": "China",
            "de": "China",
            "ja": "中国"
        },
        "iso_code": "CN"
    },
    "registered_country": {
        "geoname_id": 1814991,
        "names": {
            "en": "China",
            "ru": "Китай",
            "fr": "Chine",
            "pt-BR": "China",
            "zh-CN": "中国",
            "es": "China",
            "de": "China",
            "ja": "中国"
        },
        "iso_code": "CN"
    },
    "location": {
        "time_zone": "Asia\/Shanghai",
        "longitude": 118.7778,
        "accuracy_radius": 50,
        "latitude": 32.0617
    },
    "continent": {
        "geoname_id": 6255147,
        "names": {
            "en": "Asia",
            "ru": "Азия",
            "fr": "Asie",
            "pt-BR": "Ásia",
            "zh-CN": "亚洲",
            "es": "Asia",
            "de": "Asien",
            "ja": "アジア"
        },
        "code": "AS"
    }
}
node name: city, value: {
    "geoname_id": 1799962,
    "names": {
        "en": "Nanjing",
        "ru": "Нанкин",
        "fr": "Nankin",
        "pt-BR": "Nanquim",
        "zh-CN": "南京",
        "es": "Nankín",
        "de": "Nanjing",
        "ja": "南京市"
    }
}

```

References
---

- [GeoIP2 City and Country CSV Databases][linkGeoip2CityAndCountryCsvDatabases]
- [lilien1010/lua-resty-maxminddb][]
- [maxmind/libmaxminddb#source#lookup_and_print][]
- [maxmind/libmaxminddb#source#dump_entry_data_list][]

Bug Reports
---
Please report bugs by filing an issue with our GitHub issue tracker at https://github.com/anjia0532/lua-resty-maxminddb/issues

If the bug is casued by libmaxminddb  tracker at https://github.com/maxmind/libmaxminddb/issues

Copyright and License
=====================

This module is licensed under the apache LICENSE-2.0 license.

Copyright 2017-now anjia (anjia0532@gmail.com)

Licensed under the Apache License, Version 2.0 (the "License");

you may not use this file except in compliance with the License.

You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software

distributed under the License is distributed on an "AS IS" BASIS,

WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and

limitations under the License.

[maxmind/libmaxminddb]: https://github.com/maxmind/libmaxminddb
[openresty]: https://openresty.org/en/installation.html
[linkGeolite2FreeDownloadableDatabases]: http://dev.maxmind.com/geoip/geoip2/geolite2/
[maxmind/geoipupdate]: https://github.com/maxmind/geoipupdate
[linkGeoip2CityAndCountryCsvDatabases]: https://dev.maxmind.com/geoip/geoip2/geoip2-city-country-csv-databases/
[maxmind/libmaxminddb#source#lookup_and_print]: https://github.com/maxmind/libmaxminddb/blob/master/bin/mmdblookup.c#L262
[maxmind/libmaxminddb#source#dump_entry_data_list]: https://github.com/maxmind/libmaxminddb/blob/master/src/maxminddb.c#L1938
[lilien1010/lua-resty-maxminddb]: https://github.com/lilien1010/lua-resty-maxminddb
