require "Global"

local UI_CardPoolPlayer = {}

function UI_CardPoolPlayer:Construct()
    CommandMap:AddCommand("EnsureJustOneCardChoose",self, self.UpdateChooseState)
    CommandMap:AddCommand("GetPlayerChooseID",self, self.GetPlayerChooseID)
    CommandMap:AddCommand("PopAndPushOneCardForPlayer", self, self.PopAndPushOneCardForPlayer)
    CommandMap:AddCommand("PopOneCardForPlayer", self, self.PopOneCardForPlayer)
    CommandMap:AddCommand("CheckPlayerSeason", self, self.CheckPlayerSeason)
    CommandMap:AddCommand("SetAllCardsbCanPlayer", self, self.SetAllCardsbCanPlayer)
end

function UI_CardPoolPlayer:Initialize()
    
end

function UI_CardPoolPlayer:UpdateChooseState(ID)
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        local cardID = card:GetID()
        if ID ~= cardID and card.cardState == ECardState.Choose then
            card:PlayAnimation(card.PlayDown, 0, 1, 0, 1, false)
            card:SetChooseState(ECardState.UnChoose)
        end
    end
end

function UI_CardPoolPlayer:GetPlayerChooseID()
    local cards = self.HaveCards:GetAllChildren()
    for key, value in pairs(cards) do
        local cardID = value:GetID()
        if value.cardState == ECardState.Choose then
            return cardID
        end
    end
end

function UI_CardPoolPlayer:FirstInitCards()
    self.Cards = RandomCards(10)
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        local param = {
            ID = self.Cards[i+1], --临时修改为1 原为i+1 用来测试没有对应季节的边界情况
            cardOwner = ECardOwner.Player,
            cardPosition = ECardPostion.OnHand,
        }
        card:UpdateSelf(param)
        card:PlayAnimation(self.PlayUnChoose, 0, 1, 0, 1, false)
    end
    self:PlayAnimation(self.FirstInit, 0, 1, 0, 1, false)
    print("玩家卡池初始化完毕")
end

function UI_CardPoolPlayer:PopOneCardForPlayer(param)
    local playerHaveID = param.PlayerHaveID
    local cards = self.HaveCards:GetAllChildren()
    for key, value in pairs(cards) do
        if value.ID == playerHaveID then
            value:PlayAnimation(value.PlayUnChoose, 0, 1, 0, 1, false)
            value:SetCardVisibile(ESlateVisibility.Hidden)
            break
        end
    end
end

function UI_CardPoolPlayer:PopAndPushOneCardForPlayer(param)
    local playerHaveID = param.PlayerHaveID
    local cards = self.HaveCards:GetAllChildren()
    for key, card in pairs(cards) do
        if card.ID == playerHaveID then
            local newCardID = ChangeCard(playerHaveID)[1]
            print("玩家用卡牌", Cards[playerHaveID].Name, "交换出了", Cards[newCardID].Name)
            -- print("玩家新生成卡牌：", Cards[newCardID].Name)
            for i=1, #self.Cards do
                if self.Cards[i] == playerHaveID then
                    self.Cards[i] = newCardID
                end
            end
            local param  = {
                ID = newCardID,
                cardOwner = ECardOwner.Player,
                cardPosition = ECardPostion.OnHand,
            }
            card:UpdateSelf(param)
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
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        PlayerSeason[ESeason[card.season]] = true
    end
end

function UI_CardPoolPlayer:SetAllCardsbCanPlayer(param)
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        card:SetbCan(param.bCan)
    end
end

function UI_CardPoolPlayer:Reset()
    local cards = self.HaveCards:GetAllChildren()
    for key, value in pairs(cards) do
        local param  = {
            cardOwner = ECardOwner.Player,
            cardPosition = ECardPostion.OnHand,
        }
        value:UpdateSelf(param)
        value:SetCardVisibile(ESlateVisibility.SelfHitTestInvisible)
    end
end

return UI_CardPoolPlayer