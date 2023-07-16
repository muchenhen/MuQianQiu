require("Global")

local A_AudioPlayer = {}

function A_AudioPlayer:ReceiveBeginPlay()
    GameManager.A_AudioPlayer = self
end


return Class(nil, nil, A_AudioPlayer)