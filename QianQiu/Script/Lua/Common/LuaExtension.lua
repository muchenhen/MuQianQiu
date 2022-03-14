

function ConverUEPath(path)
    if path:find("%.") == nil then
        local fileName = LastStringBySeparator(path, "/")
        return string.format("%s.%s", path, fileName)
    else
        return path
    end
end

-- 创建新类型
-- className string 类名
-- baseClass luaTable 基类
function class(className, baseCalss)
    local newCalss = {}
    local newMate = {}
    if baseCalss then
        newMate.__index = baseCalss
        setmetatable(newCalss, newMate)
    else
        newMate.__index = newCalss
        setmetatable(newCalss, newMate)
    end
    newCalss.__name = className
    newCalss.__uid = className .. "_" .. tostring(newCalss)
    return newCalss
end

function ui(uiName)
    return class(uiName, require("Common/UIBase"))
end

local weakmeta = {__mode = "v"}
function MakeCallBack(callBack, ...)
    local parameters = setmetatable({...}, weakmeta)
    local handle = {}
    function handle:getParam()
    	return parameters
    end
    local len_p = table.maxn(parameters)
    local function f(...)
        local args = {...}
        local len_a = table.maxn(args)
        for i = 1, len_a do
            parameters[i+len_p] = args[i]
        end        
        handle.result = callBack(table.unpack(parameters, 1, len_p+len_a))
        return handle.result
    end
    return f, handle
end