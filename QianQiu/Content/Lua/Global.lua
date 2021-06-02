require "Table/Card"
require "Table/Story"
require "Functions"
require "Command"
require "Enum"
require "UIStack"
require "AI_Enemy"
require("LuaPanda").start("127.0.0.1",8818)
GameplayStatics = import("GameplayStatics")

--import function helper
local importedClsList = {} --cache element as table { cls = class, cnt = number }
ImportHelper = {}
local _import = import
ImportHelper.importClass = function (className)
    if importedClsList[className] == nil then
        importedClsList[className] = {cls = _import(className), cnt = 1}
    else
        importedClsList[className].cnt = importedClsList[className].cnt + 1
    end
    return importedClsList[className].cls
end
ImportHelper.clearAllClass = function ()
    importedClsList = {}
end
ImportHelper.shrinkClass = function (importedCnt)
    importedCnt = importedCnt or 3
    for k,v in pairs(importedClsList) do
        if v.cnt <= importedCnt then
            importedClsList[k] = nil
        else
            v.cnt = v.cnt - importedCnt
        end
    end
end

import = ImportHelper.importClass

UI_TEXTURE_PATH = "/Game/Texture/"
UI_TEXTURE_BACK_PATH = "/Game/Texture/Tex_Card_Back"

bEnemyDark = true

Table = {}


StoryOne = false
StoryOneMin = 101
StoryOneMax = 128
StoryTwo = true
StoryTwoMin = 201
StoryTwoMax = 228
StoryThree = true
StoryThreeMin = 301
StoryThreeMax = 328

bPlayer = true

NeedShowStorys = {}

PublicSeason = {}
PlayerSeason = {}
EnemySeason = {}

t1 = {} --牌库1 顺序保存ID
t2 = {} --牌库2
t1index = 0 --保存当前发牌到第几张
t2index = 0

function OpenUI(uiName)
    local ui = slua.loadUI("/Game/UI/" .. ConverUEPath(uiName))
    ui:AddToViewport(10)
    return ui
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
CheckCard = function (CardsID, part, min, max, i)
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



local function IndexAdd(index)
    if index < 28 then
        index = index + 1
    end
    -- --print(index)
    return index
end

function WashCards()
    local oneMin
    local oneMax
    local twoMin
    local twoMax
    -- 判断玩家选择的是几代
    if StoryOne and StoryTwo then
        oneMin = StoryOneMin
        oneMax = StoryOneMax
        twoMin = StoryTwoMin
        twoMax = StoryTwoMax
    elseif StoryOne and StoryThree  then
        oneMin = StoryOneMin
        oneMax = StoryOneMax
        twoMin = StoryThreeMin
        twoMax = StoryThreeMax
    elseif StoryTwo and StoryThree then
        partOne = Table.TotalCardSecond
        oneMin = StoryTwoMin
        oneMax = StoryTwoMax
        twoMin = StoryThreeMin
        twoMax = StoryThreeMax
    end
    t1 = math.randomx(oneMin, oneMax, 28)
    t2 = math.randomx(twoMin, twoMax, 28)
end
 
function RandomCards(num)
    if t1index >=28 and t2index >=28 then
        --print("牌库已空")
        return {[1] = 101}
    end
    --print("随机生成的卡片数量：", num)
    if num == 1 then
        local ran = math.random(1,2)
        if ran == 1 then
            if t1index >=28 then
                ran = 2
            end
        elseif ran == 2 then
            if t2index >=28 then
                ran = 1
            end
        end
        if ran == 1 then
            t1index = IndexAdd(t1index)
            --print("当前牌库1的索引位置位：",t1index)
            print("当前牌库1的索引位置位：",t1index)
            print("当前牌库2的索引位置位：",t2index)
            print("")
        
            return {[1] = t1[t1index]}
        else
            t2index = IndexAdd(t2index)
            --print("当前牌库2的索引位置位：",t2index)
            print("当前牌库1的索引位置位：",t1index)
            print("当前牌库2的索引位置位：",t2index)
            print("")
        
            return {[1] = t2[t2index]}
        end
    else
        local halfPartOne = math.random(1,num)
        local CardsID = {}
        local i = 1
        while i <= halfPartOne do
            t1index = IndexAdd(t1index)
            table.insert( CardsID, t1[t1index])
            i = i + 1
        end
        --print("当前牌库1的索引位置位：",t1index)
        while i <= num do
            t2index = IndexAdd(t2index)
            table.insert(CardsID, t2[t2index])
            i = i + 1
        end
        --print("当前牌库2的索引位置位：",t2index)
        --print("cardsID数量：", #CardsID)
        print("当前牌库1的索引位置位：",t1index)
        print("当前牌库2的索引位置位：",t2index)
        print("")
        return CardsID
    end
end

function ChangeCard(cardID)
    if t1index >=28 and t2index >=28 then
        --print("牌库已空")
        return {[1] = 101}
    end
    local ran = math.random(1,2)
    if ran == 1 then
        if t1index >=28 then
            ran = 2
        end
    elseif ran == 2 then
        if t2index >=28 then
            ran = 1
        end
    end
    if ran == 1 then
        -- 从t1中交换一张卡出来
        local aim = math.random(t1index, 27)
        local param = {[1] = t1[aim]}
        t1[aim] = cardID
        return param
    else
        local aim = math.random(t2index, 27)
        local param = {[1] = t2[aim]}
        t2[aim] = cardID
        return param
    end
end

function ShowTip(text)
    local param = {
        text = text,
    }
    UIStack:PushUIByName("UI_Tip", param)
end



function CheckSeasons(type)
    CommandMap:DoCommand(CommandList.CheckPublicSeason)
    if type == ECardOwner.Enemy then
        CommandMap:DoCommand(CommandList.CheckEnemySeason)
        for key, value in pairs(PublicSeason) do
            if value then
                if EnemySeason[key] then
                    return true
                end
            end
        end
        return false
    elseif type == ECardOwner.Player then
        CommandMap:DoCommand(CommandList.CheckPlayerSeason)
        for key, value in pairs(PublicSeason) do
            if value then
                if PlayerSeason[key] then
                    return true
                end
            end
        end
        return false
    end
end

function Reset()
    NeedShowStorys = {}
    PublicSeason = {}
    PlayerSeason = {}
    EnemySeason = {}
    t1 = {} --牌库1 顺序保存ID
    t2 = {} --牌库2
    t1index = 0 --保存当前发牌到第几张
    t2index = 0
    --print(t1index)
    --print(t2index)

end