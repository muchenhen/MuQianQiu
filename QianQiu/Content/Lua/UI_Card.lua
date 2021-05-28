require "Global"

local UI_Card = {}

function UI_Card:Initialize()

end

function UI_Card:Construct()
    -- 初始化状态
    -- self.ID = 204
    -- self.cardState = ECardState.UnChoose -- 选中状态
    -- self.publicCardState = EPublicCardState.Normal -- 未激活的状态/已经被激活准备被带走的状态
    -- self.cardOwner = ECardOwner.Player -- 拥有者 公共卡池/玩家/对手
    -- self.cardPosition = ECardPostion.OnHand -- 所在位置 手中/已经组成故事
    -- self.cardType = Table.Cards[self.ID].Type -- 卡面类型 用于索引贴图路径

    --#region 卡片的固有属性
    -- self.season = ECardSeason.Spring -- 卡面属性
    -- self.value = 4 -- 卡片分数
    -- self.bSpecial = (Table.Cards[self.ID].Special == 1) -- 是否是特殊卡
    --#endregion

    -- 卡牌点击
    self.Button_Card.OnClicked:Add(self.OnCardClick)
    -- 鼠标经过
    self.Button_Card.OnHovered:Add(self.OnCardHovered)
    -- 鼠标离开
    self.Button_Card.OnUnhovered:Add(self.OnCardUnHovered)
end

function UI_Card:OnCardClick()
    local self = UI_Card
    if self.bCan then
        if (self.cardState == ECardState.UnChoose
            and self.cardOwner ~= ECardOwner.Enemy
            and self.cardOwner ~= ECardOwner.Detail) then
            self:PlayAnimation(self.PlayerChoose, 0, 1, 0, 1, false)
            self.Img_CardChoose:SetVisibility(ESlateVisibility.HitTestInvisible)
            local param = {
                ID = self.ID,
                state = ECardState.UnChoose,
                season = self.season,
                score = self.value,
                type = self.cardType,
                bSpecial = self.bSpecial,
                cardDetail = self.cardDetail,
                texturePath = self.texturePath
            }
            UIStack:PushUIByName("UI_CardDetail",param)
            CommandMap:DoCommand(CommandList.EnsureJustOneCardChoose, self.ID)
            if self.cardOwner == ECardOwner.Player then
                CommandMap:DoCommand(CommandList.OnPlayerCardChoose, self.ID)
            end
        elseif (self.cardState == ECardState.Choose
            and self.cardOwner == ECardOwner.Player) then
            self:PlayAnimation(self.PlayUnChoose, 0, 1, 0, 1, false)
            self.Img_CardChoose:SetVisibility(ESlateVisibility.Collapsed)
            UIStack:PopUIByName("UI_CardDetail", true)
            if self.cardOwner == ECardOwner.Player then
                CommandMap:DoCommand(CommandList.OnPlayerCardUnchoose, self.ID)
            end
        elseif (self.cardState == ECardState.Choose
            and self.cardOwner == ECardOwner.PublicPool) then
            local playChooseID = CommandMap:DoCommand(CommandList.GetPlayerChooseID)
            if playChooseID then
                print(playChooseID, Cards[playChooseID].Name)
                print(self.ID,  Cards[self.ID].Name)
                local param = {
                    PlayerHaveID = playChooseID,
                    PlayerChooseID = self.ID
                }
                UIStack:PopUIByName("UI_CardDetail")
                CommandMap:DoCommand(CommandList.UpdatePlayerScore, param)
                CommandMap:DoCommand(CommandList.UpdatePlayerHeal, param)
                CommandMap:DoCommand(CommandList.PopAndPushOneCardForPublic, param)
                CommandMap:DoCommand(CommandList.PopOneCardForPlayer, param)
            else
                self:PlayAnimation(self.PlayUnChoose, 0, 1, 0, 1, false)
                self.Img_CardChoose:SetVisibility(ESlateVisibility.Collapsed)
                UIStack:PopUIByName("UI_CardDetail")
            end
        end
    else
        self.cardState = ECardState.Choose
        print("丢弃手牌并重新获得")
        local playChooseID = CommandMap:DoCommand(CommandList.GetPlayerChooseID)
        if playChooseID then
            local param = {
                PlayerHaveID = playChooseID,
                PlayerChooseID = self.ID
            }
            CommandMap:DoCommand(CommandList.PopAndPushOneCardForPlayer, param)
            if CheckSeasons(ECardOwner.Player) then
                local param = {
                    bCan = true
                }
                CommandMap:DoCommand(CommandList.SetAllCardsbCanPlayer, param)
                UIStack:PopUIByName("UI_StaticTip")
            else
                local param = {
                    bCan = false
                }
                CommandMap:DoCommand(CommandList.SetAllCardsbCanPlayer, param)
            end
        end
    end
end

function UI_Card:OnCardHovered()
    local self = UI_Card
    -- if self.cardState == ECardState.UnChoose and self.cardOwner ~= ECardOwner.Enemy then
    --     self:PlayAnimation(self.PlayerHovered, 0, 1, 0, 1, false)
    -- end
end

function UI_Card:OnCardUnHovered()
    local self = UI_Card
    -- if self.cardState == ECardState.UnChoose and self.cardOwner ~= ECardOwner.Enemy then
    --     self:PlayAnimation(self.PlayerUnhovered, 0, 1, 0, 1, false)
    -- end
end

function UI_Card:UpdateSelf(param)
    self.bCan = true
    if param.ID then
        self.ID = param.ID
    else
        self.ID = 204
    end

    if param.cardPosition then -- 卡片位置
        self.cardPosition = param.cardPosition
    else
        self.cardPosition = ECardPostion.OnHand
    end

    if param.cardOwner then -- 卡片归属
        self.cardOwner = param.cardOwner
    else
        self.cardOwner = ECardOwner.Detail
    end

    if param.state then -- 选中状态
        self.cardState = param.state
    else
        self.cardState = ECardState.UnChoose
    end

    if param.cardType then -- 卡面类型
        self.cardType = param.cardType
    else
        self.cardType = Table.Cards[self.ID].Type
    end

    -- if self.cardOwner == ECardOwner.Enemy then
        -- self.cardType = ECardType.Back
        -- local imgCard = LoadObject(UI_TEXTURE_BACK_PATH)
        -- self.Img_Card:SetBrushFromTexture(imgCard, false)
    -- else
        self.texturePath = self.cardType .. '/' .. Table.Cards[self.ID].Texture
        local imgCard = LoadObject(UI_TEXTURE_PATH .. self.texturePath)
        self.Img_Card:SetBrushFromTexture(imgCard, false)
    -- end

    self.season = Table.Cards[self.ID].Season -- 卡面属性
    self.value = Table.Cards[self.ID].Value -- 卡片分数
    self.bSpecial = (Table.Cards[self.ID].Special == 1) -- 是否是特殊卡

    if self.bSpecial then
        self.specialID = tonumber(Table.Cards[self.ID].SpecialName)
    else
        self.specialID = self.ID
    end

    self.cardDetail = Table.Cards[self.ID].Describe

end

function UI_Card:GetID()
    return self.ID
end

function UI_Card:GetSeason()
    return self.Season
end

function UI_Card:SetbCan(bCan)
    self.bCan = bCan
end

-- 设置选中状态 为玩家卡池设计 每次点击需要确保只有一张卡被选中
function UI_Card:SetChooseState(state)
    self.cardState = state
    if state == ECardState.UnChoose then
        self.Img_CardChoose:SetVisibility(ESlateVisibility.Collapsed)
        CommandMap:DoCommand(CommandList.OnPlayerCardUnchoose, self.ID)
    end
end

-- 根据当前状态和目标状态进行动画播放和状态更新
function UI_Card:SetCardState(state)
    if self.cardState == ECardState.Choose and state == ECardState.UnChoose then
        self:RefreshStateFromChooseToUnChoose()
    elseif self.cardState == ECardState.UnChoose and state == ECardState.Choose then
        self:PlayAnimation(self.PlayerChoose, 0, 1, 0, 1, false)
    end
end

-- 从选中到未选中的状态需要执行的操作
function UI_Card:RefreshStateFromChooseToUnChoose()
    self:PlayAnimation(self.PlayUnChoose, 0, 1, 0, 1, false)
    self:PlayAnimation(self.PlayerUnhovered, 0, 1, 0, 1, false)
    self.Img_CardChoose:SetVisibility(ESlateVisibility.Collapsed)
end

-- 仅仅切换选中状态
function UI_Card:SetPublicChooseState(state)
    self.cardState = state
end

function UI_Card:SetOwner(owner)
    self.cardOwner = owner
end

function UI_Card:OnDestroy()

end

function UI_Card:OnAnimationFinished(anim)
    if anim == self.PlayerChoose then
        self.cardState = ECardState.Choose
    elseif anim == self.PlayUnChoose then
        self.cardState = ECardState.UnChoose
    end
end

function UI_Card:SetCardVisibile(visibility)
    self:SetVisibility(visibility)
end


function UI_Card:GetCardVisibility()
    return self:GetVisibility()
end


return UI_Card