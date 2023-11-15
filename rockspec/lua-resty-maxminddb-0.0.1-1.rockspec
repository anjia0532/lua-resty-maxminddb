package = "lua-resty-maxminddb"
version = "0.0.1-1"
supported_platforms = {"linux", "macosx"}

source = {
   url = "git://github.com/cyberandao/lua-resty-maxminddb",
   tag = "cyberandao-1.0.1"
}

description = {
   summary = "About A Lua library for reading MaxMind's Geolocation database",
   detailed = [[
      lua-resty-maxminddb - A Lua library for reading MaxMind's Geolocation database format (aka mmdb or geoip2).
      Forked from https://github.com/anjia2/lua-resty-maxminddb
   ]],
   homepage = "https://github.com/cyberandao/lua-resty-maxminddb",
   license = "Apache License 2.0"
}
dependencies = {
   "lua >= 5.1, < 5.2"
   -- If you depend on other rocks, add them here
}
