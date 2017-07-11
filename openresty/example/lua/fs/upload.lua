-- ===========
-- 文件上传
-- ===========
local upload = require "resty.upload"

local chunk_size = 4096
local form, err = upload:new(chunk_size)

if not form then
    ngx.log(ngx.ERR, "failed to new upload: ", err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
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
os.execute("mkdir -p " .. target_dir)

-- 保存的文件对象
local file_name
local file_ext
local file_target

-- 文件是否成功保存
local is_end


while true do
    local typ, res, err = form:read()
    if not typ then
        ngx.say("failed to read: ", err)
        return
    end

    if typ == "header" then
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
                        local i = string.find(file_name, "[.]")
                        file_ext = string.sub(file_name, i)
                        file_name = ngx.md5("upload" .. ngx.now()) .. file_ext
                        file_target = io.open(target_dir .. file_name, "w+")
                        if not file_target then
                            ngx.say("failed to open file ", file_name)
                            return
                        end
                        break
                    end
                end
            end
        end
    elseif typ == "body" then
        -- 开始读取 http body
        if file_target then
            file_target:write(res)
        end
    elseif typ == "part_end" then
        -- 文件写结束，关闭文件
        if file_target then
            file_target:close()
            file_target = nil
        end
        is_end = true
    elseif typ == "eof" then
        -- 文件读取结束
        break
    end
end

local cjson = require "cjson"

ngx.log(ngx.INFO, "gm begin ------")
local thumbnails = { "100x100", "200x200" }
local img = target_dir .. file_name;
for _, resize in pairs(thumbnails) do
    local cmd = "/usr/graphicsmagick-1.3.20/bin/gm convert -resize " .. resize .. " " .. img .. " " .. img .. "_" .. resize .. file_ext
    local ret = os.execute(cmd .. " 2>> /tmp/upload_error.log")
    ngx.log(ngx.INFO, "gm convert : ", cmd, ", ret : ", ret)
end

local cmd = "/usr/graphicsmagick-1.3.20/bin/gm identify " .. img .. " -format '%w %h' 2>> /tmp/upload_error.log"
local out = io.popen(cmd, "r")
local all = out:read("*a")
local props = string.split(string.gsub(all, "\n", " "), " ")
out:close()
ngx.log(ngx.INFO, "gm identify : ", cmd, ", props : ", cjson.encode(props))
ngx.log(ngx.INFO, "gm end -----")

local response_body = {
    file_id = file_name,
    width = props[1],
    height = props[2]
}

if is_end then
    ngx.say(cjson.encode(response_body))
end