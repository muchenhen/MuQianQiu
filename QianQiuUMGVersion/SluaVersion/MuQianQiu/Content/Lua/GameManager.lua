MuBPFunction = import("MuBPFunction")

Min1 = 101
Max1 = 124
Min2 = 201
Max2 = 224
Min3 = 301
Max3 = 324

CardIDList = {}

function GameStart()
end

function GameEnd()
end

function Shuffle(array)
    local counter = #array

    while counter > 1 do
        local index = math.random(counter)
        array[counter], array[index] = array[index], array[counter]
        counter = counter - 1
    end

    return array
end

function InitCardOnBegin()
    for i = Min2, Max2 do
        table.insert(CardIDList, i)
    end
    for i = Min3, Max3 do
        table.insert(CardIDList, i)
    end
    Shuffle(CardIDList)
end
