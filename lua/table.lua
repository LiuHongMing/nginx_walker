--第一种遍历：pairs
tbtest = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
}
print("第1种遍历：pairs")
for key, value in pairs(tbtest) do
    print(value)
end

--第二种遍历：ipairs
tbtest = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [5] = 5,
}
print("第2种遍历：ipairs")
for k, v in ipairs(tbtest) do
    print(v)
end
print("local tbtest：")
local tbtest = {
    [2] = 2,
    [3] = 3,
    [5] = 5,
}

for k, v in ipairs(tbtest) do
    print(v)
end

--第三种遍历：一种神奇的符号'#'，这个符号的作用是是获取table的长度
print("第三种遍历：#")
tbtest = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
}
print(#(tbtest))
for i = 1, #(tbtest) do
    print(tbtest[i])
end

tbtest = {
    [1] = 1,
    [2] = 2,
    [6] = 6,
}
print(#(tbtest))
for i = 1, #(tbtest) do
    print(tbtest[i])
end

--第四种遍历：table.maxn获取的只针对整数的key，字符串的key是没办法获取到的
print("第四种遍历：table.maxn")
tbtest = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
}
print(table.maxn(tbtest))
for i = 1, table.maxn(tbtest) do
    print(tbtest[i])
end
tbtest = {
    [6] = 6,
    [1] = 1,
    [2] = 2,
}
print(table.maxn(tbtest))
for i = 1, table.maxn(tbtest) do
    print(tbtest[i])
end

-- 元方法
--"__index"	取下标操作用于访问 table[key]
mytable = setmetatable({ key1 = "value1" }, --原始表
    {
        __index = function(self, key) --重载函数
            if key == "key2" then
                return "metatablevalue"
            end
        end
    })

print(mytable.key1, mytable.key2) --> output：value1 metatablevalue
-- 高阶用法
t = setmetatable({ [1] = "hello" }, { __index = { [2] = "world" } })
print(t[1], t[2]) -->hello world