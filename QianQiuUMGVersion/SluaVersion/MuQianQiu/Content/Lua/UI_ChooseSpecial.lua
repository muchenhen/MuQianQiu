require("Global")

local UI_ChooseSpecial = {}

function UI_ChooseSpecial:Initialize()
    self.Button_Begin.OnClicked:Add(MakeCallBack(self.OnStartClick, self))

    self.TileView_SpecialCards.BP_OnEntryInitialized:Add(MakeCallBack(self.TileView_SpecialCards_OnEntryInitialized, self))

    self.AllSpecialCards = DataManager.GetAllSpecialCardDatas()
    -- self.TileView_SpecialCards.
    -- AllSpecialCards:Num()
    for i=0, self.AllSpecialCards:Num()-1 do
        local CardData = self.AllSpecialCards:Get(i)
        local NewCard = MuBPFunction.CreateUserWidget("UI_Card")
        NewCard:SetCardID(CardData.CardID)
        self.TileView_SpecialCards:AddItem(NewCard)
    end
end

function UI_ChooseSpecial:OnCardClick(Card)
    if Card.bChoosed then
        Card:SetChooseState(false, false)
    else
        Card:SetChooseState(true, false)
    end
end

function UI_ChooseSpecial:OnStartClick()
    local UI_GameMain = MuBPFunction.CreateUserWidget("UI_GameMain")
    UI_GameMain:AddToViewport(0)
    self:SetVisibility(ESlateVisibility.Hidden)
end

function UI_ChooseSpecial:TileView_SpecialCards_OnEntryInitialized(Item, Widget)
    Widget:SetCardID(Item.CardID)
    Widget:AddOnClickEvent(MakeCallBack(self.OnCardClick, self))
end

function UI_ChooseSpecial:OnDestroy()

end

return Class(nil, nil, UI_ChooseSpecial)