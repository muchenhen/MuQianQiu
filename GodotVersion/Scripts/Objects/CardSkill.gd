extends Node

class_name CardSkill

var table_manager = TableManager.get_instance()

enum SKILL_TYPE {
    DISABLE_SKILL,# 禁用技能
    GUARANTEE_APPEAR, # 保证出现
    INCREASE_APPEAR, # 增加出现概率
    ADD_SCORE, # 增加分数
    COPY_SKILL, # 复制技能
    EXCHANGE_CARD, # 交换卡牌
    OPEN_OPPONENT_HAND, # 翻开对手的手牌
    EXCHANGE_DISABLE_SKILL, # 交换后禁用技能
}

# 技能类型对应字符串
const SKILL_TYPE_STRINGS = {
    SKILL_TYPE.DISABLE_SKILL: "禁用技能",
    SKILL_TYPE.GUARANTEE_APPEAR: "保证出现",
    SKILL_TYPE.INCREASE_APPEAR: "增加出现概率",
    SKILL_TYPE.ADD_SCORE: "增加分数",
    SKILL_TYPE.COPY_SKILL: "复制技能",
    SKILL_TYPE.EXCHANGE_CARD: "交换卡牌",
    SKILL_TYPE.OPEN_OPPONENT_HAND: "翻开对手手牌",
    SKILL_TYPE.EXCHANGE_DISABLE_SKILL: "交换后无效"
}
    

# 触发技能：禁用技能
func trigger_DISABLE_SKILL() -> void:
    pass

# 触发技能：保证出现
func trigger_GUARANTEE_APPEAR() -> void:
    pass

# 触发技能：增加出现概率
func trigger_INCREASE_APPEAR() -> void:
    pass

# 触发技能：增加分数
func trigger_ADD_SCORE() -> void:
    pass

# 触发技能：复制技能
func trigger_COPY_SKILL() -> void:
    pass

# 触发技能：交换卡牌
func trigger_EXCHANGE_CARD() -> void:
    pass

# 触发技能：翻开对手的手牌
func trigger_OPEN_OPPONENT_HAND() -> void:
    pass

# 触发技能：交换后禁用技能
func trigger_EXCHANGE_DISABLE_SKILL() -> void:
    pass
