require("socket.core")
require("LuaPanda").start("127.0.0.1", 8818)

require("GameManager")

local weakmeta = {__mode = "v"}
--[[
该函数接受回调函数和可变数量的参数。
该函数创建一个名为parameters的表，该表包含传递给MakeCallBack的参数。
参数表被设置为具有弱值元表，这意味着当它们在程序中的其他地方不再被引用时，它的值将被自动删除。
然后MakeCallBack函数创建一个名为handle的表，该表有一个返回参数表的getParam函数。然后，MakeCallBack函数计算参数表的长度，并将其存储在一个名为len_p的变量中。
然后，MakeCallBack函数定义了一个名为f的新函数，该函数接受可变数量的参数。f函数将args表与参数表连接起来，并将结果存储在参数表中。
然后，f函数调用带有串联参数表的callBack函数，并将结果存储在handle.result变量中。最后，f函数返回handle.result变量。
MakeCallBack函数返回f函数和句柄表。f函数可以用任意数量的参数调用，它会将它们与传递给MakeCallBack的原始参数连接起来，并用连接的参数调用回调函数。
句柄表可用于检索参数表和回调函数的结果。
--]]
function MakeCallBack(callBack, ...)
    local parameters = setmetatable({...}, weakmeta)
    local handle = {}
    function handle:getParam()
        return parameters
    end
    local len_p = #(parameters)
    local function f(...)
        local args = {...}
        local len_a = #(args)
        for i = 1, len_a do
            parameters[i + len_p] = args[i]
        end
        handle.result = callBack(table.unpack(parameters, 1, len_p + len_a))
        return handle.result
    end
    return f, handle
end

UI_PATH = "/Game/UserWidget/"
