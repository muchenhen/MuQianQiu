local UI_StoryShow = ui("UI_StoryShow")

function UI_StoryShow:Construct()

end

function UI_StoryShow:Initialize()
    CommandMap:AddCommand("PlayStoryShowOut", self, self.PlayStoryShowOut)

    if bPlayer then
        CommandMap:DoCommand(CommandList.SetStoryShowTickPlayer, false)
    else
        CommandMap:DoCommand(CommandList.SetStoryShowTickEnemy, false)
    end
    self:PlayAnim(self.ShowIn)
    self.bAutoClose = false
end

function UI_StoryShow:PlayStoryShowOut()
    if not self.ShowOut then
        print(self.ShowOut)
    end
    self:PlayAnim(self.ShowOut)
end

function UI_StoryShow:OnAnimationFinished(anim)
    if anim == self.ShowOut then
        self:RemoveFromParent()
        if bPlayer then
            CommandMap:DoCommand(CommandList.SetStoryShowTickPlayer, true)
        else
            CommandMap:DoCommand(CommandList.SetStoryShowTickEnemy, true)
        end
    elseif anim == self.ShowIn and self.bAutoClose then
        self:PlayStoryShowOut()
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
        local card = CreateUI("Card/UI_Card")
        self.Cards:AddChild(card)
        card:UpdateSelf(cardsID[i])
        card:SetPadding(self.CardPadding)
    end
    if param.Audio ~= '' and bPlayAudio then
        CommandMap:DoCommand("SetSelfAudioAndPlay", param.Audio)
    else
        self.bAutoClose = true
    end
end

function UI_StoryShow:OnDestroy()

end

return UI_StoryShow