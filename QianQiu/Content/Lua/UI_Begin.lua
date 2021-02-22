require "Global"

local UI_Begin = {}

function UI_Begin:Construct()
    self.Button_OneTwo.OnClicked:Add(function ()
        StoryOne = true
        StoryTwo = true
        StoryThree = false
    end)
    self.Button_TwoThree.OnClicked:Add(function ()
        StoryOne = false
        StoryTwo = true
        StoryThree = true
    end)
    self.Button_OneThree.OnClicked:Add(function ()
        StoryOne = true
        StoryTwo = false
        StoryThree = true
    end)
end

function UI_Begin:Initialize()

end

return UI_Begin