
--初始化耗时模块
local redis = require
local cjson = require "cjson"

--全局变量，不推荐
count = 1

--共享内存变量
local shared_data = ngx.shared.shared_data
shared_data:set("count", 1)