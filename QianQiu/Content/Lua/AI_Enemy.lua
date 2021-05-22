Enemy = {}

Enemy.Widgets = {}
Enemy.Cards = {}

Enemy.Basic = {}

function Enemy:SetData(param)
    Enemy.Widgets["UI_CardPoolEnenmy"] = param.UI_CardPoolEnenmy
    Enemy.Widgets["UI_CardPool"] = param.UI_CardPool
    local cardNum = Enemy.Widgets["UI_CardPoolEnenmy"].HaveCards:GetChildrenCount()
    for i=0, cardNum-1 do
        Enemy.Cards[i] =
        {
            UI = Enemy.Widgets["UI_CardPoolEnenmy"]["UI_Card_" .. i],
            bOnHand = true,
        }
    end
end
local index = 1
function Enemy.Basic:Action()
    for index = 0, #(Enemy.Cards) do
        local value = Enemy.Cards[index]
        if value.bOnHand then
            if CheckSeasons(ECardOwner.Enemy) then
                index = index + 1
                local ID = value.UI.ID
                local aimSeason = Table.Cards[ID].Season
                local poolCardNum = Enemy.Widgets["UI_CardPool"].HaveCards:GetChildrenCount()
                for i=0, poolCardNum-1 do
                    print("对手行动中", index)
                    local card = Enemy.Widgets["UI_CardPool"].HaveCards:GetChildAt(i)
                    if card.season == aimSeason then
                        local param = {
                            EnemyHaveCard = ID,
                            EnemyChooseID = card.ID,
                        }
                        CommandMap:DoCommand(CommandList.PopOneCardForEnemy,param)
                        CommandMap:DoCommand(CommandList.PopAndPushOneCardForPublic,param)
                        CommandMap:DoCommand(CommandList.UpdateEnemyScore,param)
                        CommandMap:DoCommand(CommandList.UpdateEnemyHeal, param)
                        value.bOnHand = false
                        print("对手行动完毕")
                        return
                    end
                end
            else
                local param = {
                    PlayerHaveID = value.UI.ID
                }
                CommandMap:DoCommand(CommandList.PopAndPushOneCardForEnemy, param)
            end
        end
    end
    return
end