
--写响应头
ngx.header.a = "1"

--多个响应头可以使用table
ngx.header.b = {"2", "3" }

--输出响应
ngx.say("a", "b", "<br/>")
ngx.print("c", "d", "<br/>")

--退出，返回200状态码
return ngx.exit(200)