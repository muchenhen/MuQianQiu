require "Global"

local UI_Begin = {}

function UI_Begin:Construct()
    self.currSwitch = 1
    self.Button_OneTwo.OnClicked:Add(function ()
        self:PlaySwitch(1)
        self.currSwitch = 1
        StoryOne = true
        StoryTwo = true
        StoryThree = false
    end)
    self.Button_TwoThree.OnClicked:Add(function ()
        self:PlaySwitch(2)
        self.currSwitch = 2
        StoryOne = false
        StoryTwo = true
        StoryThree = true
    end)
    self.Button_OneThree.OnClicked:Add(function ()
        self:PlaySwitch(3)
        self.currSwitch = 3
        StoryOne = true
        StoryTwo = false
        StoryThree = true
    end)
end

function UI_Begin:Initialize()

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
    end
end

return UI_Begin