require "Global"
local UI_StoryShow = {}

function UI_StoryShow:Construct()

end

function UI_StoryShow:Initialize()
    CommandMap:AddCommand("PlayStoryShowOut", self, self.PlayStoryShowOut)

    if bPlayer then
        CommandMap:DoCommand(CommandList.SetStoryShowTickPlayer, false)
    else
        CommandMap:DoCommand(CommandList.SetStoryShowTickEnemy, false)
    end
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
    
end

function UI_StoryShow:PlayStoryShowOut()
    self:PlayAnimation(self.ShowOut, 0, 1, 0, 1, false)
end

function UI_StoryShow:OnAnimationFinished(anim)
    if anim == self.ShowOut then
        self:RemoveFromParent()
        if bPlayer then
            CommandMap:DoCommand(CommandList.SetStoryShowTickPlayer, true)
        else
            CommandMap:DoCommand(CommandList.SetStoryShowTickEnemy, true)
        end
    end
end

function UI_StoryShow:UpdateSelf(param)
    if not param then
        return
    end
    self.Text_StoryName:SetText(param.Name)
    self.Text_Score:SetText(param.Score)
    self.Cards:ClearChildren()
    local cardsID = param.Cards
    for i=1, #cardsID do
        local card = CreateUI("UI_Card")
        local param = {
            ID = cardsID[i],
            cardPosition = ECardPostion.OnStory,
            cardOwner = ECardOwner.Player,
            state = ECardState.UnChoose,
        }
        self.Cards:AddChild(card)
        card:UpdateSelf(param)
        card:SetPadding(self.CardPadding)
    end
    if param.Audio then
        CommandMap:DoCommand("SetSelfAudioAndPlay", param.Audio)
    end
end

function UI_StoryShow:OnDestroy()

end

return UI_StoryShow