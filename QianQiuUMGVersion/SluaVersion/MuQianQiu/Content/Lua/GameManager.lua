MuBPFunction = import("MuBPFunction")

GameManager = {}

GameManager.Min1 = 101
GameManager.Max1 = 124
GameManager.Min2 = 201
GameManager.Max2 = 224
GameManager.Min3 = 301
GameManager.Max3 = 324

GameManager.PlayerAScore = 0
GameManager.PlayerBScore = 0

CardStoreIDList = {}

function GameManager:GameStart()
    GameManager.PlayerAScore = 0
    GameManager.PlayerBScore = 0
end

function GameManager:GameEnd()
end

function GameManager:GameRestart()
end

-- 洗牌
function GameManager:Shuffle(array)
    local counter = #array

    while counter > 1 do
        local index = math.random(counter)
        array[counter], array[index] = array[index], array[counter]
        counter = counter - 1
    end

    return array
end

function GameManager:InitCardOnBegin()
    -- 清空CardIDList
    CardStoreIDList = {}
    for i = GameManager.Min2, GameManager.Max2 do
        table.insert(CardStoreIDList, i)
    end
    for i = GameManager.Min3, GameManager.Max3 do
        table.insert(CardStoreIDList, i)
    end
    self:Shuffle(CardStoreIDList)
end

function GameManager:GetOneCardFromStore()
    local cardID = CardStoreIDList[1]
    table.remove(CardStoreIDList, 1)
    return cardID
end

function GameManager:GetPlayerAScore()
    return GameManager.PlayerAScore
end

function GameManager:GetPlayerBScore()
    return GameManager.PlayerBScore
end