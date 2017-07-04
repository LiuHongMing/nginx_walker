local empty = {}

print(os.time())

local fileName = "chrome.png"

local i, j = string.find(fileName, "[.]")

print(i, j)
print(string.sub(fileName, i))

local foo = { id = 1, "hello" }
print(foo.id .. "," .. foo[1])