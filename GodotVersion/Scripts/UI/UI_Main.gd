extends Node

class_name UI_Main

@onready var player_a_deal:Button = $PlayerADeal
@onready var player_b_deal:Button = $PlayerBDeal
@onready var player_a_skill_card_zone:ColorRect = $Cards/PlayerASkillCardZone

var ui_manager:UIManager = UIManager.get_instance()
var card_manager = CardManager.get_instance()
var input_manager = InputManager.get_instance()

# 玩家A的特殊卡实例
var player_a_skill_cards = []

func _ready() -> void:
	# player_a_deal绑定点击事件
	player_a_deal.connect("pressed", Callable(self, "_on_player_a_deal_clcik"))
	# player_b_deal绑定点击事件
	player_b_deal.connect("pressed", Callable(self, "_on_player_b_deal_clcik"))
	
	# 确保技能卡区域不会被显示，但卡会显示
	if player_a_skill_card_zone:
		player_a_skill_card_zone.color = Color(0, 0, 0, 0)
	
	# 监听玩家A特殊卡选择变化
	var game_instance = GameManager.instance
	if game_instance:
		# 确保信号未连接才进行连接，避免重复
		if not game_instance.is_connected("game_start", Callable(self, "_on_game_start")):
			game_instance.connect("game_start", Callable(self, "_on_game_start"))
			print("UI_Main: 已连接game_start信号")

# 游戏开始后，显示玩家的特殊卡
func _on_game_start():
	print("UI_Main: 收到游戏开始信号")
	var player_a = GameManager.instance.player_a
	if player_a:
		print("UI_Main: 开始更新玩家A的特殊卡")
		update_player_a_skill_cards(player_a)
	else:
		print("UI_Main: 无法获取player_a对象")

# 将两个点击牌堆的按钮移动到最上面

func _on_player_a_deal_clcik():
	print("玩家A牌堆点击")
	var player_a = GameManager.instance.player_a
	var deal_status:UI_DealStatus = ui_manager.open_ui("UI_DealStatus")
	ui_manager.move_ui_instance_to_top(deal_status)
	deal_status.update_deal_status_by_player(player_a)

func _on_player_b_deal_clcik():
	print("玩家B牌堆点击")
	
# 更新玩家A的特殊卡显示
func update_player_a_skill_cards(player:Player) -> void:
	# 清理旧的卡牌
	for card in player_a_skill_cards:
		if is_instance_valid(card):
			card.queue_free()
	player_a_skill_cards.clear()
	
	# 获取玩家选择的特殊卡ID数组
	var skill_card_ids = player.get_selected_special_cards()
	if skill_card_ids.size() == 0:
		return
		
	# 计算特殊卡区域的布局参数
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
	
	# 创建并放置特殊卡，但启用动画
	_create_skill_cards_with_animation(skill_card_ids, start_x, start_y, offset_x, player_a_skill_card_zone.z_index)
	
	print("玩家A特殊卡动画开始，共", skill_card_ids.size(), "张卡")

# 使用动画创建特殊卡
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
		print("玩家A特殊卡动画完成，共", player_a_skill_cards.size(), "张卡")
		# 动画完成后，恢复用户输入
		# input_manager.allow_input()
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

func play_player_a_special_apply_anim() -> void:
	# 玩家A可以使用的特殊卡 和 玩家A手牌中可以升级的卡
	var upgradable_card = GameManager.instance.player_a.get_hand_upgradable_cards()
	for card in upgradable_card:
		# 这里可以添加动画效果
		print("玩家A可以升级的卡:", card.get_card_id())