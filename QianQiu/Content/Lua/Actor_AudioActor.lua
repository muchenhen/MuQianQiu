require("Global")

local Actor_AudioActor = {}

function Actor_AudioActor:ReceiveBeginPlay()
    print("aaaaaaaaaaaaaaaaaaaaaaaaaa")
    self.StoryAudio:Play(0)
end

return Actor_AudioActor