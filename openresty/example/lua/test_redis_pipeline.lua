local redis = require "resty.redis"

local red = redis:new()
red:set_timeout(1000)
local ip = "192.168.20.116"
local port = 19000
local ok, err = red:connect(ip, port)
if not ok then
    ngx.say("connect to redis error : ", err)
    return close_redis(red)
end

red:init_pipeline()
red:set("msg1", "hello1")
red:set("msg2", "hello2")
red:get("msg1")
red:get("msg2")
local respTable, err = red:commit_pipeline()

--得到的数据为空处理
if respTable == ngx.null then
    respTable = {} --默认值
end

for k, v in pairs(respTable) do
    ngx.say("msg : ", v, "<br/>")
end

local resp, err = red:eval("return redis.call('get', KEYS[1])", 1, "msg");
ngx.say("msg : ", v, "<br/>")

