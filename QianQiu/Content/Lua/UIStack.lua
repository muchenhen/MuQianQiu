require "Functions"

UIStack = {}
UIStack.Stack = {} -- {[Layer] = {Name =  "uiName", Widget = ui}}
UIStack.Layer = 1  -- 层级

function CreateUI(uiName)
    local ui = slua.loadUI("/Game/UI/" .. ConverUEPath(uiName))
    return ui
end

function UIStack:PushUIByName(uiName, param)
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
                value.Widget:Destruct()
                -- UIStack.Layer = UIStack.Layer - 1
            end
        end
    end
end