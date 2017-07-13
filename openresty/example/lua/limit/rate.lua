-- ===========
-- 访问频率，QPS(s)
-- ===========

--package.path = "/usr/example/lua/?.lua;"
--
--local sessionfactory = require "session.factory"
--local cjson = require "cjson"
--
--local session = sessionfactory:get()
--
--ngx.say(cjson.encode(session))

-- 批量删除
--./redis-cli keys user:172.16.208.85* | xargs ./redis-cli del

--连接池
local function close_redis(red)
    if not red then
        return
    end
    --释放连接(连接池实现)
    local pool_max_idle_time = 10000 --毫秒
    local pool_size = 100 --连接池大小
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)
    if not ok then
        ngx.say("set keepalive error : ", err)
    end
end

local function forbidden(red)
    local time = os.time()
    local res, err = red:get("block:" .. ngx.var.remote_addr)
    ngx.log(ngx.ERR, "time=", res)
    if type(res) == "string" then
        if tonumber(res) >= tonumber(time) then
            close_redis(red)
            return ngx.exit(ngx.HTTP_FORBIDDEN)
        end
    end
end

local function exceed(red)
    local time = os.time()
    local res, err = red:get("user:" .. ngx.var.remote_addr .. ":" .. time)
    ngx.log(ngx.ERR, "time=", time, ", count=", res)
    if tonumber(res) >= 3 then
        red:del("block:" .. ngx.var.remote_addr)
        red:set("block:" .. ngx.var.remote_addr, time + 5 * 60)
        close_redis(red)
        return ngx.exit(ngx.HTTP_FORBIDDEN)
    end
end

local function add(red)
    local time = os.time()
    local cmd = "user:" .. ngx.var.remote_addr .. ":" .. time;
    local ok = red:incr(cmd)
    if not ok then
        close_redis(red)
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    ngx.say(cmd)
end

local redis = require "resty.redis"

--创建实例
local red = redis:new()
--设置超时
red:set_timeout(1000)
--建立连接
local ip = "192.168.20.159"
local port = 6379

local ok, err = red:connect(ip, port)
if not ok then
    ngx.say("connect to redis error : ", err)
    return close_redis(red)
end

forbidden(red)

add(red)

exceed(red)