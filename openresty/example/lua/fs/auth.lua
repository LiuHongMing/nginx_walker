-- ===========
-- 请求认证
-- ===========
--连接池
local function close_db(db)
    if not db then
        return
    end
    local pool_max_idle_time = 10000
    local pool_size = 100
    local ok, err = db:set_keepalive(pool_max_idle_time, pool_size)
    if not ok then
        ngx.say("set keepalive error : ", err)
    end
end

local mysql = require "resty.mysql"
--创建实例
local db, err = mysql:new()
if not db then
    ngx.say("new mysql error: ", err)
    return
end
--设置超时
db:set_timeout(1000)
--链接设置
local props = {
    host = "192.168.20.131",
    port = 3306,
    database = "hj_sport",
    user = "IMUSER",
    password = "IMUSER123",
    charset = "utf8"
}
local res, err, errno, sqlstate = db:connect(props)
if not res then
    ngx.say("connect to mysql error: ", err, ", errno: ", errno, ", sqlstate: ", sqlstate)
    return close_db(db)
end
--查询token
--ngx.req.read_body()
local args, err = ngx.req.get_uri_args()
if not args then
    ngx.say("failed to get post args: ", err)
    return
end
local req_uid = args.uid or ''
local req_token = args.token or ''
local get_token_sql = "select token from client_token where user_id = '" .. req_uid
        .. "' and token = '" .. req_token .. "'"
res, err, errno, sqlstate = db:query(get_token_sql)
if not res then
    ngx.say("get_token_sql error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
    return close_db(db)
end

if #(res) == 0 then
    --ngx.say("Forbidden ...")
    return ngx.exit(ngx.HTTP_FORBIDDEN)
end