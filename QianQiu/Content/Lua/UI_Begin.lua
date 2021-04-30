require "Global"
local UI_Begin = {}

function UI_Begin:Construct()
    self.currSwitch = 1
    self.model = 4
    self.Button_OneTwo.OnClicked:Add(self.OnOneTwoClick)
    self.Button_TwoThree.OnClicked:Add(self.OnTwoThreeClick)
    self.Button_OneThree.OnClicked:Add(self.OnOneThreeClick)
    self.Button_Normal.OnClicked:Add(self.OnNormalClick)
    self.Button_Monster.OnClicked:Add(self.OnMonsterClick)
end

function UI_Begin:Initialize()
    print("牌库选择1+2")
end


function UI_Begin:OnOneTwoClick()
    local self = UI_Begin
    self:PlaySwitch(1)
    self.currSwitch = 1
    StoryOne = true
    StoryTwo = true
    StoryThree = false
    print("牌库选择1+2")
end

function UI_Begin:OnTwoThreeClick()
    local self = UI_Begin
    self:PlaySwitch(2)
    self.currSwitch = 2
    StoryOne = false
    StoryTwo = true
    StoryThree = true
    print("牌库选择2+3")
end

function UI_Begin:OnOneThreeClick()
    local self = UI_Begin
    self:PlaySwitch(3)
    self.currSwitch = 3
    StoryOne = true
    StoryTwo = false
    StoryThree = true
    print("牌库选择1+3")
end

function UI_Begin:OnNormalClick()
    local self = UI_Begin
    self:PlaySwitch(4)
    self.model = 4
    print("模式选择：普通模式")
end

function UI_Begin:OnMonsterClick()
    local self = UI_Begin
    self:PlaySwitch(5)
    self.model = 5
    print("模式选择：撒野模式")
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
    end
end

function UI_Begin:OnDestroy()

end

return UI_Begin