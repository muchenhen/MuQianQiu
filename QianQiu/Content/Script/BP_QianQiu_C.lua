--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local BP_QianQiu_C = Class()

function BP_QianQiu_C:Initialize(Initializer)
    print("Hello World")
end

--function BP_QianQiu_C:UserConstructionScript()
--end

function BP_QianQiu_C:ReceiveBeginPlay()
    print("Hello World")
end

--function BP_QianQiu_C:ReceiveEndPlay()
--end

-- function BP_QianQiu_C:ReceiveTick(DeltaSeconds)
-- end

--function BP_QianQiu_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function BP_QianQiu_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function BP_QianQiu_C:ReceiveActorEndOverlap(OtherActor)
--end

return BP_QianQiu_C
