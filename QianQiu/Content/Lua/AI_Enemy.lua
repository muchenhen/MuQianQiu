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
    local cardNum = Enemy.Widgets["UI_CardPoolEnenmy"].HaveCards:GetChildrenCount()
    local cards = Enemy.Widgets["UI_CardPoolEnenmy"].HaveCards:GetAllChildren()
    print("对手当前卡片数量：", cardNum)
    for i=0, cardNum-1 do
        Enemy.Cards[i] =
        {
            UI = cards:Get(i),
        }
    end
end

function Enemy.Basic:Action()
    Enemy:update()
    for index = 0, #(Enemy.Cards) do
        local value = Enemy.Cards[index]
        if CheckSeasons(ECardOwner.Enemy) then
            local ID = value.UI.ID
            print("对手当前第", index+1,"张卡片ID", ID, Table.Cards[ID].Name, Table.Cards[ID].Season)
            local aimSeason = Table.Cards[ID].Season
            local poolCardNum = Enemy.Widgets["UI_CardPool"].HaveCards:GetChildrenCount()
            for i=0, poolCardNum-1 do
                print("对手准备行动中……")
                local card = Enemy.Widgets["UI_CardPool"].HaveCards:GetChildAt(i)
                local cardID = card.ID
                print("AI当前检索到公共卡池卡片ID", cardID, Table.Cards[cardID].Name, Table.Cards[cardID].Season)
                if card.season == aimSeason then
                    print("对手行动！！！")
                    print("对手进牌堆的两张牌是",Table.Cards[ID].Name,Table.Cards[ID].Season,Table.Cards[cardID].Name,Table.Cards[cardID].Season)
                    local param = {
                        EnemyHaveCard = ID,
                        EnemyChooseID = card.ID,
                    }
                    CommandMap:DoCommand(CommandList.PopOneCardForEnemy,param)
                    CommandMap:DoCommand(CommandList.PopAndPushOneCardForPublic,param)
                    CommandMap:DoCommand(CommandList.UpdateEnemyScore,param)
                    CommandMap:DoCommand(CommandList.UpdateEnemyHeal, param)
                    value.bOnHand = false
                    print("对手行动完毕。")
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
    return
end