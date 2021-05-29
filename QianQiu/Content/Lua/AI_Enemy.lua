Enemy = {}

Enemy.Widgets = {}
Enemy.Cards = {}

Enemy.Basic = {}

function Enemy:SetData(param)
    Enemy.Widgets["UI_CardPoolEnenmy"] = param.UI_CardPoolEnenmy
    Enemy.Widgets["UI_CardPool"] = param.UI_CardPool
    Enemy:update()
end

function Enemy:update()
    Enemy.Cards = {}
    local cards = Enemy.Widgets["UI_CardPoolEnenmy"].HaveCards:GetAllChildren()
    local i = 0
    for key, value in pairs(cards) do
        Enemy.Cards[i] =
        {
            UI = value,
        }
        i = i + 1
    end
    --print("对手当前卡片数量：", i)
end

function Enemy.Basic:Action()
    for index = 0, #(Enemy.Cards) do
        local value = Enemy.Cards[index]
        if value then
            if CheckSeasons(ECardOwner.Enemy) then
                local ID = value.UI.ID
                --print("对手当前第", index+1,"张卡片ID", ID, Table.Cards[ID].Name, Table.Cards[ID].Season)
                local aimSeason = Table.Cards[ID].Season
                local poolCards = Enemy.Widgets["UI_CardPool"].HaveCards:GetAllChildren()
                for key, card in pairs(poolCards) do
                    --print("对手准备行动中……")
                    local cardID = card.ID
                    --print("AI当前检索到公共卡池卡片ID", cardID, Table.Cards[cardID].Name, Table.Cards[cardID].Season)
                    if card.season == aimSeason then
                        --print("对手行动！！！")
                        --print("对手进牌堆的两张牌是",Table.Cards[ID].Name,Table.Cards[ID].Season,Table.Cards[cardID].Name,Table.Cards[cardID].Season)
                        Enemy.Cards[index] = false
                        local param = {
                            EnemyHaveCard = ID,
                            EnemyChooseID = card.ID,
                        }
                        CommandMap:DoCommand(CommandList.PopOneCardForEnemy,param)
                        CommandMap:DoCommand(CommandList.PopAndPushOneCardForPublic,param)
                        CommandMap:DoCommand(CommandList.UpdateEnemyScore,param)
                        CommandMap:DoCommand(CommandList.UpdateEnemyHeal, param)
                        --print("对手行动完毕。")
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