function table.FillNum(m,n)
    local t = {}
    local i = m
    while i <= n do
        t[i] = 0 -- 0还在牌库 1已经发出去
        i = i + 1
    end
    return t
end

function table.GetValue(table,value)
    for key, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function table.RemoveValue(t, value)
    local ta = {}
    for key, v in pairs(t) do
        if v ~= value then
            table.insert(ta, v)
        end
    end
    return ta
end

function math.randomx( m,n,cnt ) -- 生成指定范围内不相同的指定数量的随机数
    if cnt>n-m+1 then
        return {}
    end
    local t = {}
    local tmp = {}
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,7)))
    while cnt>0 do
        local x = math.random(m,n)
        if not tmp[x] then
            t[#t+1]=x
            tmp[x]=1
            cnt=cnt-1
        end
    end
    return t
end

function LastStringBySeparator(str, separator)
	return str:sub(str:find(string.format("[^%s]*$", separator)))
end

function GetResPath(gamePackagePath)
    return string.format("%s.%s", gamePackagePath, LastStringBySeparator(gamePackagePath, "/"))
end

function LoadObject(path, className)
    local lastStr = LastStringBySeparator(path, "/")
    if className ~= nil then
        return slua.loadObject(string.format("%s\'%s\'", className, GetResPath(path)))
    end
    return slua.loadObject(path)
end

function ConverUEPath(path)
	if path:find('%.') == nil then
		local fileName = LastStringBySeparator(path, '/')
		return string.format("%s.%s", path, fileName)
	else
		return path
	end
end

function Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
       local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
       if not nFindLastIndex then
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
        break
       end
       nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
       nFindStartIndex = nFindLastIndex + string.len(szSeparator)
       nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

function Sleep(time)
    -- local duration = os.time() + time
    -- while os.time() < duration do end
end

function Dump(value, depth, key)
    local linePrefix = ""
    local spaces = ""
 
    if key ~= nil then
      linePrefix = "[" .. key .. "] = "
    end
 
    if depth == nil then
        depth = 0
    else
        depth = depth + 1
        for i = 1, depth do
            spaces = spaces .. "  "
        end
    end
 
    if type(value) == 'table' then
        mTable = getmetatable(value)
        if mTable ~= nil then
            --print(spaces .."(metatable) ")
            for tableKey, tableValue in pairs(mTable) do
                Dump(tableValue, depth, tableKey)
            end
        end
        --print(spaces ..linePrefix.."(table) ")
        for tableKey, tableValue in pairs(value) do
          Dump(tableValue, depth, tableKey)
        end
    elseif type(value)	== 'function' or
        type(value)	== 'thread' or
        type(value)	== 'userdata' or
        value		== nil
    then
        --print(spaces .. tostring(value))
    else
        --print(spaces .. linePrefix .. "(" .. type(value) .. ") " .. tostring(value))
    end
end


function Shuffle(_table)
    -- 判断如果不为table则直接返回 
    if type(_table)~="table" then
	   return
	end
    local _result = {}
    local _index = 1
    while #_table ~= 0 do
        local ran = math.random(0,#_table)
        if _table[ran] ~= nil then
            _result[_index] = _table[ran]
            table.remove(_table,ran)
            _index = _index + 1
        end
    end
    return _result
end