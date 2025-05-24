extends Node

class_name CardSkill

enum SKILL_TYPE {
    DISABLE_SKILL,# 禁用技能
    GUARANTEE_APPEAR, # 保证出现
    INCREASE_APPEAR, # 增加出现概率
    ADD_SCORE, # 增加分数
    COPY_SKILL, # 复制技能
    EXCHANGE_CARD, # 交换卡牌
    OPEN_OPPONENT_HAND, # 翻开对手的手牌
    EXCHANGE_DISABLE_SKILL, # 交换后禁用技能
    NULL # 空技能
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

# Convert skill type enum to string
static func skill_type_to_string(type: int) -> String:
    if SKILL_TYPE_STRINGS.has(type):
        return SKILL_TYPE_STRINGS[type]
    return "未知技能"

# Convert string to skill type enum
static func string_to_skill_type(type_str: String) -> SKILL_TYPE:
    for type in SKILL_TYPE_STRINGS.keys():
        if SKILL_TYPE_STRINGS[type] == type_str:
            return type
    return SKILL_TYPE.NULL

static func get_skill_num_for_card(card:Card) -> int:
    var table_manager = TableManager.get_instance()
    var card_skill_row = table_manager.get_row("Skills", card.ID)
    var num = 0
    if card_skill_row:
        if card_skill_row.has("Skill1Type"):
            num = 1
        if card_skill_row.has("Skill2Type"):
            num = 2
    return num

static func get_first_skill_type(card:Card) -> SKILL_TYPE:
    var table_manager = TableManager.get_instance()
    var card_skill_row = table_manager.get_row("Skills", card.ID)
    if card_skill_row:
        if card_skill_row.has("Skill1Type"):
            return string_to_skill_type(card_skill_row["Skill1Type"])
    return SKILL_TYPE.NULL

static func get_second_skill_type(card:Card) -> SKILL_TYPE:
    var table_manager = TableManager.get_instance()
    var card_skill_row = table_manager.get_row("Skills", card.ID)
    if card_skill_row:
        if card_skill_row.has("Skill2Type"):
            return string_to_skill_type(card_skill_row["Skill2Type"])
    return SKILL_TYPE.NULL

static func get_skill_type_by_index(card:Card, index:int) -> SKILL_TYPE:
    var table_manager = TableManager.get_instance()
    var card_skill_row = table_manager.get_row("Skills", card.ID)
    if card_skill_row:
        if index == 1 and card_skill_row.has("Skill1Type"):
            return string_to_skill_type(card_skill_row["Skill1Type"])
        elif index == 2 and card_skill_row.has("Skill2Type"):
            return string_to_skill_type(card_skill_row["Skill2Type"])
    return SKILL_TYPE.NULL


# 触发技能：禁用技能
func trigger_DISABLE_SKILL() -> void:
    pass

# 触发技能：保证出现
func trigger_GUARANTEE_APPEAR() -> void:
    pass

# 触发技能：增加出现概率
func trigger_INCREASE_APPEAR() -> void:
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
