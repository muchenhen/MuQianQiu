require("Global")

local UI_GameStart = {}

function UI_GameStart:Initialize()
    self.bHasScriptImplementedTick = true
end

function UI_GameStart:Tick()
end

function UI_GameStart:Construct()
    self.Button_GameStart.OnClicked:Add(MakeCallBack(self.OnStartClick, self))
end

function UI_GameStart:OnStartClick()
    GameManager:GameStart()
    local UI_GameMain = MuBPFunction.CreateUserWidget("UI_GameMain")
    UI_GameMain:AddToViewport(0)
    self:RemoveFromParent()
end

function UI_GameStart:OnDestroy()
    -- body
end

return Class(nil, nil, UI_GameStart)
