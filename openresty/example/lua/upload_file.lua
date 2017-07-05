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
    ngx.say("Forbidden ...")
    return ngx.exit(ngx.HTTP_FORBIDDEN)
end

-- ===========
-- 文件上传
-- ===========
local upload = require "resty.upload"

local chunk_size = 4096
local form, err = upload:new(chunk_size)

if not form then
    ngx.log(ngx.ERR, "failed to new upload: ", err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

form:set_timeout(1000)

-- 字符串 split 分割
string.split = function(s, p)
    local rt = {}
    string.gsub(s, '[^' .. p .. ']+', function(w) table.insert(rt, w) end)
    return rt
end

-- 支持字符串前后 trim
string.trim = function(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- 文件保存的根路径
local root_dir = "/usr/example"
local target_dir = root_dir .. "/upload/"
-- 创建目录
--os.execute("mkdir " .. target_dir)

-- 保存的文件对象
local target_file

-- 文件是否成功保存
local is_end
local file_name

while true do
    local state, res, err = form:read()
    if not state then
        ngx.say("failed to read: ", err)
        return
    end

    if state == "header" then
        --开始读取 header
        local key = res[1]
        local value = res[2]
        ngx.log(ngx.INFO, key, "=", value)
        if key == "Content-Disposition" then
            -- Content-Disposition=form-data; name="file"; filename="chrome.png"
            local kvlist = string.split(value, ';')
            for _, kv in ipairs(kvlist) do
                local seg = string.trim(kv)
                if seg:find("filename") then
                    local kvfile = string.split(seg, "=")
                    file_name = string.sub(kvfile[2], 2, -2)
                    if file_name then
                        --截取文件扩展名
                        local i, j = string.find(file_name, "[.]")
                        file_name = ngx.md5(ngx.now()) .. string.sub(file_name, i)
                        target_file = io.open(target_dir .. file_name, "w+")
                        if not target_file then
                            ngx.say("failed to open file ", file_name)
                            return
                        end
                        break
                    end
                end
            end
        end
    elseif state == "body" then
        -- 开始读取 http body
        if target_file then
            target_file:write(res)
        end
    elseif state == "part_end" then
        -- 文件写结束，关闭文件
        if target_file then
            target_file:close()
            target_file = nil
        end
        is_end = true
    elseif state == "eof" then
        -- 文件读取结束
        break
    else
        ngx.log(ngx.INFO, "do other things")
    end
end

local cjson = require "cjson"

local response_result = {
    file_id = file_name,
    width = 0,
    height = 0
}

if is_end then
    ngx.say(cjson.encode(response_result))
end