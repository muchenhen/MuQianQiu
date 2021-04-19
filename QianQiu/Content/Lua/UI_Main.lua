require "Global"

local UI_Main = {}

function UI_Main:Initialize()
    WashCards()
    self.UI_CardPool:FirstInitCards()
    self.UI_CardPoolPlayer:FirstInitCards()
    self.UI_CardPoolEnenmy:FirstInitCards()
    local param = {
        UI_CardPoolEnenmy = self.UI_CardPoolEnenmy,
        UI_CardPool = self.UI_CardPool
    }
    Enemy:SetData(param)
    self.round = 0
    self.bTick = true
    CommandMap:AddCommand("ShowRound", self, self.ShowRound)
end

function UI_Main:Construct()
    -- self.bHasScriptImplementedTick = true
end

function UI_Main:Tick()
    if self.bTick and self.round <20 then
        self.bTick = false
        self:ShowRound()
    end
end

function UI_Main:ShowRound()
    if self.round < 20 then
        local text = ""
        if self.round%2 == 0 then
            text = "我方回合"
            self.UI_CardPoolPlayer:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
        elseif self.round%2 == 1 then
            text = "对手回合"
            self.UI_CardPoolPlayer:SetVisibility(ESlateVisibility.HitTestInvisible)
        end
        local param = {
            text = text,
            round = self.round
        }
        UIStack:PushUIByName("UI_Round", param)
        self.round = self.round + 1

    end
end

return UI_Main