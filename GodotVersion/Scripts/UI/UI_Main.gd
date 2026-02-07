extends Node

class_name UI_Main

# 添加珍稀牌动画完成信号
signal skill_cards_animation_completed

@onready var player_a_deal:Button = $PlayerADeal
@onready var player_b_deal:Button = $PlayerBDeal
@onready var player_a_skill_card_zone:ColorRect = $Cards/PlayerASkillCardZone
@onready var player_b_skill_card_zone:ColorRect = get_node_or_null("Cards/PlayerBSkillCardZone")
@onready var player_a_score_animation:Label = $UI/Text_AScoreAnimation
@onready var player_b_score_animation:Label = $UI/Text_BScoreAnimation

# 分数动画标签的初始Y位置（从tscn文件中获取）
const PLAYER_A_SCORE_ANIMATION_Y = 600.0
const PLAYER_B_SCORE_ANIMATION_Y = 336.0

var ui_manager:UIManager = UIManager.get_instance()
var card_manager = CardManager.get_instance()
var input_manager = InputManager.get_instance()
var _debug_layer: CanvasLayer = null
var _debug_log: RichTextLabel = null
const ENABLE_SKILL_DEBUG_PANEL: bool = false

# 玩家A的珍稀牌实例
var player_a_skill_cards:Array[Card] = []
var player_b_skill_cards:Array[Card] = []
# 等待珍稀牌动画完成的回调函数
var pending_after_animation_callback = null
var pending_after_animation_callback_b = null

func _ready() -> void:
	# player_a_deal绑定点击事件
	player_a_deal.connect("pressed", Callable(self, "_on_player_a_deal_clcik"))
	# player_b_deal绑定点击事件
	player_b_deal.connect("pressed", Callable(self, "_on_player_b_deal_clcik"))
	
	# 确保技能卡区域不会被显示，但卡会显示
	if player_a_skill_card_zone:
		player_a_skill_card_zone.color = Color(0, 0, 0, 0)
	_ensure_player_b_skill_zone()
	if player_b_skill_card_zone:
		player_b_skill_card_zone.color = Color(0, 0, 0, 0)
	
	# 监听玩家A珍稀牌选择变化
	var game_instance = GameManager.instance
	if game_instance:
		# 确保信号未连接才进行连接，避免重复
		if not game_instance.is_connected("game_start", Callable(self, "_on_game_start")):
			game_instance.connect("game_start", Callable(self, "_on_game_start"))
			print("UI_Main: 已连接game_start信号")
		if ENABLE_SKILL_DEBUG_PANEL and not game_instance.is_connected("skill_debug_event", Callable(self, "_on_skill_debug_event")):
			game_instance.connect("skill_debug_event", Callable(self, "_on_skill_debug_event"))
	
	if ENABLE_SKILL_DEBUG_PANEL:
		_setup_skill_debug_panel()

# 游戏开始后，显示玩家的珍稀牌
func _on_game_start():
	print("UI_Main: 收到游戏开始信号")
	var player_a = GameManager.instance.player_a
	var player_b = GameManager.instance.player_b
	if player_a:
		print("UI_Main: 开始更新玩家A的珍稀牌")
		update_player_a_skill_cards(player_a)
	else:
		print("UI_Main: 无法获取player_a对象")

	if player_b:
		print("UI_Main: 开始更新玩家B的珍稀牌")
		update_player_b_skill_cards(player_b)
	else:
		print("UI_Main: 无法获取player_b对象")

	if _debug_log != null:
		_debug_log.clear()
		_debug_log.append_text("[技能调试] 已开始新对局\n")

func _apply_player_b_special_card_visibility(card: Card) -> void:
	if card == null:
		return
	if GameManager.opponent_hand_visible:
		card.update_card()
	else:
		card.set_card_back()

func refresh_player_b_special_cards_visibility(opponent_visible: bool) -> void:
	for card in player_b_skill_cards:
		if not is_instance_valid(card):
			continue
		if opponent_visible:
			card.update_card()
		else:
			card.set_card_back()

func _on_skill_debug_event(payload: Dictionary) -> void:
	if _debug_log == null:
		return

	var entries = payload.get("entries", [])
	if not (entries is Array):
		return

	for item in entries:
		if not (item is Dictionary):
			continue
		var line = "回合: %s | 玩家: %s | 发动卡: %s | 技能: %s | 结果: %s" % [
			str(item.get("round", "-")),
			str(item.get("player", "Unknown")),
			str(item.get("card_name", "未知卡牌")),
			str(item.get("skill_name", "未知技能")),
			str(item.get("result", "无")),
		]
		_debug_log.append_text(line + "\n")

	var last_line = maxi(_debug_log.get_line_count() - 1, 0)
	_debug_log.scroll_to_line(last_line)

func _setup_skill_debug_panel() -> void:
	if _debug_layer != null:
		return

	_debug_layer = CanvasLayer.new()
	_debug_layer.layer = 90
	add_child(_debug_layer)

	var panel = PanelContainer.new()
	panel.name = "SkillDebugPanel"
	panel.position = Vector2(1360, 28)
	panel.custom_minimum_size = Vector2(530, 290)
	_debug_layer.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "技能触发调试面板"
	vbox.add_child(title)

	_debug_log = RichTextLabel.new()
	_debug_log.bbcode_enabled = false
	_debug_log.fit_content = false
	_debug_log.scroll_following = true
	_debug_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_debug_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_debug_log.custom_minimum_size = Vector2(510, 220)
	vbox.add_child(_debug_log)

	var clear_btn = Button.new()
	clear_btn.text = "清空日志"
	clear_btn.pressed.connect(func():
		if _debug_log != null:
			_debug_log.clear()
			_debug_log.append_text("[技能调试] 日志已清空\n")
	)
	vbox.add_child(clear_btn)

	_debug_log.append_text("[技能调试] 面板初始化完成，等待技能触发...\n")

# 将两个点击牌堆的按钮移动到最上面

func _on_player_a_deal_clcik():
	print("玩家A牌堆点击")
	var player_a = GameManager.instance.player_a
	var deal_status:UI_DealStatus = ui_manager.open_ui("UI_DealStatus")
	ui_manager.move_ui_instance_to_top(deal_status)
	deal_status.update_deal_status_by_player(player_a)

func _on_player_b_deal_clcik():
	print("玩家B牌堆点击")

func _ensure_player_b_skill_zone() -> void:
	if player_b_skill_card_zone != null:
		return
	var cards_root = get_node_or_null("Cards")
	if cards_root == null:
		return

	var zone = ColorRect.new()
	zone.name = "PlayerBSkillCardZone"
	zone.position = Vector2(1632, 53)
	zone.size = Vector2(272, 256)
	zone.color = Color(0, 0, 0, 0)
	cards_root.add_child(zone)
	player_b_skill_card_zone = zone
	
# 更新玩家A的珍稀牌显示
func update_player_a_skill_cards(player:Player) -> void:
	# 清理旧的卡牌
	for card in player_a_skill_cards:
		if is_instance_valid(card):
			card.queue_free()
	player_a_skill_cards.clear()
	
	# 获取玩家选择的珍稀牌ID数组
	var skill_card_ids = player.get_selected_special_cards()
	if skill_card_ids.size() == 0:
		return
		
	# 计算珍稀牌区域的布局参数
	var zone_rect = Rect2(player_a_skill_card_zone.position, player_a_skill_card_zone.size)
	var card_width = card_manager.CARD_WIDTH
	var card_height = card_manager.CARD_HEIGHT
	
	# 确保卡片放在区域内
	var total_cards = skill_card_ids.size()
	
	# 计算卡片叠加的偏移量，确保所有卡片都在区域内
	# 如果卡片很多，偏移量会变小，确保最后一张卡片也在区域内
	var max_width = zone_rect.size.x - 20  # 左右各预留10像素边距
	var max_overlap = card_width - 30  # 卡片最大重叠量，确保至少露出30像素
	var min_overlap = 10  # 最小重叠量
	
	# 计算需要的重叠量，确保所有卡片都能在区域内显示
	var required_width = card_width + (total_cards - 1) * (card_width - max_overlap)
	var overlap = max_overlap
	
	if required_width > max_width && total_cards > 1:
		# 需要更大的重叠来适应区域
		var remaining_width = max_width - card_width  # 除第一张卡外可用宽度
		var cards_to_fit = total_cards - 1
		overlap = max(min_overlap, card_width - remaining_width / cards_to_fit)
	
	# 计算卡片间的水平偏移，这决定了卡片的叠加程度
	var offset_x = card_width - overlap
	
	# 计算整体卡牌组的总宽度
	var total_width = card_width + offset_x * (total_cards - 1)
	
	# 计算起始位置，使卡片组在区域内居中
	var start_x = zone_rect.position.x + (zone_rect.size.x - total_width) / 2
	var start_y = zone_rect.position.y + (zone_rect.size.y - card_height) / 2
	
	# 阻止用户输入，直到动画完成
	input_manager.block_input()
	
	# 创建并放置珍稀牌，但启用动画
	_create_skill_cards_with_animation(skill_card_ids, start_x, start_y, offset_x, player_a_skill_card_zone.z_index)
	
	print("玩家A珍稀牌动画开始，共", skill_card_ids.size(), "张卡")

# 使用动画创建珍稀牌
func _create_skill_cards_with_animation(skill_card_ids: Array, start_x: float, start_y: float, offset_x: float, base_z_index: int) -> void:
	# 清除任何可能正在运行的卡片动画计时器
	if has_node("CardAnimTimer"):
		get_node("CardAnimTimer").queue_free()
	
	# 创建新的计时器节点控制卡片出现的时间
	var timer = Timer.new()
	timer.name = "CardAnimTimer"
	timer.one_shot = false
	timer.wait_time = 0.15  # 每张卡出现的间隔，可以调整这个数值控制速度
	self.add_child(timer)
	
	# 动画参数
	var anim_offset_y = -50  # 卡片出现时的Y方向偏移
	var anim_duration = 0.3  # 单张卡片动画持续时间
	
	# 存储动画相关信息
	var anim_data = {
		"card_ids": skill_card_ids,
		"current_index": 0,
		"start_x": start_x,
		"start_y": start_y,
		"offset_x": offset_x,
		"base_z_index": base_z_index,
		"anim_offset_y": anim_offset_y,
		"anim_duration": anim_duration
	}
	
	# 连接计时器信号
	timer.timeout.connect(func(): _show_next_card(anim_data, timer))
	
	# 启动计时器显示第一张卡
	timer.start()

# 显示下一张卡片
func _show_next_card(anim_data: Dictionary, timer: Timer) -> void:
	var index = anim_data["current_index"]
	
	# 检查是否所有卡片都已显示
	if index >= anim_data["card_ids"].size():
		timer.queue_free()  # 停止计时器
		print("玩家A珍稀牌动画完成，共", player_a_skill_cards.size(), "张卡")
		# 动画完成后，恢复用户输入
		input_manager.allow_input()
		# 发出动画完成信号
		emit_signal("skill_cards_animation_completed")
		# 如果有待执行的回调函数，执行它
		if pending_after_animation_callback != null:
			print("执行动画完成后的回调函数")
			pending_after_animation_callback.call()
			pending_after_animation_callback = null
		return
	
	# 获取当前要显示的卡片ID
	var card_id = anim_data["card_ids"][index]
	
	# 创建卡片
	var card = card_manager.create_one_card(card_id)
	
	# 添加到场景中
	$Cards.add_child(card)
	player_a_skill_cards.append(card)
	
	# 设置卡牌位置，初始透明度很低，位置在目标位置上方
	var x_pos = anim_data["start_x"] + index * anim_data["offset_x"]
	var initial_y = anim_data["start_y"] + anim_data["anim_offset_y"]
	card.position = Vector2(x_pos, initial_y)
	
	# 完全透明并添加轻微缩放效果，增强视觉冲击力
	card.modulate.a = 0.0  # 开始时完全透明
	card.scale = Vector2(0.9, 0.9)  # 开始时稍微小一点
	
	# 设置Z序，右侧卡片层级高，确保新的卡片显示在前面
	card.z_index = anim_data["base_z_index"] + index + 1
	
	# 更新卡牌显示并禁用点击
	card.update_card()
	card.disable_click()
	
	# 创建Tween动画
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)  # 使用BACK过渡效果，动画会更有弹性
	
	# 从上往下移动的动画
	tween.parallel().tween_property(card, "position:y", anim_data["start_y"], anim_data["anim_duration"])
	
	# 透明度从0到1的动画，使用闪光效果
	var flash_tween = create_tween()
	flash_tween.set_trans(Tween.TRANS_CUBIC)
	
	# 先快速到高亮（略微过亮）然后回到正常
	flash_tween.tween_property(card, "modulate:a", 1.2, anim_data["anim_duration"] * 0.7)
	flash_tween.tween_property(card, "modulate:a", 1.0, anim_data["anim_duration"] * 0.3)
	
	# 添加缩放动画，让卡片有一点"弹"的感觉
	var scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_ELASTIC)
	scale_tween.tween_property(card, "scale", Vector2(1.0, 1.0), anim_data["anim_duration"])
	
	# 进入下一张卡片的索引
	anim_data["current_index"] += 1

# 修改后的send_special_cards_to_player_a函数，确保动画完成后才执行
func send_special_cards_to_player_a() -> void:
	# 获取玩家A
	var player_a = GameManager.instance.player_a
	if player_a == null:
		print("玩家A对象无效")
		return
	
	# 检查是否有珍稀牌动画正在播放
	if has_node("CardAnimTimer"):
		print("珍稀牌动画正在播放，将回调函数加入到动画完成后执行")
		# 如果动画正在播放，将逻辑设置为回调函数，等待动画完成后执行
		pending_after_animation_callback = func():
			print("动画完成后，将珍稀牌实例传递给玩家A")
			player_a.set_selected_special_cards_instance(player_a_skill_cards)
	else:
		# 如果没有动画正在播放，直接执行
		print("没有珍稀牌动画播放中，直接将珍稀牌实例传递给玩家A")
		player_a.set_selected_special_cards_instance(player_a_skill_cards)

func send_special_cards_to_player_b() -> void:
	var player_b = GameManager.instance.player_b
	if player_b == null:
		print("玩家B对象无效")
		return
	if has_node("CardAnimTimerB"):
		print("玩家B珍稀牌动画正在播放，将回调函数加入到动画完成后执行")
		pending_after_animation_callback_b = func():
			print("动画完成后，将珍稀牌实例传递给玩家B")
			player_b.set_selected_special_cards_instance(player_b_skill_cards)
	else:
		player_b.set_selected_special_cards_instance(player_b_skill_cards)

func update_player_b_skill_cards(player: Player) -> void:
	_ensure_player_b_skill_zone()
	for card in player_b_skill_cards:
		if is_instance_valid(card):
			card.queue_free()
	player_b_skill_cards.clear()

	var skill_card_ids = player.get_selected_special_cards()
	if skill_card_ids.is_empty():
		return
	if player_b_skill_card_zone == null:
		return

	var zone_rect = Rect2(player_b_skill_card_zone.position, player_b_skill_card_zone.size)
	var card_width = card_manager.CARD_WIDTH
	var card_height = card_manager.CARD_HEIGHT
	var total_cards = skill_card_ids.size()
	var max_width = zone_rect.size.x - 20
	var max_overlap = card_width - 30
	var min_overlap = 10
	var required_width = card_width + (total_cards - 1) * (card_width - max_overlap)
	var overlap = max_overlap
	if required_width > max_width and total_cards > 1:
		var remaining_width = max_width - card_width
		var cards_to_fit = total_cards - 1
		overlap = max(min_overlap, card_width - remaining_width / cards_to_fit)

	var offset_x = card_width - overlap
	var total_width = card_width + offset_x * (total_cards - 1)
	var start_x = zone_rect.position.x + (zone_rect.size.x - total_width) / 2
	var start_y = zone_rect.position.y + (zone_rect.size.y - card_height) / 2

	_create_skill_cards_with_animation_player_b(
		skill_card_ids,
		start_x,
		start_y,
		offset_x,
		player_b_skill_card_zone.z_index
	)

func _create_skill_cards_with_animation_player_b(skill_card_ids: Array, start_x: float, start_y: float, offset_x: float, base_z_index: int) -> void:
	if has_node("CardAnimTimerB"):
		get_node("CardAnimTimerB").queue_free()

	var timer = Timer.new()
	timer.name = "CardAnimTimerB"
	timer.one_shot = false
	timer.wait_time = 0.15
	self.add_child(timer)

	var anim_data = {
		"card_ids": skill_card_ids,
		"current_index": 0,
		"start_x": start_x,
		"start_y": start_y,
		"offset_x": offset_x,
		"base_z_index": base_z_index,
		"anim_offset_y": 50,
		"anim_duration": 0.3
	}

	timer.timeout.connect(func(): _show_next_card_player_b(anim_data, timer))
	timer.start()

func _show_next_card_player_b(anim_data: Dictionary, timer: Timer) -> void:
	var index = int(anim_data["current_index"])
	if index >= anim_data["card_ids"].size():
		timer.queue_free()
		print("玩家B珍稀牌动画完成，共", player_b_skill_cards.size(), "张卡")
		emit_signal("skill_cards_animation_completed")
		if pending_after_animation_callback_b != null:
			pending_after_animation_callback_b.call()
			pending_after_animation_callback_b = null
		return

	var card_id = int(anim_data["card_ids"][index])
	var card = card_manager.create_one_card(card_id)
	$Cards.add_child(card)
	player_b_skill_cards.append(card)

	var x_pos = anim_data["start_x"] + index * anim_data["offset_x"]
	var initial_y = anim_data["start_y"] + anim_data["anim_offset_y"]
	card.position = Vector2(x_pos, initial_y)
	card.modulate.a = 0.0
	card.scale = Vector2(0.9, 0.9)
	card.z_index = anim_data["base_z_index"] + index + 1
	_apply_player_b_special_card_visibility(card)
	card.disable_click()

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(card, "position:y", anim_data["start_y"], anim_data["anim_duration"])

	var flash_tween = create_tween()
	flash_tween.set_trans(Tween.TRANS_CUBIC)
	flash_tween.tween_property(card, "modulate:a", 1.2, anim_data["anim_duration"] * 0.7)
	flash_tween.tween_property(card, "modulate:a", 1.0, anim_data["anim_duration"] * 0.3)

	var scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_ELASTIC)
	scale_tween.tween_property(card, "scale", Vector2(1.0, 1.0), anim_data["anim_duration"])

	anim_data["current_index"] += 1

# 等待珍稀牌动画完成后执行指定的回调函数
func wait_for_skill_cards_animation_complete(callback: Callable) -> void:
	if has_node("CardAnimTimer") or has_node("CardAnimTimerB"):
		print("设置珍稀牌动画完成后的回调函数")
		pending_after_animation_callback = callback
	else:
		print("没有珍稀牌动画正在播放，直接执行回调函数")
		callback.call()

func is_skill_card_animation_running() -> bool:
	return has_node("CardAnimTimer") or has_node("CardAnimTimerB")

# 播放玩家A的分数增加动画
func play_player_a_score_animation(score: int) -> void:
	_play_score_animation(player_a_score_animation, score)

# 播放玩家B的分数增加动画
func play_player_b_score_animation(score: int) -> void:
	_play_score_animation(player_b_score_animation, score)

# 播放分数动画的通用方法
func _play_score_animation(label: Label, score: int) -> void:
	if not label:
		print("警告: 分数动画标签为 null")
		return
	
	# 获取标签的初始Y位置（从tscn文件中定义的固定值）
	var initial_y = PLAYER_A_SCORE_ANIMATION_Y if label == player_a_score_animation else PLAYER_B_SCORE_ANIMATION_Y
	
	print("开始播放分数动画，标签位置: ", label.position, " 初始Y: ", initial_y, " 分数: ", score)
	
	# 设置文本
	label.text = "+%d 分" % score
	
	# 重置状态：位置复原到初始位置，透明度为0（不可见）
	label.position.y = initial_y
	label.modulate.a = 0.0
	
	print("标签重置后位置: ", label.position, " 透明度: ", label.modulate.a)
	
	# 创建动画
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 淡入（透明度从0到1）
	tween.tween_property(label, "modulate:a", 1.0, 0.2)
	
	# 向上浮动（从初始位置向上移动40像素）
	tween.tween_property(label, "position:y", initial_y - 40, 1.0).set_delay(0.2)
	
	# 淡出（透明度从1到0）
	tween.tween_property(label, "modulate:a", 0.0, 0.3).set_delay(0.7)
	
	# 动画完成：重置位置和透明度
	tween.tween_callback(func():
		print("分数动画完成，重置标签状态")
		label.position.y = initial_y  # 重置到初始位置
		label.modulate.a = 0.0  # 透明度归零（完全不可见）
	)
	
	print("播放分数动画: +%d 分" % score)

func _exit_tree() -> void:
	var game_instance = GameManager.instance
	if ENABLE_SKILL_DEBUG_PANEL and game_instance != null and game_instance.is_connected("skill_debug_event", Callable(self, "_on_skill_debug_event")):
		game_instance.disconnect("skill_debug_event", Callable(self, "_on_skill_debug_event"))
