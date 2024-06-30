MuBPFunction = import("MuBPFunction")

UIManager = {}

function UIManager:ShowTip(Tip)
    local UI_Tip = MuBPFunction.CreateUserWidget("UI_Tip")
    UI_Tip:AddToViewport(0)
    UI_Tip:ShowTip(Tip)
    print(Tip)
end