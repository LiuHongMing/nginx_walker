-- 字符串 split 分割
string.split = function(s, p)
    local rt = {}
    string.gsub(s, '[^' .. p .. ']+', function(w) table.insert(rt, w) end)
    return rt
end

local val = "320 118"

local arr = string.split(val, " ")
print(arr[1], arr[2])
for i, v in ipairs(arr) do
    print(v)
end