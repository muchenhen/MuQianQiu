require "Table/Card"
require "Table/Story"
require "Functions"
require("LuaPanda").start("127.0.0.1",8818)

-- 卡池的卡片的状态
EPublicCardState = {
    ReadyChoose = 1,--已经选择了卡池中的一张卡 准备带走的状态
    Normal = 2, --普通状态
}

ECardOwner = {
    Player = 0,     --玩家
    Enemy = 1,      -- 对手
    PublicPool = 2, -- 公共牌库
    Detail = 4,     -- 卡片详情里展示用的
}
 
ECardPostion = {
    OnHand = 0,     --还在手
    OnStory = 1,    --已经打出去的
}

ECardSeason = {
    Spring = 1,     --春
    Summer = 2,     --夏
    Autumn = 3,     --秋
    Winter = 4      --冬
}

ECardState = {
    Choose = 1,     --被选中
    UnChoose = 0    --没有被选中
}

ECardType = {
    Char = 'Char',
    Sword = 'Sword',
    Item = 'Item',
    Pet = 'Pet',
    Map = 'Map',
    Back = '',
}

ESpecialType = {
    CardUp = 1,
    StoryUp = 2,
    AllStoryUp = 3,
    BanAnyCard = 4,
    BanAimCard = 5,
    SwapAnyCard = 6,
    CopyAnyCard = 7,
    ShowCards = 8,
    SeeCards = 9,
    BanSwap = 10
}

ESpecialDetail = {
    [ESpecialType.CardUp]       = "己方“${Card}”增加${Point}分",
    [ESpecialType.StoryUp]      = "己方“${Com}”组合增加${Point}分",
    [ESpecialType.AllStoryUp]   = "增加与自身相关的所有组合${Point}分",
    [ESpecialType.BanAnyCard]	= "禁用对方任意一张特殊牌的效果",
    [ESpecialType.BanAimCard]	= "禁用“${Cards}”特殊牌的效果",
    [ESpecialType.SwapAnyCard]	= "选择对手任意一张特殊牌进行交换",
    [ESpecialType.CopyAnyCard]	= "选择对手任意一张特殊牌复制效果",
    [ESpecialType.ShowCards]	= "如果“${Cards}”还在公共牌库则必定下一回合出现其中之一",
    [ESpecialType.SeeCards]     = "随机翻开对手${Num}张手牌进行查看",
    [ESpecialType.BanSwap]      = "禁止被对方交换"
}


ESlateVisibility = {
    Visible = 0,
	Collapsed = 1,
	Hidden = 2,
	HitTestInvisible = 3,
	SelfHitTestInvisible = 4
}

UI_TEXTURE_PATH = "/Game/Texture/"
UI_TEXTURE_BACK_PATH = "/Game/Texture/Tex_Card_Back"

local WBL = import("WidgetBlueprintLibrary")
Table = {}
CommandMap = {}
CommandMap.FuncMap = {}

StoryOne = false
StoryOneMin = 101
StoryOneMax = 128
StoryTwo = true
StoryTwoMin = 201
StoryTwoMax = 228
StoryThree = true
StoryThreeMin = 301
StoryThreeMax = 328

function CommandMap:AddCommand(key, widget, func)
    local value = {
        widget = widget,
        func = func,
    }
    CommandMap.FuncMap[key] = value
    print("Add One Command:",key)
end

function CommandMap:DoCommand(key, param)
    if key == nil then
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
    CardDetailPlayShowIn = 'CardDetailPlayShowIn',              -- 点击卡片后显示详情界面
    CardDetailPlayShowOut = 'CardDetailPlayShowOut',            -- 卡片取消选择后隐藏详情界面
    EnsureJustOneCardChoose = 'EnsureJustOneCardChoose',        -- 玩家每次选择卡片时确认只有一张卡片被选择
    OnPlayerCardChoose = 'OnPlayerCardChoose',                  -- 当玩家选择一张卡片之后 卡池中对应的属性的牌也被选中
    OnPlayerCardUnchoose = 'OnPlayerCardUnchoose',              -- 玩家手牌取消选择后 卡池中对应的牌也取消选择
    GetPlayerChooseID = 'GetPlayerChooseID',                    -- 获得玩家当前选择的卡片的ID
    UpdatePlayerScore = "UpdatePlayerScore",                    -- 玩家从公共卡池取走卡的时候更新分数信息
    UpdatePlayerHeal = "UpdatePlayerHeal",                      -- 将玩家选的两张卡加入到卡堆
    PopAndPushOneCardForPublic = "PopAndPushOneCardForPublic",  -- 移除选择的卡并随机在生成一张卡 公共卡池
    PopAndPushOneCardForPlayer = "PopAndPushOneCardForPlayer",  -- 同上 玩家卡池
}

function LastStringBySeparator(str, separator)
	return str:sub(str:find(string.format("[^%s]*$", separator)))
end

function GetResPath(gamePackagePath)
    return string.format("%s.%s", gamePackagePath, LastStringBySeparator(gamePackagePath, "/"))
end

function LoadObject(path, className)
    local lastStr = LastStringBySeparator(path, "/")
    if className ~= nil then
        return slua.loadObject(string.format("%s\'%s\'", className, GetResPath(path)))
    end
    return slua.loadObject(path)
end

function ConverUEPath(path)
	if path:find('%.') == nil then
		local fileName = LastStringBySeparator(path, '/')
		return string.format("%s.%s", path, fileName)
	else
		return path
	end
end

function CreateUI(uiName)
    local ui = slua.loadUI("/Game/UI/" .. ConverUEPath(uiName))
    return ui
end

function OpenUI(uiName)
    local ui = slua.loadUI("/Game/UI/" .. ConverUEPath(uiName))
    ui:AddToViewport(10)
end

function Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
       local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
       if not nFindLastIndex then
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
        break
       end
       nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
       nFindStartIndex = nFindLastIndex + string.len(szSeparator)
       nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

Table.Cards = Cards
Table.Story = Story
Table.TotalCardOne = table.FillNum(StoryOneMin, StoryOneMax)
Table.TotalCardSecond = table.FillNum(StoryTwoMin, StoryTwoMax)
Table.TotalCardThird = table.FillNum(StoryThreeMin, StoryThreeMax)
FormatEffectDetail = {
    [ESpecialType.CardUp] = function(param)
        local params = Split(param,';')
        local EffectDetail = ESpecialDetail[ESpecialType.CardUp]
        local cardName = Table.Cards[params[1]].Name
        EffectDetail = string.gsub(EffectDetail,"${Card}", cardName)
        EffectDetail = string.gsub(EffectDetail,"${Point}", params[2])
        return EffectDetail
    end,
    [ESpecialType.StoryUp] = function(param)
        local params = Split(param,';')
        local EffectDetail = ESpecialDetail[ESpecialType.StoryUp]
        local storyName = Table.Story[tonumber(params[1])].Name
        EffectDetail = string.gsub(EffectDetail,"${Com}", storyName)
        EffectDetail = string.gsub(EffectDetail,"${Point}", params[2])
        return EffectDetail
    end,
    [ESpecialType.AllStoryUp] = function(param)
        local EffectDetail = ESpecialDetail[ESpecialType.AllStoryUp]
        EffectDetail = string.gsub(EffectDetail, "${Point}", param)
        return EffectDetail
    end,
    [ESpecialType.BanAnyCard] = function(param)
        return ESpecialDetail[ESpecialType.BanAnyCard]
    end,
    [ESpecialType.BanAimCard] = function(param)
        local params = Split(param,';')
        local cardsName = ''
        for key, value in pairs(params) do
            cardsName = cardsName .. Table.Cards[value].Name .. ' '
        end
        local EffectDetail = ESpecialDetail[ESpecialType.StoryUp]
        EffectDetail = string.gsub(EffectDetail, "${Cards}", cardsName)
        return EffectDetail
    end,
    [ESpecialType.SwapAnyCard] = function(param)
        return ESpecialDetail[ESpecialType.SwapAnyCard]
    end,
    [ESpecialType.CopyAnyCard] = function(param)
        return ESpecialDetail[ESpecialType.CopyAnyCard]
    end,
    [ESpecialType.ShowCards] = function(param)
        local params = Split(param,';')
        local cardsName = ""
        for key, value in pairs(params) do
            cardsName = cardsName .. Table.Cards[tonumber(value)].Name .. ' '
        end
        local EffectDetail = ESpecialDetail[ESpecialType.ShowCards]
        EffectDetail = string.gsub(EffectDetail, "${Cards}", cardsName)
        return EffectDetail
    end,
    [ESpecialType.SeeCards] = function(param)
        local EffectDetail = ESpecialDetail[ESpecialType.SeeCards]
        EffectDetail = string.gsub(EffectDetail,"${Num}", param)
        return EffectDetail
    end,
    [ESpecialType.BanSwap] = function(param)
        return ESpecialDetail[ESpecialType.BanSwap]
    end
}

function FindStory(cardID)
    local cardsName = ''
    local cards = {}
    for key, value in pairs(Table.Story) do
        local bHasStory = false
        for m,n in pairs(value.Cards) do
            if n == cardID then
                bHasStory = true
            end
        end
        if bHasStory then
            for m,n in pairs(value.Cards) do
                if n ~= cardID then
                    cards[n] = Table.Cards[n].Name
                end
            end
        end
    end
    for m,n in pairs(cards) do
        cardsName = cardsName .. n .. ', '
    end
    cardsName = string.sub(cardsName, 1, -2)
    cardsName = string.sub(cardsName, 1, -2)
    return cardsName
end

local CheckCard
function CheckCard(CardsID, part, min, max, i)
    -- math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,7))) -- 设置随机种子
    -- 在最大值和最小值之间生成一个随机数
    local temp = math.random(min, max)
    -- 如果该数字表示的卡还在牌库里（0）就添加进CardsID 并标记为已经发出（1），否则重新生成
    if part[temp] == 0 then
        table.insert(CardsID, temp)
        part[temp] = 1
        i = i + 1
        return CardsID,i
    else
        return CheckCard(CardsID, part, min, max, i)
    end
end

function RandomCards(num)
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,7))) -- 设置随机种子
    local halfPartOne = math.random(1,num) -- 第一部分的数量
    local partOne
    local oneMin
    local oneMax
    local partTwo
    local twoMin
    local twoMax
    -- 判断玩家选择的是几代
    if StoryOne and StoryTwo then
        partOne = Table.TotalCardOne
        oneMin = StoryOneMin
        oneMax = StoryOneMax
        partTwo = Table.TotalCardSecond
        twoMin = StoryTwoMin
        twoMax = StoryTwoMax
    elseif StoryOne and StoryThree  then
        partOne = Table.TotalCardOne
        oneMin = StoryOneMin
        oneMax = StoryOneMax
        partTwo = Table.TotalCardThird
        twoMin = StoryThreeMin
        twoMax = StoryThreeMax
    elseif StoryTwo and StoryThree then
        partOne = Table.TotalCardSecond
        oneMin = StoryTwoMin
        oneMax = StoryTwoMax
        partTwo = Table.TotalCardThird
        twoMin = StoryThreeMin
        twoMax = StoryThreeMax
    end
    -- 生成Cards并返回
    local CardsID = {}
    local i = 1
    while i <= halfPartOne do
        CardsID,i = CheckCard(CardsID, partOne, oneMin, oneMax, i)
    end
    while i <= num do
        CardsID,i = CheckCard(CardsID, partTwo, twoMin, twoMax, i)
    end
    print("随机生成的卡片数量：", #CardsID)
    return CardsID
end

