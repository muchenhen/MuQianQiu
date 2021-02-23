require "Global"

local UI_Card = {}

function UI_Card:Initialize()

end

function UI_Card:Construct()
    -- 初始化状态
    self.state = ECardState.UnChoose -- 选中状态
    self.publicCardState = EPublicCardState.Normal
    -- 卡牌点击
    self.Button_Card.OnClicked:Add(function()
        if not self.bCanClick then
            return
        end
        if self.publicCardState == EPublicCardState.ReadyChoose then
            self:PlayAnimation(self.PlayerChoose, 0, 1, 0, 1, false)
        elseif self.state == ECardState.UnChoose and self.publicCardState == EPublicCardState.Normal then
            self:PlayAnimation(self.PlayerChoose, 0, 1, 0, 1, false)
            self.state = ECardState.Choose
            self.Img_CardChoose:SetVisibility(ESlateVisibility.HitTestInvisible)
            local param = {
                id = self.ID,
                bPlayer = true,
                state = ECardState.UnChoose,
                season = self.season,
                score = self.score,
                type = self.type,
                bSpecial = self.bSpecial,
                bCanClick = false,
                cardDetail = self.cardDetail,
                texturePath = self.texturePath
            }
            CommandMap:DoCommand("CardDetailPlayShowIn", param)
            CommandMap:DoCommand("EnsureJustOneCardChoose", self.ID)
            CommandMap:DoCommand("OnPlayerCardChoose", self.ID)
            -- print("Chosse card")
        elseif self.state == ECardState.Choose and self.publicCardState == EPublicCardState.Normal then
            self:PlayAnimation(self.PlayUnChoose, 0, 1, 0, 1, false)
            self.state = ECardState.UnChoose
            self.Img_CardChoose:SetVisibility(ESlateVisibility.Collapsed)
            CommandMap:DoCommand("CardDetailPlayShowOut")
            CommandMap:DoCommand("OnPlayerCardUnchoose", self.ID)
            -- print("Unchose card")
        end
    end)
    -- 鼠标经过
    self.Button_Card.OnHovered:Add(function ()
        if self.state == ECardState.UnChoose and self.bCanHovered then
            self:PlayAnimation(self.PlayerHovered, 0, 1, 0, 1, false)
            -- print("OnUnHovered card")
        end
    end)
    -- 鼠标离开
    self.Button_Card.OnUnhovered:Add(function ()
        if self.state == ECardState.UnChoose and self.bCanHovered then
            self:PlayAnimation(self.PlayerUnhovered, 0, 1, 0, 1, false)
            -- print("OnUnHovered card")
        end
    end)
end

function UI_Card:UpdateSelf(param)
    self.bPlayer = param.bPlayer
    self.state = param.state
    self.season = param.season
    self.score = param.score
    self.type = param.type
    self.bSpecial = param.bSpecial
    self.bCanClick = param.bCanClick
    self.cardDetail = param.cardDetail
    self.texturePath = param.texturePath
    self:UpdateCard()
end

function UI_Card:UpdateSelfByID(ID, bPlayer)
    self.ID = ID
    self.bPlayer = bPlayer
    self.state = ECardState.UnChoose -- 选中状态
    self.season = Table.Cards[self.ID].Season -- 卡面属性
    self.score = Table.Cards[self.ID].Value -- 卡片分数
    self.type = Table.Cards[self.ID].Type -- 卡面类型
    self.bSpecial = Table.Cards[self.ID].Special == 1 -- 是否是特殊卡
    if self.bSpecial then
        self.specialID = tonumber(Table.Cards[self.ID].SpecialName)
    else
        self.specialID = self.ID
    end
    self.bCanClick = true -- 是否可以点击
    self.cardDetail = Table.Cards[self.ID].Describe
    self.texturePath = "/" .. Table.Cards[self.ID].Texture
    self:UpdateCard()
end

function UI_Card:UpdateCard()
    if not self.bCanClick then
        self.Button_Card:SetVisibility(ESlateVisibility.HitTestInvisible)
    end

    if self.bPlayer then
        local imgCard = LoadObject(UI_TEXTURE_PATH .. self.type .. self.texturePath)
        self.Img_Card:SetBrushFromTexture(imgCard, false)
    else
        local imgCard = LoadObject(UI_TEXTURE_BACK_PATH)
        self.Img_Card:SetBrushFromTexture(imgCard, false)
    end

end

function UI_Card:SetClick(bCanClick)
    self.bCanClick = bCanClick
    self:UpdateCard()
end

function UI_Card:SetHovered(bCanHovered)
    self.bCanHovered = bCanHovered
    self:UpdateCard()
end

function UI_Card:SetPlayer(bPlayer)
    self.bPlayer = bPlayer
    self:UpdateCard()
end

function UI_Card:GetID()
    return self.ID
end

function UI_Card:GetSeason()
    return self.Season
end

function UI_Card:SetChooseState(state)
    self.state = state
    if state == ECardState.UnChoose then
        self.Img_CardChoose:SetVisibility(ESlateVisibility.Collapsed)
        CommandMap:DoCommand("OnPlayerCardUnchoose", self.ID)
    end
end

function UI_Card:SetPublicState(state)
    self.publicCardState = state
end

return UI_Card