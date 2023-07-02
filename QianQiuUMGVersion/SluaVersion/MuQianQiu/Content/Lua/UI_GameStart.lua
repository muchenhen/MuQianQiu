require("Global")

local UI_GameStart = {}

function UI_GameStart:Initialize()

end

function UI_GameStart:Construct()
    print("UI_GameStart:Construct")
    self.Button_GameStart.OnClicked:Add(MakeCallBack(self.OnStartClick, self))
    print(self.Button_GameStart)
end

function UI_GameStart:OnStartClick()
    print("UI_GameStart:OnStartClick")
    InitCardOnBegin()
    local UI_GameMain = MuBPFunction.CreateUserWidget("UI_GameMain")
    UI_GameMain:AddToViewport(0)
    self:RemoveFromParent()
end


return Class(nil, nil, UI_GameStart)
