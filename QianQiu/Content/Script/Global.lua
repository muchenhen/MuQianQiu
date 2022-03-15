require "Functions"
require "Enums"
require("LuaPanda").start("127.0.0.1",8818)

GameplayStatics = UE.UGameplayStatics
QianQiuBlueprintFunctionLibrary = UE.UQianQiuBlueprintFunctionLibrary

--import function helper
local importedClsList = {} --cache element as table { cls = class, cnt = number }
ImportHelper = {}
local _import = import
ImportHelper.importClass = function(className)
    if importedClsList[className] == nil then
        importedClsList[className] = {cls = _import(className), cnt = 1}
    else
        importedClsList[className].cnt = importedClsList[className].cnt + 1
    end
    return importedClsList[className].cls
end
ImportHelper.clearAllClass = function()
    importedClsList = {}
end
ImportHelper.shrinkClass = function(importedCnt)
    importedCnt = importedCnt or 3
    for k, v in pairs(importedClsList) do
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
bStoryExtra = false
bNormalStory = true
bPlayAudio = true

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
FULLt = {}
FULLtIndex = 0

PlayerFinishStories = {}
EnemyFinishStories = {}

PlayerHealCards = {}
EnemyHealCards = {}

Table.Cards = Cards
Table.Story = Story
Table.StoryExtra = StoryExtra
Table.AllStory = {}
Table.TotalCardOne = table.FillNum(StoryOneMin, StoryOneMax)
Table.TotalCardSecond = table.FillNum(StoryTwoMin, StoryTwoMax)
Table.TotalCardThird = table.FillNum(StoryThreeMin, StoryThreeMax)

function OpenUI(uiName)
    local ui = slua.loadUI("/Game/UI/" .. ConverUEPath(uiName))
    ui:AddToViewport(10)
    return ui
end

function InitAllStory()
    if bStoryExtra and bNormalStory then
        for key, value in pairs(Table.Story) do
            Table.AllStory[key] = value
        end
        for key, value in pairs(Table.StoryExtra) do
            Table.AllStory[key] = value
        end
    elseif bNormalStory and not bStoryExtra then
        for key, value in pairs(Table.Story) do
            Table.AllStory[key] = value
        end
    elseif bStoryExtra and not bNormalStory then
        for key, value in pairs(Table.StoryExtra) do
            Table.AllStory[key] = value
        end
    end
end

FormatEffectDetail = {
    [ESpecialType.CardUp] = function(param)
        local params = Split(param, ";")
        local EffectDetail = ESpecialDetail[ESpecialType.CardUp]
        local cardName = Table.Cards[params[1]].Name
        EffectDetail = string.gsub(EffectDetail, "${Card}", cardName)
        EffectDetail = string.gsub(EffectDetail, "${Point}", params[2])
        return EffectDetail
    end,
    [ESpecialType.StoryUp] = function(param)
        local params = Split(param, ";")
        local EffectDetail = ESpecialDetail[ESpecialType.StoryUp]
        local storyName = Table.AllStory[tonumber(params[1])].Name
        EffectDetail = string.gsub(EffectDetail, "${Com}", storyName)
        EffectDetail = string.gsub(EffectDetail, "${Point}", params[2])
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
        local params = Split(param, ";")
        local cardsName = ""
        for key, value in pairs(params) do
            cardsName = cardsName .. Table.Cards[value].Name .. " "
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
        local params = Split(param, ";")
        local cardsName = ""
        for key, value in pairs(params) do
            cardsName = cardsName .. Table.Cards[tonumber(value)].Name .. " "
        end
        local EffectDetail = ESpecialDetail[ESpecialType.ShowCards]
        EffectDetail = string.gsub(EffectDetail, "${Cards}", cardsName)
        return EffectDetail
    end,
    [ESpecialType.SeeCards] = function(param)
        local EffectDetail = ESpecialDetail[ESpecialType.SeeCards]
        EffectDetail = string.gsub(EffectDetail, "${Num}", param)
        return EffectDetail
    end,
    [ESpecialType.BanSwap] = function(param)
        return ESpecialDetail[ESpecialType.BanSwap]
    end
}

function FindStory(cardID)
    local cardsName = ""
    local cards = {}
    for key, value in pairs(Table.AllStory) do
        local bHasStory = false
        for m, n in pairs(value.Cards) do
            if n == cardID then
                bHasStory = true
            end
        end
        if bHasStory then
            for m, n in pairs(value.Cards) do
                if n ~= cardID then
                    cards[n] = Table.Cards[n].Name
                end
            end
        end
    end
    for m, n in pairs(cards) do
        cardsName = cardsName .. n .. ", "
    end
    cardsName = string.sub(cardsName, 1, -2)
    cardsName = string.sub(cardsName, 1, -2)
    return cardsName
end

local function IndexAdd(index)
    index = index + 1
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
    elseif StoryOne and StoryThree then
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
    for key, value in pairs(t1) do
        FULLt[#FULLt + 1] = value
    end
    for key, value in pairs(t2) do
        FULLt[#FULLt + 1] = value
    end
    local n = 10
    while n >= 0 do
        FULLt = Shuffle(FULLt)
        n = n - 1
    end
end

-- 需要考虑某一个牌库已经发空的情况
function RandomCards(num)
    if FULLtIndex >= #FULLt then
        ShowTip("牌库已空")
        return {[1] = 101}
    end
    --print("随机生成的卡片数量：", num)

    local i = 1
    local CardsID = {}
    while i <= num do
        FULLtIndex = IndexAdd(FULLtIndex)
        table.insert(CardsID, FULLt[FULLtIndex])
        --print("卡池新生成卡牌：", Cards[FULLt[FULLtIndex]].Name)
        i = i + 1
    end
    --print("当前索引位置：", FULLtIndex)
    return CardsID
end

function ChangeCard(cardID)
    if FULLtIndex >= #FULLt then
        ShowTip("牌库已空")
        return {[1] = 101}
    end
    -- 从Fullt中交换一张卡出来
    local aim = math.random(FULLtIndex, #FULLt)
    local param = {[1] = FULLt[aim]}
    FULLt[aim] = cardID
    return param
end

function ShowTip(text)
    local param = {
        text = text
    }
    --print(text)
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

-- 确认玩家或者对手牌堆中有没有指定的牌
function CheckIsHaveThisCardInHeal(bPlayer, cardID)
    if bPlayer then
        for key, value in pairs(PlayerHealCards) do
            if value == cardID then
                return true
            end
        end
        return false
    else
        for key, value in pairs(EnemyHealCards) do
            if value == cardID then
                return true
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
    FULLt = {}
    FULLtIndex = 0
end
