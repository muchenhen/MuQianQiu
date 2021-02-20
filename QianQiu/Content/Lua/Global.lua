ECardSeason = {
    Spring = 1,
    Summer = 2,
    Autumn = 3,
    Winter = 4
}

ECardState = {
    Choose = 1,
    UnChoose = 0
}

ECardType = {
    Char = 'Char',
    Sword = 'Sword',
    Item = 'Item',
    Pet = 'Pet',
    Map = 'Map',
    Back = '',
}

ESpecialDetail = {
    [1] = "己方“{$Card}”增加{$Point}分",
    [2] = "己方“{$Com}”组合增加{$Point}分",
    [3] = "增加与自身相关的所有组合{$Point}分",
    [4]	= "禁用对方任意一张特殊牌的效果",
    [5]	= "禁用“{$Cards}”特殊牌的效果",
    [6]	= "选择对手任意一张特殊牌进行交换",
    [7]	= "选择对手任意一张特殊牌复制效果",
    [8]	= "如果“{$Cards}”还在公共牌库则必定下一回合出现",
    [9] = "随机翻开对手{$Num}张手牌进行查看",
    [10] = "禁止被对方交换"
}

ESpecialType = {
    CardUp = 1,
    StoryUp = 2,
    AllStoryUp = 3,
    BanAnyCard = 4,
    BanAimCard = 5,
    SwapAnyCard = 6,
    CopyAnyCard = 7,
    ShowCards = 8
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

CommandMap = {}
CommandMap.FuncMap = {}

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
        if not param then
            func(widget)
        else
            func(widget, param)
        end
    end
end

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

Cards = {
    [101] = {
        ["Name"] = "beiluo",
        ""
    }
}