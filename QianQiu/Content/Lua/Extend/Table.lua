local table = table

-- Shallow copy a table
--@t table
--@return table
function table.scopy(t)
    local res = {}
    for k, v in pairs(t) do
        res[k] = v
    end
    return res
end

function table.dcopy(t)
    local SearchTable = {}
    local function Func(t)
        if type(t) ~= "table" then
            return t
        elseif SearchTable[t] then
            return SearchTable[t]
        end
        local NewTable = {}
        SearchTable[t] = NewTable
        for k, v in pairs(t) do
            NewTable[Func(k)] = Func(v)
        end
        return setmetatable(NewTable, getmetatable(t))
    end
    return Func(t)
end

--[[
@description: 切割字典
	in: [0,1,2,3,4,5] 4, 5 超出长度
	out: [4,5]
	in: [0,1,2,3,4,5] 1, 2 目标数小于数组长度
	out: [1,2]
	in: [0,1,2,3,4,5] 3	   缺省目标数
	out: [2,3,4,5]
--]]
function table.slice(t, from, count)
    count = count or #t
    if from > count then
        return {}
    end
    return {table.unpack(t, from, count + from)}
end

-- Swap table values by keys key1 and key2
--@key1 any
--@key2 any
function table.swap(t, key1, key2)
    local temp = t[key1]
    t[key1] = t[key2]
    t[key2] = temp
end

-- Get the max number of key in table
--@t table
function table.maxn(t)
    local mn = nil
    for k, v in pairs(t) do
        if type(k) == "number" then
            if (mn == nil or mn < k) then
                mn = k
            end
        end
    end
    return mn or 0
end

function table.insertUnique(array, val, insertPos)
    local idx = table.indexof(array, val)
    if idx == 0 then
        insertPos = insertPos or #array+1
        table.insert(array, insertPos, val)
        return true
    end
    return false
end

function table.insertto(dest, src, begin)
    begin = checkInt(begin)
    if begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end
function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

--[[
@description: 筛选元素
@param {
    t: targettable
    filterIter: filterfunction
}
@return {
    new table
}
--]]
function table.filter(t, filterIter)
    local out = {}
  
    for k, v in pairs(t) do
      if filterIter(v, k, t) then out[k] = v end
    end
  
    return out
  end

function table.mergeinsert(dest, src)
    for _, v in pairs(src) do
        table.insert(dest, v)
    end
end

function table.keys(hashTbl)
    local keys = {}
    for k in pairs(hashTbl) do
        keys[#keys + 1] = k
    end
    return keys
end

function table.indexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then
            return i
        end
    end
    return 0
end

function table.removeValue(t, value)
    if table.isEmpty(t) then
        return
    end

    for i, v in ipairs(t) do
        if v == value then
            table.remove(t, i)
            break
        end
    end
end

--[[
@description: 快速移除某个位置的对象, 只可用于顺序无关的数组
--]]
function table.orderirrelevantRemove(t, index)
    t[index] = nil
end

function table.checkValueExist(tbl, value)
    if table.isEmpty(tbl) then
        return false
    end

    for k, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

function table.isEmpty(tbl)
    if not tbl then
        return true
    end
    if type(tbl) ~= "table" then
        return true
    end
    return _G.next(tbl) == nil
end

function table.length(tbl)
    local length = 0
    for _ in pairs(tbl) do
        length = length + 1
    end
    return length
end

function table.fakeAdd(t1, t2)
    local res = {}
    for i = 1, #t1 do
        res[i] = t1[i] + t2[i]
    end
    return res
end

function table.MakeReadOnlyTable(tbl)
    if type(tbl) == "table" then
        local meta = {
            __index = tbl,
            __newindex = function()
                LuaErrorLog("AI Script: not allow to change battle data!\n" .. debug.traceback())
            end
        }
        local lockedTbl = {}
        setmetatable(lockedTbl, meta)
        return lockedTbl
    else
        return tbl
    end
end

function table.GetKeyNameByValue(tbl, value)
    if type(tbl) == "table" then
        for k, v in pairs(tbl) do
            if v == value then
                return k
            end
        end
        return nil
    else
        return nil
    end
end
