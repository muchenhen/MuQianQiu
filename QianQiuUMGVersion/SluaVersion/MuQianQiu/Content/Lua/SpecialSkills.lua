require("GameManager")

-- 禁用技能
-- 禁用对方的特殊技能
function GameManager:DoBanSpecialSkill()
    
end

-- 确保卡牌在公共区域显示，如果这张牌还在公共卡池的话
function GameManager:DoEnsureCardShowInPublic()
    
end

-- 增加指定故事的分数，注意只增加发动技能的玩家的分数
function GameManager:DoRaiseStoryScore()
    
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