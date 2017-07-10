
--local dir = "f:/vfs/"
--local file_name = dir .. "upload.log"
--
--local target = io.open(file_name, "w+")
--target:write()


require "lfs"

local mkdir = "f:/lua_lsf"
local res = lfs.attributes(mkdir)
for k, v in pairs(res) do
    --print(k, v)
end

local stdout = io.popen("dir", "r")
local all = stdout:read("*a")
print(all)

stdout:close()