--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local CardBase = Class()

-- function CardBase:Initialize(Initializer)
-- end

--function CardBase:UserConstructionScript()
--end

-- function CardBase:ReceiveBeginPlay()
-- end

function CardBase:ReceiveActorOnClicked()
    print("???")
    QianQiuBlueprintFunctionLibrary:DumpCardData(self.CardData)
end

--function CardBase:ReceiveEndPlay()
--end

-- function CardBase:ReceiveTick(DeltaSeconds)
-- end

--function CardBase:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function CardBase:ReceiveActorBeginOverlap(OtherActor)
--end

--function CardBase:ReceiveActorEndOverlap(OtherActor)
--end

return CardBase
