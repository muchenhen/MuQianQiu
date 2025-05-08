extends Node2D

@onready var label_title: Label = $Label_Title
@onready var card_table_view: VBoxContainer = $ColorRect/ScrollContainer/CardTableView
@onready var start_button: Button = $StartButton
@onready var scroll_container: ScrollContainer = $ColorRect/ScrollContainer

var card_ids: Array[int] = []
var selected_cards: Array[int] = []
var dragging = false  # 拖拽状态标志
var drag_start_position: Vector2  # 记录拖拽开始位置
var is_dragging_action = false  # 标记是否正在进行拖拽动作
var drag_threshold = 10  # 拖拽阈值，超过此距离才认为是拖拽动作
var card_instances = []  # 存储所有实例化的卡牌

# 卡牌场景
const CARD_SCENE = preload("res://Scripts/Objects/Card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	# 设置ScrollContainer可以接收输入
	scroll_container.mouse_filter = Control.MOUSE_FILTER_PASS
	# 连接滚动容器的输入事件
	scroll_container.gui_input.connect(_on_scroll_container_gui_input)

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

func _on_start_button_pressed() -> void:
	# 处理开始游戏按钮点击事件
	if selected_cards.size() > 0:
		# 触发选择完成事件，可以在此处添加将选择的卡片信息发送到游戏管理器的代码
		print("Selected cards: ", selected_cards)
		# 在这里添加跳转到下一个场景或开始游戏的逻辑
