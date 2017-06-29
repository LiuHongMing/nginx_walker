local _M = { _VERSION = '0.08' }
local mt = { __index = _M }

local mytable = setmetatable({}, mt)

print(mytable._VERSION)


