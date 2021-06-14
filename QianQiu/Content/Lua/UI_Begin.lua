require "Global"
local UI_Begin = {}

function UI_Begin:Initialize()
    --print("牌库选择1+2")
    self.Button_Begin.OnClicked:Add(self.OnStartClick)
    StoryOne = true
    StoryTwo = true
    StoryThree = false
end

function UI_Begin:Construct()
    self.currSwitch = 1
    self.model = 4
    self.bDark = true
    self.Button_OneTwo.OnClicked:Add(self.OnOneTwoClick)
    self.Button_TwoThree.OnClicked:Add(self.OnTwoThreeClick)
    self.Button_OneThree.OnClicked:Add(self.OnOneThreeClick)
    self.Button_Normal.OnClicked:Add(self.OnNormalClick)
    self.Button_Monster.OnClicked:Add(self.OnMonsterClick)
    self.Button_OnlyMonster.OnClicked:Add(self.OnOnlyMonsterClick)
    self.Button_Dark.OnClicked:Add(self.OnDarkClick)
    self.Button_Light.OnClicked:Add(self.OnLightClick)
    self.Button_Slience.OnClicked:Add(self.OnSlienceClick)
    self.Button_Voice.OnClicked:Add(self.OnVoiceClick)

    --print(GameplayStatics.GetPlatformName())
end

function UI_Begin:OnOneTwoClick()
    local self = UI_Begin
    self:PlaySwitch(1)
    self.currSwitch = 1
    StoryOne = true
    StoryTwo = true
    StoryThree = false
    --print("牌库选择1+2")
end

function UI_Begin:OnTwoThreeClick()
    local self = UI_Begin
    self:PlaySwitch(2)
    self.currSwitch = 2
    StoryOne = false
    StoryTwo = true
    StoryThree = true
    --print("牌库选择2+3")
end

function UI_Begin:OnOneThreeClick()
    local self = UI_Begin
    self:PlaySwitch(3)
    self.currSwitch = 3
    StoryOne = true
    StoryTwo = false
    StoryThree = true
    --print("牌库选择1+3")
end

function UI_Begin:OnNormalClick()
    local self = UI_Begin
    if self.model == 4 then
        return
    end
    self:PlaySwitch(4)
    self.model = 4
    bNormalStory = true
    bStoryExtra = false
    print("模式选择：普通模式")
end

function UI_Begin:OnMonsterClick()
    local self = UI_Begin
    self:PlaySwitch(5)
    self.model = 5
    bNormalStory = true
    bStoryExtra = true
    print("模式选择：撒野模式")
end

function UI_Begin:OnOnlyMonsterClick()
    local self = UI_Begin
    self:PlaySwitch(6)
    self.model = 6
    bNormalStory = false
    bStoryExtra = true
    print("模式选择：仅撒野模式")
end

function UI_Begin:OnDarkClick()
    local self = UI_Begin
    if self.bDark then
        return
    end
    self.bDark = true
    bEnemyDark = self.bDark
    self:PlaySwitch(7)
    --print("对手暗牌")
end

function UI_Begin:OnLightClick()
    local self = UI_Begin
    if not self.bDark then
        return
    end
    self.bDark = false
    bEnemyDark = self.bDark
    self:PlaySwitch(8)
    --print("对手明牌")
end

function UI_Begin:OnStartClick()
    local self = UI_Begin
    InitAllStory()
    UIStack:PushUIByName("UI_Main")
    self:RemoveFromViewport()
end

function UI_Begin:OnSlienceClick()
    local self = UI_Begin
    if bPlayAudio then
        bPlayAudio = false
        self:PlaySwitch(10)
    end
end

function UI_Begin:OnVoiceClick()
    local self = UI_Begin
    if not bPlayAudio then
        bPlayAudio = true
        self:PlaySwitch(9)
    end
end

function UI_Begin:PlaySwitch(aim)
    if self.currSwitch == 1 and aim == 2 then
        self:PlayAnimation(self.A12, 0, 1, 0, 1, false)
    elseif self.currSwitch == 1 and aim == 3 then
        self:PlayAnimation(self.A13, 0, 1, 0, 1, false)
    elseif self.currSwitch == 2 and aim == 3 then
        self:PlayAnimation(self.A23, 0, 1, 0, 1, false)
    elseif self.currSwitch == 2 and aim == 1 then
        self:PlayAnimation(self.A12, 0, 1, 1, 1, false)
    elseif self.currSwitch == 3 and aim == 2 then
        self:PlayAnimation(self.A23, 0, 1, 1, 1, false)
    elseif self.currSwitch == 3 and aim == 1 then
        self:PlayAnimation(self.A13, 0, 1, 1, 1, false)
    elseif self.model == 4 and aim == 5 then
        self:PlayAnimation(self.B12, 0, 1, 0, 1, false)
    elseif self.model == 5 and aim == 4 then
        self:PlayAnimation(self.B12, 0, 1, 1, 1, false)
    elseif self.model == 4 and aim == 6 then
        self:PlayAnimation(self.B13, 0, 1, 0, 1, false)
    elseif self.model == 6 and aim == 4 then
        self:PlayAnimation(self.B13, 0, 1, 1, 1, false)
    elseif self.model == 5 and aim == 6 then
        self:PlayAnimation(self.B23, 0, 1, 0, 1, false)
    elseif self.model == 6 and aim == 5 then
        self:PlayAnimation(self.B23, 0, 1, 1, 1, false)
    elseif self.bDark and aim == 7 then
        self:PlayAnimation(self.C12, 0, 1, 1, 1, false)
    elseif not self.bDark and aim == 8 then
        self:PlayAnimation(self.C12, 0, 1, 0, 1, false)
    elseif aim == 9 then
        self:PlayAnimation(self.D12, 0, 1, 1, 1, false)
    elseif aim == 10 then
        self:PlayAnimation(self.D12, 0, 1, 0, 1, false)
    end
end

function UI_Begin:OnDestroy()
end

return UI_Begin
