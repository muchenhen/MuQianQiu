

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

_ENV.ui = ui
_G.ui = ui
