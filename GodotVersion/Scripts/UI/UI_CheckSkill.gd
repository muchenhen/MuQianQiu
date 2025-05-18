extends Node2D

# 用于展示卡牌技能的UI
# 可以显示最多两张卡牌的技能信息

signal closed

var card1_data = null
var card2_data = null

# 初始化UI
func _ready():
	pass

# 设置第一张卡的数据
func set_card1(card_data):
	card1_data = card_data
	update_card_display(card_data, $Background/CardContainer/Row1)

# 设置第二张卡的数据
func set_card2(card_data):
	card2_data = card_data
	update_card_display(card_data, $Background/CardContainer/Row2)

# 更新卡牌显示
func update_card_display(card_data, row_container):
	if card_data == null:
		row_container.visible = false
		return
		
	row_container.visible = true
	var card_visual = row_container.get_node("CardVisual")
	var skill1 = row_container.get_node("Skill1")
	var skill2 = row_container.get_node("Skill2")
	
	# 设置卡牌图像
	if "texture" in card_data:
		card_visual.texture_normal = card_data.texture
		
	# 设置技能描述
	if "skills" in card_data and card_data.skills.size() > 0:
		skill1.visible = true
		skill1.text = "[center][b]" + card_data.skills[0].name + "[/b][/center]\n" + card_data.skills[0].description
		
		if card_data.skills.size() > 1:
			skill2.visible = true
			skill2.text = "[center][b]" + card_data.skills[1].name + "[/b][/center]\n" + card_data.skills[1].description
		else:
			skill2.visible = false
	else:
		skill1.visible = false
		skill2.visible = false

# 关闭按钮点击事件
func _on_close_button_pressed():
	emit_signal("closed")
	queue_free()
