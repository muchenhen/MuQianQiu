require("Global")

local UI_GameStart = {}

function UI_GameStart:Construct()
    print("UI_GameStart:Construct")
    self.Button_GameStart.OnClicked:Add(self.OnButtonClicked)
    print(self.Button_GameStart)
end

function UI_GameStart:OnButtonClicked()
    print("UI_GameStart:OnButtonClicked")
end


return Class(nil, nil, UI_GameStart)
