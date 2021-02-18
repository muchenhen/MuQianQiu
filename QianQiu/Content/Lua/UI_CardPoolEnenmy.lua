require "Global"

local UI_CardPoolEnenmy = {}

function UI_CardPoolEnenmy:Initialize()

end

function UI_CardPoolEnenmy:Construct()
    for i=0,9 do
        local cardName = "UI_Card_" .. i
        self[cardName]:SetPlayer(false)
        self[cardName]:SetClick(false)
    end
end

return UI_CardPoolEnenmy