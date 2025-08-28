wrk.method = "GET";
wrk.body = "";

logfile = io.open("wrk.log", "w");

request = function()
ip = tostring(math.random(1, 255)).."."..tostring(math.random(1, 255)).."."..tostring(math.random(1, 255)).."."..tostring(math.random(1, 255))
local types = {"city", "asn", "country"}
local random_type = types[math.random(#types)]
path = "/?ip=" .. ip .. "&type=" .. random_type
return wrk.format(nil, path)
end

-- response = function(status,header,body)
-- logfile:write("\nbody:" .. body .. "\n-----------------");
-- end
