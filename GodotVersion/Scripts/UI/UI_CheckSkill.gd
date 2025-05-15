extends Control

class_name UI_CheckSkill

# 引用场景节点
@onready var card1 = $CardsContainer/Card1Parent/Card1
@onready var card2 = $CardsContainer/Card2Parent/Card2
@onready var label_card1 = $CardsContainer/Card1Parent/Label_Card1
@onready var label_card2 = $CardsContainer/Card2Parent/Label_Card2
@onready var button_confirm = $ButtonContainer/Button_Confirm

# 技能信息面板
@onready var skill_panel = $SkillPanel
@onready var skill1_type = $SkillPanel/VBoxContainer/Skill1Container/Skill1Type
@onready var skill1_target = $SkillPanel/VBoxContainer/Skill1Container/Skill1Target
@onready var skill1_value = $SkillPanel/VBoxContainer/Skill1Container/Skill1Value
@onready var skill2_type = $SkillPanel/VBoxContainer/Skill2Container/Skill2Type
@onready var skill2_target = $SkillPanel/VBoxContainer/Skill2Container/Skill2Target
@onready var skill2_value = $SkillPanel/VBoxContainer/Skill2Container/Skill2Value

# 技能效果展示面板
@onready var effect_panel = $EffectPanel
@onready var label_effect = $EffectPanel/Label_Effect

# 存储传入的数据
var base_card_data: Dictionary
var special_card_data: Dictionary
var player_owner: Player
var ui_manager: UIManager

# 存储技能数据
var skill_data_dict = {}
# 卡牌名称字典，用于显示目标名称
var card_name_dict = {}

# 完成信号
signal check_skill_finished()

func _ready():
	# 初始化UI管理器引用
	ui_manager = UIManager.get_instance()
	
	# 连接按钮事件
	button_confirm.pressed.connect(_on_confirm_button_pressed)
	
	# 禁用卡牌点击
	card1.disable_click()
	card2.disable_click()
	
	# 默认隐藏效果面板
	effect_panel.visible = false
	
	# 加载技能和卡牌数据
	_load_data()

# 加载必要的卡牌和技能数据
func _load_data() -> void:
	# 加载卡牌名称映射
	var table_manager = TableManager.get_instance()
	var cards_table = table_manager.get_table("Cards")
	
	for card_id in cards_table.keys():
		if card_id == 0:
			continue
		var card_info = cards_table[card_id]
		card_name_dict[card_id] = card_info["Name"]
	
	# 加载技能数据
	_load_skill_data()

# 使用TableManager加载技能数据
func _load_skill_data() -> void:
	var table_manager = TableManager.get_instance()
	var skills_table = table_manager.get_table("Skills")
	
	# 遍历Skills表的所有行
	for index in skills_table.keys():
		if index == 0:
			continue
		var skill_row = skills_table[index]
		
		var card_id = int(skill_row["CardID"])
		var card_name = skill_row["CardName"]
		
		# 创建技能数据结构
		var skill_data = {
			"index": index,
			"card_id": card_id,
			"card_name": card_name,
			"skill1": {
				"type": skill_row["Skill1Type"],
				"target": skill_row["Skill1Target"],
				"target_id": skill_row["Skill1TargetID"],
				"value": skill_row["Skill1Value"]
			},
			"skill2": {
				"type": skill_row["Skill2Type"],
				"target": skill_row["Skill2Target"],
				"target_id": skill_row["Skill2TargetID"],
				"value": skill_row["Skill2Value"]
			}
		}
		
		# 保存到字典中，以卡牌ID为键
		skill_data_dict[card_id] = skill_data

# 初始化界面，显示卡牌和技能信息
func initialize(base_card: Card, special_card: Card, player: Player) -> void:
	player_owner = player
	
	# 保存卡牌数据
	if base_card:
		base_card_data = {
			"ID": base_card.ID,
			"Name": base_card.Name,
			"Type": base_card.Type,
			"BaseID": base_card.BaseID,
			"Special": base_card.Special
		}
	
	if special_card:
		special_card_data = {
			"ID": special_card.ID,
			"Name": special_card.Name,
			"Type": special_card.Type,
			"BaseID": special_card.BaseID,
			"Special": special_card.Special
		}
	
	# 更新卡牌显示
	_update_card_display(base_card, special_card)
	
	# 更新技能信息
	if special_card:
		_update_skill_info(special_card.ID)
	else:
		skill_panel.visible = false
	
	# 显示特效面板（如果需要的话）
	_check_skill_effects(special_card)

# 更新卡牌显示
func _update_card_display(base_card: Card, special_card: Card) -> void:
	if base_card:
		# 复制基础卡的信息到UI中的卡牌
		card1.update_card_info_by_id(base_card.ID)
		label_card1.text = "基础卡: " + base_card.Name
	else:
		# 如果没有基础卡，隐藏卡牌1
		card1.visible = false
		label_card1.visible = false
	
	if special_card:
		# 复制特殊卡的信息到UI中的卡牌
		card2.update_card_info_by_id(special_card.ID)
		label_card2.text = "特殊卡: " + special_card.Name
	else:
		# 如果没有特殊卡，则不显示箭头和卡牌2
		card2.visible = false
		label_card2.visible = false
		$CardsContainer/Arrow.visible = false

# 更新技能信息显示
func _update_skill_info(card_id: int) -> void:
	if not skill_data_dict.has(card_id):
		# 如果没有找到技能数据，隐藏详情面板
		skill_panel.visible = false
		return
	
	# 显示技能详情面板
	skill_panel.visible = true
	
	var skill_data = skill_data_dict[card_id]
	
	# 更新技能1的详情
	_update_skill_display(
		skill_data.skill1,
		skill1_type,
		skill1_target,
		skill1_value
	)
	
	# 更新技能2的详情
	_update_skill_display(
		skill_data.skill2,
		skill2_type,
		skill2_target,
		skill2_value
	)

# 更新单个技能的显示
func _update_skill_display(skill_data: Dictionary, type_label: Label, target_label: Label, value_label: Label) -> void:
	# 如果技能类型为空，则表示没有此技能
	if typeof(skill_data.type) == TYPE_STRING and skill_data.type.strip_edges() == "":
		type_label.text = "类型: 无"
		target_label.text = "目标: 无"
		value_label.text = "数值: 无"
		return
	
	# 设置技能类型
	type_label.text = "类型: " + str(skill_data.type)
	
	# 处理技能目标
	var target_text = "目标: "
	if typeof(skill_data.target) == TYPE_STRING and skill_data.target.strip_edges() != "":
		if skill_data.target == "包含自身":
			target_text += "包含自身"
		else:
			target_text += str(skill_data.target)
			
			# 如果有目标ID，查找目标卡牌名
			if typeof(skill_data.target_id) == TYPE_STRING and skill_data.target_id.strip_edges() != "":
				# 检查是否为括号中的ID列表
				if "(" in skill_data.target_id and ")" in skill_data.target_id:
					var id_list_str = skill_data.target_id.trim_prefix("(").trim_suffix(")")
					var id_list = id_list_str.split(",")
					
					var target_names = []
					for id_str in id_list:
						var id = int(id_str)
						if card_name_dict.has(id):
							target_names.append(card_name_dict[id])
					
					if target_names.size() > 0:
						target_text += " (" + ", ".join(target_names) + ")"
				else:
					# 单个ID
					var target_id = int(skill_data.target_id)
					if card_name_dict.has(target_id):
						target_text += " (" + card_name_dict[target_id] + ")"
	else:
		target_text += "无"
	
	target_label.text = target_text
	
	# 处理技能数值
	var value_text = "数值: "
	if typeof(skill_data.value) == TYPE_STRING and skill_data.value.strip_edges() != "":
		value_text += skill_data.value
	elif typeof(skill_data.value) != TYPE_STRING and skill_data.value:
		value_text += str(skill_data.value)
	else:
		value_text += "无"
	
	value_label.text = value_text

# 检查技能效果并显示
func _check_skill_effects(special_card: Card) -> void:
	if not special_card:
		return
	
	# 获取技能数据
	var card_id = special_card.ID
	if not skill_data_dict.has(card_id):
		return
	
	var skill_data = skill_data_dict[card_id]
	var effect_text = "技能效果: "
	var has_effect = false
	
	# 检查技能1
	skill1_type = skill_data.skill1.type
	if typeof(skill1_type) == TYPE_STRING and skill1_type.strip_edges() != "":
		has_effect = true
		effect_text += _get_skill_effect_description(skill1_type, skill_data.skill1)
	
	# 检查技能2
	skill2_type = skill_data.skill2.type
	if typeof(skill2_type) == TYPE_STRING and skill2_type.strip_edges() != "":
		if has_effect:
			effect_text += "，并且"
		has_effect = true
		effect_text += _get_skill_effect_description(skill2_type, skill_data.skill2)
	
	if has_effect:
		effect_panel.visible = true
		label_effect.text = effect_text

# 获取技能效果描述
func _get_skill_effect_description(skill_type: String, skill_data: Dictionary) -> String:
	match skill_type:
		"禁用技能":
			return "使对手一张珍稀牌技能失效"
		"保证出现":
			if skill_data.target:
				return "保证下回合出现" + str(skill_data.target)
			return "保证下回合出现特定卡牌"
		"增加分数":
			if skill_data.target and skill_data.value:
				return "使" + str(skill_data.target) + "的分数增加" + str(skill_data.value)
			return "增加特定组合的分数"
		"翻开对手手牌":
			if skill_data.value:
				return "随机翻开对手" + str(int(float(skill_data.value))) + "张手牌"
			return "随机翻看对手手牌"
		"交换卡牌":
			return "与对手交换一张卡牌"
		"复制技能":
			return "复制对手一张珍稀牌技能"
		"交换后无效":
			return "被交换后的卡牌技能无效"
		"增加出现":
			if skill_data.target:
				return "增加" + str(skill_data.target) + "出现的概率"
			return "增加特定卡牌出现的概率"
		_:
			return "应用特殊技能效果"

# 确认按钮点击事件
func _on_confirm_button_pressed() -> void:
	# 发送完成信号
	emit_signal("check_skill_finished")
	
	# 应用技能逻辑 (这里只是UI展示，实际的技能应用在game manager中进行)
	
	# 关闭界面
	ui_manager.destroy_ui("UI_CheckSkill")