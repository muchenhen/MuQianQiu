require "Global"

local UI_Card = {}

function UI_Card:Initialize()

end

function UI_Card:Construct()
    -- 初始化状态
    self.bPlayer = true
    self.state = ECardState.UnChoose -- 选中状态
    self.season = ECardSeason.Spring -- 卡面属性
    self.score = 2 -- 卡片分数
    self.type = ECardType.Char -- 卡面类型
    self.bSpecial = false -- 是否是特殊卡
    self.bCanClick = true -- 是否可以点击
    self.cardDetail = "既出丹渊交光夜，凝雾点漆逸流萤。"
    self.texturePath = "/" .. "Tex_Char_YunWuYue_HuaShang"
    -- 初始化卡面
    self:UpdateCard()

    -- 卡牌点击
    self.Button_Card.OnClicked:Add(function()
        if not self.bCanClick then
            return
        end
        if self.state == ECardState.UnChoose then
            self:PlayAnimation(self.PlayerChoose, 0, 1, 0, 1, false)
            self.state = ECardState.Choose
            local param = {
                bPlayer = true,
                state = ECardState.UnChoose,
                season = ECardSeason.Spring,
                score = 2,
                type = ECardType.Char,
                bSpecial = false,
                bCanClick = true,
                cardDetail = "既出丹渊交光夜，凝雾点漆逸流萤。",
                texturePath = "/" .. "Tex_Char_YunWuYue_HuaShang"
            }
            CommandMap:DoCommand("CardDetailPlayShowIn", param)
            -- print("Chosse card")
        elseif self.state == ECardState.Choose then
            self:PlayAnimation(self.PlayUnChoose, 0, 1, 0, 1, false)
            self.state = ECardState.UnChoose
            CommandMap:DoCommand("CardDetailPlayShowOut")
            -- print("Unchose card")
        end
    end)
    -- 鼠标经过
    self.Button_Card.OnHovered:Add(function ()
        if self.state == ECardState.UnChoose then
            self:PlayAnimation(self.PlayerHovered, 0, 1, 0, 1, false)
            -- print("OnUnHovered card")
        end
    end)
    -- 鼠标离开
    self.Button_Card.OnUnhovered:Add(function ()
        if self.state == ECardState.UnChoose then
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
end

function UI_Card:SetPlayer(bPlayer)
    self.bPlayer = bPlayer
    self:UpdateCard()
end

return UI_Card