require("GameManager")

-- 禁用技能
-- 禁用对方的特殊技能
-- 两种：
-- 1. 禁用任意指定的一张当前对方拥有的特殊牌的技能
-- 2. 禁用的卡牌列表有限，只能禁用列表
function GameManager:DoBanSpecialSkill()
    
end

-- 确保卡牌在公共区域显示，如果这张牌还在公共卡池的话
function GameManager:DoEnsureCardShowInPublic()
    
end

-- Describe： 增加指定故事的分数，注意只增加发动技能的玩家的分数
-- Param： storyId 故事的id
-- Param： score 增加的分数
-- Param:  playerIndex 玩家的索引
function GameManager:DoRaiseStoryScore(storyId, score, playerIndex)
    
    
end

-- 随机翻开对手的若干张卡牌
function GameManager:DoSeeOpponentCard()
    -- body
end

-- 交换卡牌
function GameManager:DoSwapCard()
    -- body
end

-- 复制技能
function GameManager:DoCopySkill()
    -- body
end

-- 增加指定卡牌出现的概率
function GameManager:DoRaiseCardAppearRate()
    -- body
end