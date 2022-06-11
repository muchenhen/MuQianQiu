--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local Actor_Card = Class()

function Actor_Card:Initialize(Initializer)
    self.CardID = 101
    self.CardName = "百里屠苏"
end

--function Actor_Card:UserConstructionScript()
--end

-- function Actor_Card:ReceiveBeginPlay()
-- end

function Actor_Card:InitCard(CardID)

end

function Actor_Card:ReceiveActorOnClicked()
    self:SetSelfImageByCardID(101)
end

function Actor_Card:SetSelfImageByCardID(CardID)
   print(QianQiuBlueprintFunctionLibrary:GetProBase())
end

--function Actor_Card:ReceiveEndPlay()
--end

-- function Actor_Card:ReceiveTick(DeltaSeconds)
-- end

--function Actor_Card:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function Actor_Card:ReceiveActorBeginOverlap(OtherActor)
--end

--function Actor_Card:ReceiveActorEndOverlap(OtherActor)
--end

return Actor_Card
