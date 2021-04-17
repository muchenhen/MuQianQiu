require "Functions"

UIStack = {}
UIStack.Stack = {}
UIStack.Layer = 1

function UIStack:OpenUIByName(uiName)
    local ui = slua.loadUI("/Game/UI/" .. ConverUEPath(uiName))
    ui:AddToViewport(UIStack.Layer)
    UIStack.Stack[#UIStack.Stack + 1] = ui
    UIStack.Layer = UIStack.Layer + 1
    return ui
end

function UIStack:OpenUI(ui)
    local bCreated
    local bCreatedUI
    for k,v in pairs(UIStack.Stack) do
        if v == ui then
            bCreated = true
            bCreatedUI = v
            break
        end
    end
    if bCreated then
        bCreatedUI:AddToViewport(UIStack.Layer)
        UIStack.Layer = UIStack.Layer + 1
    end
end

function UIStack:CreateUI(uiName)
    local ui = slua.loadUI("/Game/UI/" .. ConverUEPath(uiName))
    UIStack.Stack[#UIStack.Stack + 1] = ui
    return ui
end

function UIStack:CloseUI(ui)
    for k,v in pairs(UIStack.Stack) do
        if v == ui then
            v:RemoveFromParent()
            table.remove(UIStack.Stack, k)
            UIStack.Layer = UIStack.Layer + 1
            break
        end
    end
end