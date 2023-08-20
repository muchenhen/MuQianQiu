require("Global")

local UI_GameStart = {}

function UI_GameStart:print_hello()
    print("Hello!")
end

function UI_GameStart:Initialize()
    GameManager.UI_GameStart = self
    self.bHasScriptImplementedTick = true
end

function UI_GameStart:Tick()
end

function UI_GameStart:Construct()
    self.Button_GameStart.OnClicked:Add(MakeCallBack(self.OnStartClick, self))
end

function UI_GameStart:OnStartClick()
    GameManager:GameStart()
    local UI_ChooseSpecial = MuBPFunction.CreateUserWidget("UI_ChooseSpecial")
    UI_ChooseSpecial:AddToViewport(0)
    self:SetVisibility(ESlateVisibility.Hidden)
end

function UI_GameStart:OnDestroy()
    -- body
end

return Class(nil, nil, UI_GameStart)
