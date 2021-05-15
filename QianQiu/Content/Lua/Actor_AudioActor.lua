require("Global")

local Actor_AudioActor = {}

function Actor_AudioActor:ReceiveBeginPlay()
    CommandMap:AddCommand("SetSelfAudioAndPlay", self, self.SetSelfAudioAndPlay)
end

function Actor_AudioActor:SetSelfAudioAndPlay(audioPath)
    local audio = LoadObject("/Game/Audio/" .. audioPath)
    self.StoryAudio:SetSound(audio)
    self.StoryAudio:Play(0)
end

function Actor_AudioActor:ShowStoryOut()
    CommandMap:DoCommand("PlayStoryShowOut")
end

return Actor_AudioActor