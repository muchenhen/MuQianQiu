extends Node2D

@onready var label_title: Label = $Label_Title
@onready var card_table_view: VBoxContainer = $ColorRect/ScrollContainer/CardTableView
@onready var start_button: Button = $StartButton
@onready var scroll_container: ScrollContainer = $ColorRect/ScrollContainer
@onready var detail_card_parent = $ColorRect/RightUIContainer/ColorRect/DetailCardParent
@onready var special_card_detail_show = $ColorRect/RightUIContainer/ColorRect/DetailCardParent/SpecialCardDetailShow
@onready var skill_info_panel = $ColorRect/RightUIContainer/ColorRect/DetailCardParent/SkillInfoPanel
@onready var skill1_type_label = $ColorRect/RightUIContainer/ColorRect/DetailCardParent/SkillInfoPanel/VBoxContainer/Skill1Container/Skill1Type
@onready var skill1_target_label = $ColorRect/RightUIContainer/ColorRect/DetailCardParent/SkillInfoPanel/VBoxContainer/Skill1Container/Skill1Target
@onready var skill1_value_label = $ColorRect/RightUIContainer/ColorRect/DetailCardParent/SkillInfoPanel/VBoxContainer/Skill1Container/Skill1Value
@onready var skill2_type_label = $ColorRect/RightUIContainer/ColorRect/DetailCardParent/SkillInfoPanel/VBoxContainer/Skill2Container/Skill2Type
@onready var skill2_target_label = $ColorRect/RightUIContainer/ColorRect/DetailCardParent/SkillInfoPanel/VBoxContainer/Skill2Container/Skill2Target
@onready var skill2_value_label = $ColorRect/RightUIContainer/ColorRect/DetailCardParent/SkillInfoPanel/VBoxContainer/Skill2Container/Skill2Value

# 技能数据字典，从Skills.txt加载
var skill_data_dict = {}
# 卡牌名称字典，用于显示目标名称
var card_name_dict = {}

var card_ids: Array[int] = []
var selected_cards: Array[int] = []
var dragging = false  # 拖拽状态标志
var drag_start_position: Vector2  # 记录拖拽开始位置
var is_dragging_action = false  # 标记是否正在进行拖拽动作
var drag_threshold = 10  # 拖拽阈值，超过此距离才认为是拖拽动作
var card_instances = []  # 存储所有实例化的卡牌

# 卡牌场景
const CARD_SCENE = preload("res://Scripts/Objects/Card.tscn")
# 技能数据文件路径
const SKILL_DATA_PATH = "res://Tables/Skills.txt"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	# 设置ScrollContainer可以接收输入
	scroll_container.mouse_filter = Control.MOUSE_FILTER_PASS
	# 连接滚动容器的输入事件
	scroll_container.gui_input.connect(_on_scroll_container_gui_input)
	# 设置右侧详情卡片为不可点击
	special_card_detail_show.is_enable_click = false
	# 初始化时隐藏详情卡片的父节点
	detail_card_parent.visible = false
	# 加载技能数据
	_load_skill_data()

# 加载技能数据
func _load_skill_data() -> void:
	var file = FileAccess.open(SKILL_DATA_PATH, FileAccess.READ)
	if file:
		# 读取表头行
		var header = file.get_csv_line()
		
		# 读取数据行
		while !file.eof_reached():
			var line = file.get_csv_line()
			if line.size() > 1:
				var index = int(line[0])
				var card_id = int(line[1])
				var card_name = line[2]
				
				# 保存卡牌ID和名称的对应关系
				card_name_dict[card_id] = card_name
				
				# 创建技能数据结构
				var skill_data = {
					"index": index,
					"card_id": card_id,
					"card_name": card_name,
					"skill1": {
						"type": line[3],
						"target": line[4],
						"target_id": line[5],
						"value": line[6]
					},
					"skill2": {
						"type": line[7],
						"target": line[8],
						"target_id": line[9],
						"value": line[10]
					}
				}
				
				# 保存到字典中，以卡牌ID为键
				skill_data_dict[card_id] = skill_data
		
		file.close()

# 处理滚动容器的输入事件
func _on_scroll_container_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# 鼠标按下，记录起始位置
				dragging = true
				drag_start_position = event.position
				is_dragging_action = false
				# 临时禁用所有卡牌的点击
				_set_cards_clickable(false)
				# 确保事件不会传递给其他控件
				get_viewport().set_input_as_handled()
			else:
				# 鼠标释放
				dragging = false
				# 如果不是拖拽动作，启用卡牌点击
				if not is_dragging_action:
					# 短暂延迟后再启用卡牌点击，避免误触
					await get_tree().create_timer(0.05).timeout
					_set_cards_clickable(true)
				else:
					# 如果是拖拽动作，延迟稍长一点再启用卡牌点击
					await get_tree().create_timer(0.1).timeout
					_set_cards_clickable(true)
				
				is_dragging_action = false
				get_viewport().set_input_as_handled()
			
	elif event is InputEventMouseMotion and dragging:
		# 计算移动距离
		var distance = event.position.distance_to(drag_start_position)
		
		# 如果移动超过阈值，视为拖拽动作
		if distance > drag_threshold:
			is_dragging_action = true
			
			# 使用relative获取鼠标移动的相对量
			var relative_motion = event.relative
			
			# 更新垂直和水平滚动
			scroll_container.scroll_vertical -= int(relative_motion.y)
			scroll_container.scroll_horizontal -= int(relative_motion.x)
			
			# 确保事件不会传递给其他控件
			get_viewport().set_input_as_handled()

# 这个方法由卡片调用，通知发生了拖拽事件
func _notify_child_drag(relative_motion: Vector2) -> void:
	# 处理拖拽事件，移动ScrollContainer
	scroll_container.scroll_vertical -= int(relative_motion.y)
	scroll_container.scroll_horizontal -= int(relative_motion.x)
	
	# 确保事件不会传递给其他控件
	get_viewport().set_input_as_handled()

# 启用或禁用所有卡片的点击功能
func _set_cards_clickable(clickable: bool) -> void:
	for card in card_instances:
		card.is_enable_click = clickable

func set_card_datas(in_card_ids: Array[int]) -> void:
	card_ids = in_card_ids
	
	# 获取 GameInstance 中的版本选择
	var game_instance = GameManager.instance
	var filtered_ids: Array[int] = []
	
	# 根据选择的版本过滤卡牌
	for card_id in card_ids:
		var version = int(card_id / float(100)) # 获取卡牌的版本号（首位数字）
		if version == 1 and game_instance.is_open_first:
			filtered_ids.append(card_id)
		elif version == 2 and game_instance.is_open_second:
			filtered_ids.append(card_id)
		elif version == 3 and game_instance.is_open_third:
			filtered_ids.append(card_id)
	
	# 更新卡牌列表
	card_ids = filtered_ids
	card_ids.sort() # 将卡牌ID按从小到大排序

func init_card_table_view() -> void:
	var row_count = 6 # 总共6行
	var column_count = 6 # 每行6列，从7列改为6列
	
	# 清空卡牌实例列表
	card_instances.clear()
	
	# 清空当前所有行中的卡片（如果有的话）
	for r in range(1, row_count + 1):
		var row_node = card_table_view.get_node("MarginRow" + str(r) + "/HBoxRow" + str(r))
		for c in range(1, column_count + 1):
			var item_node = row_node.get_node("MarginItem" + str(c))
			
			# 删除已有的卡片（如果有）
			for child in item_node.get_children():
				child.queue_free()
	
	# 遍历所有卡片ID
	var card_index = 0
	for card_id in card_ids:
		if card_index >= row_count * column_count:
			break  # 超过布局容量，不再添加
		
		# 计算当前卡片应该放在哪一行哪一列
		var row = int(card_index / float(column_count)) + 1  # 行号从1开始，显式转换为整数
		var column = card_index % column_count + 1  # 列号从1开始
		
		# 使用场景实例化创建卡片
		var card = CARD_SCENE.instantiate()
		card.update_card_info_by_id(card_id)
		
		# 获取对应的容器节点
		var row_node = card_table_view.get_node("MarginRow" + str(row) + "/HBoxRow" + str(row))
		var item_node = row_node.get_node("MarginItem" + str(column))
		
		# 添加卡片到容器节点
		item_node.add_child(card)
		
		# 调整卡片大小适应容器
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		# 连接卡片点击信号
		card.connect("card_clicked", Callable(self, "_on_card_selected"))
		
		# 将卡牌添加到实例列表中
		card_instances.append(card)
		
		card_index += 1

func _on_card_selected(card) -> void:
	# 如果正在拖拽，不处理点击
	if is_dragging_action:
		return
		
	# 处理卡片选择逻辑
	if selected_cards.has(card.ID):
		selected_cards.erase(card.ID)
		card.set_card_unchooesd()
	else:
		selected_cards.append(card.ID)
		card.set_card_chooesd()
		
	# 显示DetailCardParent
	detail_card_parent.visible = true
	
	# 更新右侧详情卡片显示
	special_card_detail_show.update_card_info_by_id(card.ID)
	
	# 更新技能详情
	_update_skill_info(card.ID)

# 更新技能详情显示
func _update_skill_info(card_id: int) -> void:
	if not skill_data_dict.has(card_id):
		# 如果没有找到技能数据，隐藏详情面板
		skill_info_panel.visible = false
		return
	
	# 显示技能详情面板
	skill_info_panel.visible = true
	
	var skill_data = skill_data_dict[card_id]
	
	# 更新技能1的详情
	_update_skill_display(
		skill_data.skill1,
		skill1_type_label,
		skill1_target_label,
		skill1_value_label
	)
	
	# 更新技能2的详情
	_update_skill_display(
		skill_data.skill2,
		skill2_type_label,
		skill2_target_label,
		skill2_value_label
	)

# 更新单个技能的显示
func _update_skill_display(skill_data: Dictionary, type_label: Label, target_label: Label, value_label: Label) -> void:
	# 如果技能类型为空，则表示没有此技能
	if skill_data.type.strip_edges() == "":
		type_label.text = "类型: 无"
		target_label.text = "目标: 无"
		value_label.text = "数值: 无"
		return
	
	# 设置技能类型
	type_label.text = "类型: " + skill_data.type
	
	# 处理技能目标
	var target_text = "目标: "
	if skill_data.target.strip_edges() != "":
		if skill_data.target == "包含自身":
			target_text += "包含自身"
		else:
			target_text += skill_data.target
			
			# 如果有目标ID，查找目标卡牌名
			if skill_data.target_id.strip_edges() != "":
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
	if skill_data.value.strip_edges() != "":
		value_text += skill_data.value
	else:
		value_text += "无"
	
	value_label.text = value_text

func _on_start_button_pressed() -> void:
	# 处理开始游戏按钮点击事件
	if selected_cards.size() > 0:
		# 触发选择完成事件，可以在此处添加将选择的卡片信息发送到游戏管理器的代码
		print("Selected cards: ", selected_cards)
		# 在这里添加跳转到下一个场景或开始游戏的逻辑
