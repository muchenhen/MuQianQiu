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
