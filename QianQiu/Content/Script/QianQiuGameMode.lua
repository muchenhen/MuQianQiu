--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--
require("LuaPanda").start("127.0.0.1",8818)
require "UnLua"

local QianQiuGameMode = Class()

function QianQiuGameMode:Initialize(Initializer)
    print("QianQiuGameMode Initializer")
end

--function QianQiuGameMode:UserConstructionScript()
--end

--function QianQiuGameMode:ReceiveBeginPlay()
--end

--function QianQiuGameMode:ReceiveEndPlay()
--end

-- function QianQiuGameMode:ReceiveTick(DeltaSeconds)
-- end

--function QianQiuGameMode:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function QianQiuGameMode:ReceiveActorBeginOverlap(OtherActor)
--end

--function QianQiuGameMode:ReceiveActorEndOverlap(OtherActor)
--end

return QianQiuGameMode
