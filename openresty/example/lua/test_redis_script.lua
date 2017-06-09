local function close_redis(red)
    if not red then
        return
    end

    local ok, err = red:close()
    if not ok then
        ngx.say("close redis error : ", err)
    end
end

local redis = require "resty.redis"

local red = redis:new()
red:set_timeout(1000)
local ip = "192.168.20.159"
local port = 6379
local ok, err = red:connect(ip, port)
if not ok then
    ngx.say("connect to redis error : ", err)
end

-- eval
local resp, err = red:eval("return redis.call('get', KEYS[1])", 1, "msg");
ngx.say("eval resp : ", resp, "<br/>")

-- script，evalsha
local sha1, err = red:script("load", "redis.call('get', KEYS[1])");
if not sha1 then
    ngx.say("load script error : ", err)
end
ngx.say("sha1 : ", sha1, "<br/>")
local resp, err = red:evalsha(sha1, 1, "msg");
ngx.say("evalsha resp : ", resp, "<br/>")