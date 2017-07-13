local empty = {}

print(os.time(), os.date("%Y"), os.date("%m"), os.date("%d"))

local fileName = "chrome.png"

local i, j = string.find(fileName, "[.]")

print(i, j)
print(string.sub(fileName, i))

local foo = { id = 1, "hello" }
print(foo.id .. "," .. foo[1])

foo.bar = function(a, b, c)
    print(a, b, c)
end

foo.bar(1, 2, 3)

local res = { [1] = "Content-Disposition" }

if res[1] ~= "Content-Disposition" then
    print("~=")
end

local status = os.execute("dir")
print(status)

local function test()

end

local function test2()

end

local res = (test() and test2()) or true
if res then
    print("OooooooO")
end