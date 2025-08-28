package = "lua-resty-maxminddb"
version = "1.3.5-1"
supported_platforms = {"linux", "macosx"}

source = {
   url = "git://github.com/anjia0532/lua-resty-maxminddb",
   tag = "v1.3.5"
}

description = {
   summary = "About A Lua library for reading MaxMind's Geolocation database",
   detailed = [[
      lua-resty-maxminddb - A Lua library for reading MaxMind's Geolocation database format (aka mmdb or geoip2).
   ]],
   homepage = "https://github.com/anjia0532/lua-resty-maxminddb",
   license = "Apache License 2.0"
}
dependencies = {
   "lua >= 5.1, < 5.2"
   -- If you depend on other rocks, add them here
}
build = {
    type = "command",
    build_command = [[
        wget -O libmaxminddb-1.12.2.tar.gz \
          https://github.com/maxmind/libmaxminddb/releases/download/1.12.2/libmaxminddb-1.12.2.tar.gz && \
        tar zxf libmaxminddb-1.12.2.tar.gz && \
          cd libmaxminddb-1.12.2 && \
          ./configure && \
          $(MAKE) -j && \
          $(MAKE) check
    ]],
    install = {
       lua = {
           ["resty.maxminddb"] = "lib/resty/maxminddb.lua",
       },
       lib = {
           ["libmaxminddb.so"] = "libmaxminddb-1.12.2/src/.libs/libmaxminddb.so.0.0.7",
           ["libmaxminddb.so.0 "] = "libmaxminddb-1.12.2/src/.libs/libmaxminddb.so.0.0.7",
           ["libmaxminddb.so.0.0.7"] = "libmaxminddb-1.12.2/src/.libs/libmaxminddb.so.0.0.7",
       },
    },
    install_command = "cd libmaxminddb-1.12.2 && $(MAKE) install"
}
