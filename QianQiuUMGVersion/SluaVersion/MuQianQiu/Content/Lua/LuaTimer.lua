local LuaTimer = {}

function LuaTimer:new()
    local timer = {tasks = {}}

    setmetatable(timer, self)
    self.__index = self

    return timer
end

function LuaTimer:Add(delay, func)
    local task = {delay = delay, func = func, time = os.time() + delay}
    table.insert(self.tasks, task)
end

function LuaTimer:Update()
    local timer = os.time()

    for i = #self.tasks, 1, -1 do
        local task = self.tasks[i]

        if timer >= task.time then
            task.func()
            table.remove(self.tasks, i)
        end
    end
end

return LuaTimer
