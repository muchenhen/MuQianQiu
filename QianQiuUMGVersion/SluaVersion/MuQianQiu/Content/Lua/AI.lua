require("Enums")

AIPlayer = {}

AIPlayer.bAIMode = true

AIPlayer.Mode = EAIMode.Easy

AIPlayer.Cards = {}
AIPlayer.PCards = {}

AIPlayer.ReadyToChoosePCard = nil

function AIPlayer:DoAction()
    if self.Mode == EAIMode.Easy then
        self:DoActionEasy()
    end
end

function AIPlayer:DoActionEasy()
    -- 简单模式直接按顺序点击 但是每张牌要去检查Season，当前P区是否有相同Season的牌，没有的话选择下一张
    if not self.AIChoosing then
        -- AI 当前没有选择手牌
        if not GameManager.PLayerBChangingCard then
            for i = 1, #self.Cards do
                local Card = self.Cards[i]
                if Card.CardOwner == ECardOwnerType.PlayerB then
                    local bHasSameSeasonCard = false
                    for j = 1, #self.PCards do
                        local PCard = self.PCards[j]
                        if PCard.Season == Card.Season then
                            AIPlayer.ReadyToChoosePCard = PCard
                            bHasSameSeasonCard = true
                            break
                        end
                    end
                    if bHasSameSeasonCard then  
                        Card:OnClick()
                        break
                    end
                end
            end
        else
            -- AI 当前正在选择换牌 按顺序选择
            for i = 1, #self.Cards do
                local Card = self.Cards[i]
                if Card.CardOwner == ECardOwnerType.PlayerB then
                    Card:OnClick()
                    break
                end
            end
        end
    -- 当前AI已经选择了一张牌
    else
        if self.ReadyToChoosePCard then
            self.ReadyToChoosePCard:OnClick()
            self.ReadyToChoosePCard = nil
        end
    end
end