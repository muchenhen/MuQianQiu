ECardSeason = {
    Spring = 1,
    Summer = 2,
    Autumn = 3,
    Winter = 4
}

ECardState = {
    Choose = 1,
    UnChoose = 0
}

function ui(uiname, baseUIName)
	return class(uiname, require("UIBase/UIBase"))
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


