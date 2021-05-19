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
    Heal = 5,       -- 近弃牌堆了
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

ESeason = {
    ['春'] = 1,
    ['夏'] = 1,
    ['秋'] = 1,
    ['冬'] = 1,
}