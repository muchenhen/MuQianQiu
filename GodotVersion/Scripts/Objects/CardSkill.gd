extends Node

class_name CardSkill

var card_skill_id: int = 0
var table_manager = null

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

func _init(skill_id: int):
    self.card_skill_id = skill_id
    
func _ready():
    # 初始化表格管理器
    table_manager = TableManager.get_instance()

# 获取技能ID
func get_skill_id() -> int:
    return self.card_skill_id

# 根据卡牌ID获取技能信息
static func get_card_skill_info(card_id: int, table_manager_instance) -> Dictionary:
    # 从Skills表获取信息
    var skills_table = table_manager_instance.get_table("Skills")
    
    # 遍历Skills表寻找匹配的卡牌ID
    for index in skills_table.keys():
        var skill = skills_table[index]
        if skill.has("CardID") and skill["CardID"] == card_id:
            return skill
            
    return Dictionary()

# 格式化技能文本，用于UI显示
static func format_skill_text(skill_type: String, target: String, _target_id, value) -> String:
    var text = "[center][b]" + skill_type + "[/b][/center]"
    
    # 添加技能描述（使用更大的字号）
    text += "\n[center][font_size=20]效果: "
    
    match skill_type:
        "禁用技能":
            text += "禁用" + (target if target else "对方") + "的技能"
        "保证出现":
            text += "确保" + target + "出现在牌局中"
        "增加分数":
            text += "为" + target + "增加" + str(value) + "分"
        "复制技能":
            text += "复制对方的技能"
        "交换卡牌":
            text += "与对方交换卡牌"
        "翻开对手手牌":
            text += "可以查看对手的手牌"
        "交换后无效":
            text += "交换后技能失效"
        _:
            text += "特殊技能效果"
    
    text += "[/font_size][/center]"
    
    return text

# 根据枚举获取技能类型字符串
static func get_skill_type_string(type_enum) -> String:
    if SKILL_TYPE_STRINGS.has(type_enum):
        return SKILL_TYPE_STRINGS[type_enum]
    return "未知技能"

# 获取技能名称
func get_skill_name() -> String:
    var skill_info = CardSkill.get_card_skill_info(self.card_skill_id, table_manager)
    if skill_info and skill_info.has("SkillName"):
        return skill_info["SkillName"]
    return "未命名技能"

# 获取技能描述
func get_skill_description() -> String:
    var skill_info = CardSkill.get_card_skill_info(self.card_skill_id, table_manager)
    if skill_info:
        # 这里可以根据技能信息拼接完整描述
        return "技能详细描述"
    return "无描述"

# 获取技能类型
func get_skill_type() -> String:
    var skill_info = CardSkill.get_card_skill_info(self.card_skill_id, table_manager)
    if skill_info and skill_info.has("SkillType"):
        return skill_info["SkillType"]
    return "未知类型"

# 获取技能效果
func get_skill_effect() -> String:
    var skill_info = CardSkill.get_card_skill_info(self.card_skill_id, table_manager)
    if skill_info and skill_info.has("Effect"):
        return skill_info["Effect"]
    return "无效果"


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
