require "Global"

local UI_Main = {}

function UI_Main:ctor()

end

function UI_Main:Initialize()
    self.UI_CardPool:FirstInitCards()
    self.UI_CardPoolPlayer:FirstInitCards()
    self.UI_CardPoolEnenmy:FirstInitCards()
    -- self.UI_CardPoolEnenmy:SetBackOn()
end

function UI_Main:Construct()

end

return UI_Main