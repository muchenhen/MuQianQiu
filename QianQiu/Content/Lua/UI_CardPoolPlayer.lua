require "Global"

local UI_CardPoolPlayer = {}

function UI_CardPoolPlayer:Construct()
    CommandMap:AddCommand("GetPlayerChooseID", self, self.GetPlayerChooseID)
    CommandMap:AddCommand("PopAndPushOneCardForPlayer", self, self.PopAndPushOneCardForPlayer)
    CommandMap:AddCommand("PopOneCardForPlayer", self, self.PopOneCardForPlayer)
    CommandMap:AddCommand("CheckPlayerSeason", self, self.CheckPlayerSeason)
    CommandMap:AddCommand("SetAllCardsbCanPlayer", self, self.SetAllCardsbCanPlayer)
    CommandMap:AddCommand("PrintAllCards", self, self.PrintAllCards)
end

function UI_CardPoolPlayer:Initialize()
    for i = 0, 9 do
        self["UI_CardPlayer_C_" .. i]:SetRenderTranslation(self.trans * i)
    end
end

function UI_CardPoolPlayer:GetPlayerChooseID()
    local cards = self.HaveCards:GetAllChildren()
    for key, value in pairs(cards) do
        local cardID = value.ID
        print(cardID, Cards[cardID].Name)
        if value.cardState == ECardState.Choose then
            return cardID
        end
    end
end

function UI_CardPoolPlayer:FirstInitCards()
    self.Cards = RandomCards(10)
    local cards = self.HaveCards:GetAllChildren()
    local i = 0
    for key, card in pairs(cards) do
        card:UpdateSelf(self.Cards[i + 1])
        card:PlayAnimation(self.PlayUnChoose, 0, 1, 0, 1, false)
        i = i + 1
    end
    self:PlayAnimation(self.FirstInit, 0, 1, 0, 1, false)
    --print("玩家卡池初始化完毕")
end

function UI_CardPoolPlayer:PopOneCardForPlayer()
    -- local playerHaveID = ID
    local self = UI_CardPoolPlayer
    local cards = self.HaveCards:GetAllChildren()
    for key, value in pairs(cards) do
        if value.state == ECardState.Choose then
            value:SetVisibility(ESlateVisibility.Hidden)
            break
        end
    end
end

function UI_CardPoolPlayer:PopAndPushOneCardForPlayer(ID)
    local playerHaveID = ID
    local cards = self.HaveCards:GetAllChildren()
    for key, card in pairs(cards) do
        local cardVisibility = card:GetVisibility()
        card.cardState = ECardState.Choose
        if card.ID == playerHaveID and cardVisibility ~= ESlateVisibility.Hidden then
            local newCardID = ChangeCard(playerHaveID)[1]
            print("玩家用卡牌", Cards[playerHaveID].Name, "交换出了", Cards[newCardID].Name)
            -- print("玩家新生成卡牌：", Cards[newCardID].Name)
            for i = 1, #self.Cards do
                if self.Cards[i] == playerHaveID then
                    self.Cards[i] = newCardID
                end
            end
            card:UpdateSelf(newCardID)
            if CheckSeasons(ECardOwner.Player) then
                UIStack:PopUIByName("UI_StaticTip")
                CommandMap:DoCommand(CommandList.SetAllCardsbCanPlayer, true)
            end
            break
        end
    end
end

function UI_CardPoolPlayer:OnAnimationFinished(anim)
    if anim == self.FirstInit then
        CommandMap:DoCommand(CommandList.ShowRound)
    end
end

function UI_CardPoolPlayer:CheckPlayerSeason()
    PlayerSeason[ECardSeason.Spring] = false
    PlayerSeason[ECardSeason.Summer] = false
    PlayerSeason[ECardSeason.Autumn] = false
    PlayerSeason[ECardSeason.Winter] = false
    local cards = self.HaveCards:GetAllChildren()
    for key, card in pairs(cards) do
        if card:GetVisibility() ~= ESlateVisibility.Hidden then
            local season = Table.Cards[card.ID].Season
            PlayerSeason[ESeason[season]] = true
        end
    end
end

function UI_CardPoolPlayer:SetAllCardsbCanPlayer(bCan)
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum - 1 do
        local card = self.HaveCards:GetChildAt(i)
        card:SetbCan(bCan)
    end
end

function UI_CardPoolPlayer:PrintAllCards()
    local cards = self.HaveCards:GetAllChildren()
    for key, card in pairs(cards) do
        local cardID = card.ID
        print(cardID, Cards[cardID].Name)
    end
end

function UI_CardPoolPlayer:Reset()
    local cards = self.HaveCards:GetAllChildren()
    for key, value in pairs(cards) do
        value:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end
end

return UI_CardPoolPlayer
