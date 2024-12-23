extends Node

class_name CardSkill

var card_skill_id: int = 0

enum SKILL_TYPE{
    NORMAL,
    SPECIAL,
    PASSIVE
}

enum SKILL_EFFECT{
    NORMAL,
    SPECIAL
}

func _init(skill_id: int):
    self.card_skill_id = skill_id

func _ready():
    pass

func get_skill_id() -> int:
    return self.card_skill_id

func get_skill_name() -> String:
    return "技能名称"

func get_skill_description() -> String:
    return "技能描述"

func get_skill_type() -> String:
    return "技能类型"

func get_skill_effect() -> String:
    return "技能效果"


# 技能触发
func trigger_skill() -> void:
    pass

# 技能效果A
func trigger_skill_effect_A() -> void:
    pass

func trigger_skill_effect_B() -> void:
    pass

func trigger_skill_effect_C() -> void:
    pass

func trigger_skill_effect_D() -> void:
    pass

func trigger_skill_effect_E() -> void:
    pass