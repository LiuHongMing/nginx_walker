
local _M = { _VERSION = '0.08' }
--元方法
local mt = { __index = _M }

local mytable = setmetatable({}, mt) --重载函数

print(mytable._VERSION)


