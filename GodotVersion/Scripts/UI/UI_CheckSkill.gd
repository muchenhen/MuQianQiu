extends Node2D

# 用于展示卡牌技能的UI
# 可以显示最多两张卡牌的技能信息

signal closed

var card1: Card = null
var card2: Card = null
var table_manager = null

# 初始化UI
func _ready():
	table_manager = TableManager.get_instance()

# 设置第一张卡的数据
func set_card1(card_instance: Card):
	card1 = card_instance
	update_card_display(card_instance, $Background/CardContainer/Row1)

# 设置第二张卡的数据
func set_card2(card_instance: Card):
	card2 = card_instance
	update_card_display(card_instance, $Background/CardContainer/Row2)

# 更新卡牌显示
func update_card_display(card_instance: Card, row_container):
	if card_instance == null:
		row_container.visible = false
		return
		
	row_container.visible = true
	var card_visual = row_container.get_node("CardVisual")
	var skill1 = row_container.get_node("Skill1")
	var skill2 = row_container.get_node("Skill2")
	
	# 设置卡牌视觉部分
	card_visual.texture_normal = card_instance.texture_normal
	
	# 获取技能信息 - 使用CardSkill静态方法
	var skill_info = CardSkill.get_card_skill_info(card_instance.ID, table_manager)
	if skill_info:
		# 技能1
		if "Skill1Type" in skill_info and skill_info["Skill1Type"]:
			skill1.visible = true
			var skill1_text = CardSkill.format_skill_text(
				skill_info["Skill1Type"],
				skill_info.get("Skill1Target", ""),
				skill_info.get("Skill1TargetID", ""),
				skill_info.get("Skill1Value", "")
			)
			skill1.text = skill1_text
		else:
			skill1.visible = false
			
		# 技能2
		if "Skill2Type" in skill_info and skill_info["Skill2Type"]:
			skill2.visible = true
			var skill2_text = CardSkill.format_skill_text(
				skill_info["Skill2Type"],
				skill_info.get("Skill2Target", ""),
				skill_info.get("Skill2TargetID", ""),
				skill_info.get("Skill2Value", "")
			)
			skill2.text = skill2_text
		else:
			skill2.visible = false
	else:
		# 没有技能信息
		skill1.visible = false
		skill2.visible = false

# 关闭按钮点击事件
func _on_close_button_pressed():
	emit_signal("closed")
	queue_free()
