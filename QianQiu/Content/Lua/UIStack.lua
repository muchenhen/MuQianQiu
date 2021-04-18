require "Functions"

UIStack = {}
UIStack.Stack = {} -- {[Layer] = {Name =  "uiName", Widget = ui}}
UIStack.Cache = {} -- {"uiName" = ui }
UIStack.Layer = 1  -- 层级

function CreateUI(uiName)
    local ui = slua.loadUI("/Game/UI/" .. ConverUEPath(uiName))
    return ui
end

function UIStack:PushUIByName(uiName, param)
    local bHaveCache = false
    local cacheUI = false
    if next(UIStack.Cache) then
        for key, value in pairs(UIStack.Cache) do
            if key == uiName then
                bHaveCache = true
                cacheUI = value
                break
            end
        end
    end
    if bHaveCache and cacheUI then
        return UIStack:PushUIByCache(uiName, param, cacheUI)
    else
        return UIStack:PushUI(uiName, param)
    end
end

function UIStack:PushUIByCache(uiName, param, cacheUI)
    local ui = cacheUI
    if param then
        ui:UpdateSelf(param)
    end
    UIStack.Layer = UIStack.Layer + 1
    ui:AddToViewport(UIStack.Layer)
    ui:PlayAnimation(ui.ShowIn, 0, 1, 0, 1, false)
    UIStack.Stack[UIStack.Layer] = {
        Name = uiName,
        Widget = ui,
    }
    -- print("从缓存打开UI：",uiName, "添加上的UI的层级：", UIStack.Layer)
    return ui
end

function UIStack:PushUI(uiName, param)
    local ui = CreateUI(uiName)
    if param then
        ui:UpdateSelf(param)
    end
    UIStack.Layer = UIStack.Layer + 1
    ui:AddToViewport(UIStack.Layer)
    UIStack.Stack[UIStack.Layer] = {
        Name = uiName,
        Widget = ui,
    }
    -- print("创建并打开UI：",uiName, "添加上的UI的层级：", UIStack.Layer)
    return ui
end

function UIStack:PopUIByName(uiName, bNeedCache)
    if next(UIStack.Stack) then
        for key, value in pairs(UIStack.Stack) do
            if value.Name == uiName then
                local anim = value.Widget.ShowOut
                if anim then
                    value.Widget:PlayAnimation(value.Widget.ShowOut, 0, 1, 0, 1, false)
                else
                    value.Widget:RemoveFromViewport()
                end
                if bNeedCache then
                    UIStack.Cache[uiName] = value.Widget
                else
                    value.Widget:Destruct()
                end
                UIStack.Stack[key] = nil
                -- print("关闭UI", uiName, "关闭的层级：", UIStack.Layer, "当前的最高层级：", UIStack.Layer - 1)
                UIStack.Layer = UIStack.Layer - 1
            end
        end
    end
end