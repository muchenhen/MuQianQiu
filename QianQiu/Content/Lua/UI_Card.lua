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
    if self.cardState == ECardState.UnChoose then
        self:PlayAnimation(self.PlayerChoose, 0, 1, 0, 1, false)
        self.cardState = ECardState.Choose
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
        CommandMap:DoCommand("CardDetailPlayShowIn", param)
        CommandMap:DoCommand("EnsureJustOneCardChoose", self.ID)
        if self.owner == ECardOwner.Player then
            CommandMap:DoCommand("OnPlayerCardChoose", self.ID)
        end
        print("Chosse card")
    elseif self.cardState == ECardState.Choose then
        self:PlayAnimation(self.PlayUnChoose, 0, 1, 0, 1, false)
        self.cardState = ECardState.UnChoose
        self.Img_CardChoose:SetVisibility(ESlateVisibility.Collapsed)
        CommandMap:DoCommand("CardDetailPlayShowOut")
        if self.owner == ECardOwner.Player then
            CommandMap:DoCommand("OnPlayerCardUnchoose", self.ID)
        end
        print("Unchose card")
    elseif self.owner == ECardOwner.PublicPool and self.cardState == ECardState.Choose then
        print(self.ID)
        local playChooseID = CommandMap:DoCommand("GetPlayerChooseID")
        print(playChooseID)
        -- OpenUI("UI_StoryShow")
    end
end

function UI_Card:OnCardHovered()
    local self = UI_Card
    if self.cardState == ECardState.UnChoose and self.cardOwner ~= ECardOwner.Enemy then
        self:PlayAnimation(self.PlayerHovered, 0, 1, 0, 1, false)
    end
end

function UI_Card:OnCardUnHovered()
    local self = UI_Card
    if self.cardState == ECardState.UnChoose and self.cardOwner ~= ECardOwner.Enemy then
        self:PlayAnimation(self.PlayerUnhovered, 0, 1, 0, 1, false)
    end
end

function UI_Card:UpdateSelf(param)
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
    if self.cardOwner == ECardOwner.Enemy then
        self.cardType = ECardType.Back
        local imgCard = LoadObject(UI_TEXTURE_BACK_PATH)
        self.Img_Card:SetBrushFromTexture(imgCard, false)
    else
        self.texturePath = self.cardType .. '/' .. Table.Cards[self.ID].Texture
        local imgCard = LoadObject(UI_TEXTURE_PATH .. self.texturePath)
        self.Img_Card:SetBrushFromTexture(imgCard, false)
    end
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

-- 设置选中状态 为玩家卡池设计 每次点击需要确保只有一张卡被选中
function UI_Card:SetChooseState(state)
    self.cardState = state
    if state == ECardState.UnChoose then
        self.Img_CardChoose:SetVisibility(ESlateVisibility.Collapsed)
        CommandMap:DoCommand("OnPlayerCardUnchoose", self.ID)
    end
end

-- 仅仅切换选中状态
function UI_Card:SetPublicChooseState(state)
    self.cardState = state
end

function UI_Card:SetOwner(owner)
    self.cardOwner = owner
end

return UI_Card