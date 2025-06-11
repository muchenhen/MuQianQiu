extends Node

class_name SkillManager

static var instance: SkillManager = null

# 获取单例实例
static func get_instance() -> SkillManager:
    if instance == null:
        instance = SkillManager.new()
    return instance

# 技能注册表 - 保存每个技能类型的处理函数
var skill_handlers = {}

func check_guarantee_card_skills():
    # 检查待生效的技能中是否有"保证出现"技能，有的话执行并按照技能补充PublicCardDeal
    # TODO：等待完成保证出现
    pass

func check_increased_probability_skills():
    # 检查待生效的技能中是否有"增加出现概率"技能，有的话执行并按照技能补充PublicCardDeal
    # TODO：等待完成增加出现概率
    pass