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
        local x =math.random(m,n)
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

function Sleep(a)
    local sec = tonumber(os.clock() + a);
    while (os.clock() < sec) do
    end
end