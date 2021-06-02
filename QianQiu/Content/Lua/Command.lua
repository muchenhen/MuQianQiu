CommandMap = {}
CommandMap.FuncMap = {}

function CommandMap:AddCommand(key, widget, func)
    local value = {
        widget = widget,
        func = func,
    }
    if not CommandMap.FuncMap[key] then
        -- --print("Add One Command:",key)
    end
    CommandMap.FuncMap[key] = value
end

function CommandMap:DoCommand(key, param)
    if key == nil then
        error("该消息没有注册！")
        return
    end
    if CommandMap.FuncMap[key] then
        local widget = CommandMap.FuncMap[key].widget
        local func = CommandMap.FuncMap[key].func
        if not widget then
            error("Can not find this widget:")
        end
        if not func then
            error("Can not find this function:" ..  key)
        end
        if not param then
            local re = func(widget)
            if re then
                return re
            end
        else
            local re = func(widget, param)
            if re then
                return re
            end
        end
    end
end

CommandList = {
    EnsureJustOneCardChoose = 'EnsureJustOneCardChoose',        -- 玩家每次选择卡片时确认只有一张卡片被选择
    OnPlayerCardChoose = 'OnPlayerCardChoose',                  -- 当玩家选择一张卡片之后 卡池中对应的属性的牌也被选中
    OnPlayerCardUnchoose = 'OnPlayerCardUnchoose',              -- 玩家手牌取消选择后 卡池中对应的牌也取消选择
    GetPlayerChooseID = 'GetPlayerChooseID',                    -- 获得玩家当前选择的卡片的ID
    UpdatePlayerScore = "UpdatePlayerScore",                    -- 玩家从公共卡池取走卡的时候更新分数信息
    UpdatePlayerHeal = "UpdatePlayerHeal",                      -- 将玩家选的两张卡加入到卡堆
    UpdateEnemyHeal = "UpdateEnemyHeal",                        -- 同上 对手
    PopAndPushOneCardForPublic = "PopAndPushOneCardForPublic",  -- 移除选择的卡并随机在生成一张卡 公共卡池
    PopAndPushOneCardForEnemy = "PopAndPushOneCardForEnemy",    -- 同上 对手卡池
    PopAndPushOneCardForPlayer = "PopAndPushOneCardForPlayer",  -- 同上 玩家卡池
    PopOneCardForPlayer = "PopOneCardForPlayer",                -- 移除玩家选择的卡
    PopOneCardForEnemy = "PopOneCardForEnemy",                  -- 移除对手选择的卡
    ShowRound = "ShowRound",                                    -- 设置回合文字并显示回合
    UpdateEnemyScore = "UpdateEnemyScore",                      -- 更新敌人分数
    SetStoryShowTickPlayer = "SetStoryShowTickPlayer",          -- 设置Heal的故事tick检查 Player
    SetStoryShowTickEnemy = "SetStoryShowTickEnemy",            -- 设置Heal的故事tick检查 Enemy
    CheckPlayerSeason = "CheckPlayerSeason",                    -- 检查玩家手牌的季节
    CheckEnemySeason = "CheckEnemySeason",                      -- 检查对手手牌的季节
    CheckPublicSeason = "CheckPublicSeason",                    -- 检查公共卡池的季节
    SetAllCardsbCanPlayer = "SetAllCardsbCanPlayer",            -- 设置所有卡片的丢弃状态
    SetAllCardsbCanEnemy = "SetAllCardsbCanEnemy",              -- 同上 对手
    GetResultScores = "GetResultScores",                        -- 获取最后的分数
    UIMainReset = "UIMainReset",                                -- 重置UIMain
    UIStartRestart = "UIStartRestart",                          -- 重新到启动界面
}