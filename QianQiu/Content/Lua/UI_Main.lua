require "Global"

local UI_Main = {}

function UI_Main:Initialize()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
    WashCards()     --洗牌
    self.UI_CardPool:FirstInitCards()       --第一次初始化公共卡池
    self.UI_CardPoolPlayer:FirstInitCards() --初次初始化玩家卡池
    self.UI_CardPoolEnenmy:FirstInitCards() --初次初始化敌人卡池
    local param = {
        UI_CardPoolEnenmy = self.UI_CardPoolEnenmy,
        UI_CardPool = self.UI_CardPool
    }
    Enemy:SetData(param)
    self.round = 0 --奇数为我方回合，回合数小于等于20，第21回合进行结算展示
    -- 第一次的回合展示在玩家卡池初始化动画播放完毕后进行 UI_CardPoolPlayer中
    CommandMap:AddCommand("ShowRound", self, self.ShowRound)
    CommandMap:AddCommand("UIMainReset", self, self.Reset)
    CommandMap:AddCommand("UIStartRestart", self, self.Restart)

end

-- 展示并切换回合
function UI_Main:ShowRound()
    if self.round < 20 then --20个回合
        local text = ""
        local bCan = true
        if self.round%2 == 0 then
            bPlayer = true
            text = "我方回合"
            bCan = CheckSeasons(ECardOwner.Player)
            self.UI_CardPoolPlayer:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
        elseif self.round%2 == 1 then
            bPlayer = false
            text = "对手回合"
            self.UI_CardPoolPlayer:SetVisibility(ESlateVisibility.HitTestInvisible)
            bCan = CheckSeasons(ECardOwner.Player)
        end
        local param = {
            text = text,
            round = self.round,
            bCan = bCan
        }
        UIStack:PushUIByName("UI_Round", param)
        self.round = self.round + 1
    else
        local scores = CommandMap:DoCommand(CommandList.GetResultScores)
        local param = {
            playerScore = scores.playerScore,
            enemyScore = scores.enemyScore,
        }
        UIStack:PushUIByName("UI_GameResult", param)
    end
end

function UI_Main:Reset()
    --print("UI_Main Reset")
    self.round = 0 --奇数为我方回合，回合数小于等于20，第21回合进行结算展示

    self.UI_CardPoolPlayer:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.UI_CardPool:Reset()
    self.UI_CardPoolPlayer:Reset()
    self.UI_CardPoolEnenmy:Reset()
    self.UI_Score:Reset()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
    WashCards()     --洗牌
    self.UI_CardPool:FirstInitCards()       --第一次初始化公共卡池
    self.UI_CardPoolPlayer:FirstInitCards() --初次初始化玩家卡池
    self.UI_CardPoolEnenmy:FirstInitCards() --初次初始化敌人卡池
    local param = {
        UI_CardPoolEnenmy = self.UI_CardPoolEnenmy,
        UI_CardPool = self.UI_CardPool
    }
    Enemy:SetData(param)
end

function UI_Main:Restart()
    self.round = 0
    self.UI_CardPoolPlayer:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.UI_CardPool:Reset()
    self.UI_CardPoolPlayer:Reset()
    self.UI_CardPoolEnenmy:Reset()
    self.UI_Score:Reset()
    UIStack:PopUIByName("UI_Main")
    UIStack:PushUIByName("UI_Begin")
end

return UI_Main