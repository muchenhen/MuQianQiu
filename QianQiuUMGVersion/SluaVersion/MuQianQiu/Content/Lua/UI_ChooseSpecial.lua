require("Global")

local UI_ChooseSpecial = {}

function UI_ChooseSpecial:Initialize()
    self.Button_Begin.OnClicked:Add(MakeCallBack(self.OnStartClick, self))

    self.TileView_SpecialCards.BP_OnEntryInitialized:Add(MakeCallBack(self.TileView_SpecialCards_OnEntryInitialized, self))
    self.TileView_SpecialCards.BP_OnItemClicked:Add(MakeCallBack(self.TileView_SpecialCards_OnItemClicked, self))


    self.AllSpecialCards = DataManager.GetAllSpecialCardDatas()
    for i=0, self.AllSpecialCards:Num()-1 do
        local CardData = self.AllSpecialCards:Get(i)
        local NewCard = MuBPFunction.CreateUserWidget("UI_Card")
        NewCard.Button:SetVisibility(ESlateVisibility.Hidden)
        NewCard:SetCardID(CardData.CardID)
        self.TileView_SpecialCards:AddItem(NewCard)
    end

    self.ChoosedCards = {}
end

--- 选择一张特殊牌，检查是否可选：同一人物不能选择超过一张。累计不能超过十张
---@param Card any
function UI_ChooseSpecial:ChooseCard(Card)
    self.UI_CardDetail:SetVisibility(ESlateVisibility.HitTestInvisible)
    self.UI_CardDetail:SetCardID(Card.CardID)
    if Card.bChoosed then
        Card:SetChooseState(false, false)
        for i=1, #self.ChoosedCards do
            if self.ChoosedCards[i] == Card then
                table.remove(self.ChoosedCards, i)
                break
            end
        end
    else
        if #self.ChoosedCards >= 10 then
            print("最多选择10张特殊牌")
            return
        end
        for i=1, #self.ChoosedCards do
            if self.ChoosedCards[i].SpecialName == Card.SpecialName then
                local UI_Tip = MuBPFunction.CreateUserWidget("UI_Tip")
                UI_Tip:AddToViewport(0)
                UI_Tip:ShowTip("同一角色只能选择一张特殊牌")
                print("同一角色只能选择一张特殊牌")
                return
            end
        end
        Card:SetChooseState(true, false)
        table.insert(self.ChoosedCards, Card)
    end
end

function UI_ChooseSpecial:OnStartClick()
    GameManager.PlayerASpecialCards = self.ChoosedCards
    print("特殊牌选择完毕")
    local UI_GameMain = MuBPFunction.CreateUserWidget("UI_GameMain")
    UI_GameMain:AddToViewport(0)
    self:SetVisibility(ESlateVisibility.Hidden)
end

function UI_ChooseSpecial:TileView_SpecialCards_OnEntryInitialized(Item, Widget)
    Widget.Button:SetVisibility(ESlateVisibility.Hidden)
    Widget:SetCardID(Item.CardID)
    Widget:SetChooseState(Item.bChoosed, false)
end

function UI_ChooseSpecial:TileView_SpecialCards_OnItemClicked(Item)
    self:ChooseCard(Item)
    self.TileView_SpecialCards:RegenerateAllEntries()
end

function UI_ChooseSpecial:OnDestroy()

end

return Class(nil, nil, UI_ChooseSpecial)