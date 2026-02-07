extends Node

class_name Player

const MAX_HAND_CARD_NUM = 10

var card_manager = CardManager.get_instance()

var player_name: String = "Player"

var hand_cards = {
	0: PlayerHandCard.new(),
	1: PlayerHandCard.new(),
	2: PlayerHandCard.new(),
	3: PlayerHandCard.new(),
	4: PlayerHandCard.new(),
	5: PlayerHandCard.new(),
	6: PlayerHandCard.new(),
	7: PlayerHandCard.new(),
	8: PlayerHandCard.new(),
	9: PlayerHandCard.new(),
}

# map - card_id -> card
var deal_cards:Dictionary[int,Card] = {}

var player_score: int

var score_ui:Label = null

var finished_stories = []

var hand_cards_pos_array = []

var current_choosing_card_id:int = -1

var story_queue = []
var story_timer: Timer

var current_sc_story_show: Node = null

# 玩家选择的特殊卡ID列表
var selected_special_card_ids: Array[int] = []
var selected_special_cards: Array[Card] = []

# 被特殊卡替换的原始手牌，用于后续可能的恢复操作
var hidden_original_cards: Dictionary = {}

# ai agent
var bind_ai_agent: AIAgent = null
var ai_controlled: bool = false

signal player_choose_card(Player)
signal player_choose_change_card(Player)
signal player_state_changed(Player, PlayerState)

# 新完成的故事展示完毕
signal new_story_show_finished()
# 当前回合动作结算完成（动画和故事展示完成后）
signal action_resolution_completed(player: Player, action_cards: Array)

enum PlayerState{
	# 不在自己的回合中
	WAITING = 0,
	# 自己的回合中，未选择卡片
	SELF_ROUND_UNCHOOSING = 1,
	# 自己的回合中，已选择卡片
	SELF_ROUND_CHOOSING = 2,
	# 自己的回合中，选了手牌并选了公共区域的卡片
	SELF_ROUND_CHOOSING_FINISHED = 3,
	# 自己的回合中，手上没有和公共区域相同季节的卡片，需要换牌
	SELF_ROUND_CHANGE_CARD = 4,
}

var player_state

enum PlayerPos{
	A = 0,
	B = 1
}

func initialize(p_name, player_pos) -> void:
	player_name = p_name
	if player_pos == PlayerPos.A:
		# 初始化位置信息
		hand_cards_pos_array = card_manager.init_cards_position_tile(
										card_manager.PLAYER_A_CARD_AREA_SIZE,
										card_manager.PLAYER_A_CARD_AREA_POS,
										10)
	else:
		hand_cards_pos_array = card_manager.init_cards_position_tile(
										card_manager.PLAYER_B_CARD_AREA_SIZE,
										card_manager.PLAYER_B_CARD_AREA_POS,
										10)

	for i in range(10):
		hand_cards[i] = PlayerHandCard.new()
		hand_cards[i].pos = hand_cards_pos_array[i]
		hand_cards[i].zindex = 10 - i
		hand_cards[i].is_empty = true
	# 绑定分数变化信号
	ScoreManager.get_instance().score_changed.connect(Callable(self, "_on_score_changed"))

func _on_score_changed(player: Player, old_score: int, new_score: int, change: int, description: String) -> void:
	if player == self:
		player_score = new_score
		print("玩家 ", player_name, " 分数变化: ", old_score, " -> ", new_score, " 变化: ", change, " 描述: ", description)
		if score_ui:
			score_ui.text = "当前分数：" + str(new_score)

func assign_player_hand_card_to_slot(card: Card, slot_index: int) -> void:
	if slot_index < 0 or slot_index > 9:
		print("设置玩家手牌时，slot_index超出范围")
		return
	hand_cards[slot_index].card = card
	hand_cards[slot_index].slot_index = slot_index
	hand_cards[slot_index].is_empty = false
	# hand_cards[slot_index].card.position = hand_cards[slot_index].pos
	hand_cards[slot_index].card.z_index = hand_cards[slot_index].zindex
	hand_cards[slot_index].card.set_player_owner(self)

	card.connect("card_clicked", Callable(self, "on_card_clicked"))
	# AI玩家卡牌不可点击
	if self.is_ai_player():
		print("AI玩家：", player_name, slot_index,"张卡牌不可点击")
		hand_cards[slot_index].card.disable_click()
	else:
		hand_cards[slot_index].card.enable_click()

# 恢复卡牌为牌堆中的卡牌
func recover_hand_card_free(card: Card) -> void:
	# 移除身上的事件
	if card.is_connected("card_clicked", Callable(self, "on_card_clicked")):
		card.disconnect("card_clicked", Callable(self, "on_card_clicked"))
	# 其他TODO

func get_player_first_enpty_hand_card_index() -> int:
	for i in hand_cards.keys():
		if hand_cards[i].is_empty:
			return i
	return -1

func get_player_hand_card_by_id(card_id: int) -> Card:
	for i in hand_cards.keys():
		if not hand_cards[i].is_empty and hand_cards[i].card.ID == card_id:
			return hand_cards[i].card
	return null

func set_player_state(state: PlayerState, bemit_state: bool = false) -> void:
	player_state = state
	print("当前玩家 ", player_name, " 状态: ", player_state)
	# 发送信号
	if bemit_state:
		player_state_changed.emit(self, player_state)


func on_card_clicked(card: Node) -> void:
	if player_state == PlayerState.WAITING:
		return
	if player_state == PlayerState.SELF_ROUND_UNCHOOSING:
		card.set_card_chooesd()
		set_player_state(PlayerState.SELF_ROUND_CHOOSING)
		current_choosing_card_id = card.ID
		player_choose_card.emit(self)
		return
	elif player_state == PlayerState.SELF_ROUND_CHOOSING:
		if current_choosing_card_id == card.ID:
			card.set_card_unchooesd()
			set_player_state(PlayerState.SELF_ROUND_UNCHOOSING)
			current_choosing_card_id = -1
			player_choose_card.emit(self)
		else:
			set_all_hand_card_unchooesd()
			card.set_card_chooesd()
			current_choosing_card_id = card.ID
			player_choose_card.emit(self)
		return
	elif player_state == PlayerState.SELF_ROUND_CHANGE_CARD:
		current_choosing_card_id = card.ID
		player_choose_change_card.emit(self)
	elif player_state == PlayerState.SELF_ROUND_CHOOSING_FINISHED:
		return

func set_all_hand_card_unchooesd() -> void:
	for i in hand_cards.keys():
		if not hand_cards[i].is_empty:
			hand_cards[i].card.set_card_unchooesd()

func set_all_hand_card_cannot_click() -> void:
	for i in hand_cards.keys():
		if not hand_cards[i].is_empty:
			hand_cards[i].card.disable_click()

func set_all_hand_card_can_click() -> void:
	for i in hand_cards.keys():
		if not hand_cards[i].is_empty:
			hand_cards[i].card.enable_click()

func set_score_ui(ui: Node) -> void:
	score_ui = ui

func remove_hand_card(card:Card) -> void:
	for i in hand_cards.keys():
		if not hand_cards[i].is_empty and hand_cards[i].card.ID == card.ID:
			hand_cards[i].is_empty = true
			hand_cards[i].card = null
			break

# 检查当前手牌是不是已经没有和公共牌库相同的季节了
# 如果没有了 需要进入换牌状态 SELF_ROUND_CHANGE_CARD
func check_hand_card_season() -> bool:
	var seasons = GameManager.instance.get_public_card_deal().get_choosable_seasons()
	print("当前公共区域可用季节： ", seasons)
	var has_season = false

	for i in hand_cards.keys():
		if not hand_cards[i].is_empty:
			var card = hand_cards[i].card
			print("玩家 ", player_name, " 手牌中的卡牌： ", card.Name, " 季节： ", card.Season)
			if seasons.find(card.Season) != -1:
				has_season = true
				break

	if not has_season:
		print("玩家 ", player_name, " 手牌中没有和公共区域相同季节的卡牌，需要换牌")
		# 创建sc并展示
		UIManager.get_instance().open_ui_to_top(("UI_PlayerChangeCard"))
		set_player_state(PlayerState.SELF_ROUND_CHANGE_CARD, true)
	else:
		UIManager.get_instance().destroy_ui("UI_PlayerChangeCard")

	return has_season

func send_card_to_deal(card: Card) -> void:
	deal_cards[card.ID] = card
	card.set_card_unchooesd()
	card.disable_click()

# 一个玩家的回合结束，检查故事完成情况
func check_finish_story() -> bool:
	var this_time_completed_stories = StoryManager.get_instance().check_story_finish_for_player(self)
	# 将故事添加到玩家的完成故事列表中
	if this_time_completed_stories.size() > 0:
		finished_stories.append_array(this_time_completed_stories)
	# 给对应玩家增加当前故事的分数
	ScoreManager.get_instance().add_story_score(self, this_time_completed_stories)
	show_new_finished_stories(this_time_completed_stories)
	return this_time_completed_stories.size() > 0
	
# 展示新完成的故事
func show_new_finished_stories(this_time_completed_stories: Array):
	story_queue = this_time_completed_stories.duplicate()
	_show_next_story()

# 展示下一个新完成的故事
func _show_next_story():
	if not story_queue.is_empty():
		var story = story_queue.pop_front()
		show_one_new_finished_story(story)
	else:
		print("玩家 ", player_name, " 所有新完成的故事展示完毕")
		new_story_show_finished.emit()

# 展示一个新完成的故事
func show_one_new_finished_story(story:Story):
	print("玩家 ", player_name, " 完成了故事 ", story.name)
	# 使用sc_story_show展示当前故事的卡牌
	
	current_sc_story_show = UIManager.get_instance().ensure_get_ui_instance("UI_StoryShow")
	current_sc_story_show.modulate.a = 0
	current_sc_story_show.visible = true
	current_sc_story_show.z_index = 999
	current_sc_story_show.clear_all_cards()
	# 将sc添加到最上层
	var tree = GameManager.instance.scene_tree
	var root = tree.get_root()
	root.add_child(current_sc_story_show)
	# 获取当前故事的所有id
	var card_ids = story.cards_id
	
	# 创建一个映射，用于记录原始卡牌ID到特殊卡牌ID的映射
	var card_id_to_special_id_map = {}
	
	# 检查玩家deal中的卡牌，找出特殊卡
	for deal_card_id in deal_cards:
		var deal_card = deal_cards[deal_card_id]
		if deal_card.Special and deal_card.BaseID in card_ids:
			# 如果是特殊卡，且它的BaseID在故事所需的卡牌列表中
			# 记录这个映射关系
			card_id_to_special_id_map[deal_card.BaseID] = deal_card.ID
			print("找到特殊卡: ", deal_card.Name, " ID: ", deal_card.ID, " BaseID: ", deal_card.BaseID)
	
	# 创建新的卡牌，添加到sc中
	for card_id in card_ids:
		var display_card_id = card_id
		# 检查是否有对应的特殊卡
		if card_id in card_id_to_special_id_map:
			# 如果有特殊卡，使用特殊卡的ID
			display_card_id = card_id_to_special_id_map[card_id]
			print("使用特殊卡ID: ", display_card_id, " 替代普通卡ID: ", card_id)
		
		var card = card_manager.create_one_card(display_card_id)
		card.z_index = 1000
		current_sc_story_show.add_card(card)
	
	# 设置故事名
	current_sc_story_show.set_story_name(story.name)
	current_sc_story_show.layout_children()
	AnimationManager.get_instance().start_linear_alpha(current_sc_story_show, 1, 0.5, AnimationManager.EaseType.LINEAR, Callable(self, "show_one_new_finished_story_anim_in_end"))
	# 播放故事对应的音频
	var audio_id = story.audio_id
	AudioManager.get_instance().play_story_sfx(audio_id)

func show_one_new_finished_story_anim_in_end():
	# 1秒后开始消失动画
	await GameManager.instance.scene_tree.create_timer(1).timeout
	AnimationManager.get_instance().start_linear_alpha(current_sc_story_show, 0, 0.5, AnimationManager.EaseType.LINEAR, Callable(self, "show_one_new_finished_story_anim_out_end"))
	
func show_one_new_finished_story_anim_out_end():
	# 销毁current_sc_story_show
	var tree = GameManager.instance.scene_tree
	var root = tree.get_root()
	root.remove_child(current_sc_story_show)
	UIManager.get_instance().destroy_ui("UI_StoryShow")
	# 故事展示完毕，继续展示下一个故事
	_show_next_story()

func update_self_card_z_index() -> void:
	# 从slot_index 0开始 move_to_top 并且设置z_index为最大 然后递减
	for i in hand_cards.keys():
		if not hand_cards[i].is_empty:
			hand_cards[i].card.z_index = 10 - i
			
	# 倒序遍历
	for i in range(MAX_HAND_CARD_NUM-1, -1, -1):
		if not hand_cards[i].is_empty:
			hand_cards[i].card.move_to_top()
		
func get_current_choosing_card() -> Card:
	for i in hand_cards.keys():
		if not hand_cards[i].is_empty and hand_cards[i].card.ID == current_choosing_card_id:
			return hand_cards[i].card
	return null

func get_current_choosing_player_hand_card() -> PlayerHandCard:
	for i in hand_cards.keys():
		if not hand_cards[i].is_empty and hand_cards[i].card.ID == current_choosing_card_id:
			return hand_cards[i]
	return null

# 当前玩家是否还有手牌
func has_hand_card() -> bool:
	for i in hand_cards.keys():
		if not hand_cards[i].is_empty:
			return true
	return false

# 获取当前玩家的手牌下标
func get_available_hand_cards() -> Array:
	var card_indexes = []
	for i in hand_cards.keys():
		if not hand_cards[i].is_empty:
			card_indexes.append(i)
		
	return card_indexes

func get_all_hand_cards() -> Array[Card]:
	var result: Array[Card] = []
	for i in hand_cards.keys():
		if not hand_cards[i].is_empty and hand_cards[i].card != null:
			result.append(hand_cards[i].card)
	return result

func is_card_in_hand(card: Card) -> bool:
	for i in hand_cards.keys():
		if not hand_cards[i].is_empty and hand_cards[i].card == card:
			return true
	return false

func get_hand_slot_index(card: Card) -> int:
	for i in hand_cards.keys():
		if not hand_cards[i].is_empty and hand_cards[i].card == card:
			return i
	return -1

func get_first_hand_card() -> Card:
	for i in hand_cards.keys():
		if not hand_cards[i].is_empty and hand_cards[i].card != null:
			return hand_cards[i].card
	return null

func _disconnect_card_clicked_from_all_players(card: Card) -> void:
	if GameManager.instance == null:
		return
	for player in [GameManager.instance.player_a, GameManager.instance.player_b]:
		if player != null and card.is_connected("card_clicked", Callable(player, "on_card_clicked")):
			card.disconnect("card_clicked", Callable(player, "on_card_clicked"))

func _attach_card_to_slot(slot_index: int, card: Card) -> void:
	hand_cards[slot_index].card = card
	hand_cards[slot_index].slot_index = slot_index
	hand_cards[slot_index].is_empty = false
	_disconnect_card_clicked_from_all_players(card)
	if not card.is_connected("card_clicked", Callable(self, "on_card_clicked")):
		card.connect("card_clicked", Callable(self, "on_card_clicked"))
	card.set_player_owner(self)
	if is_ai_player():
		card.disable_click()
	else:
		card.enable_click()

func swap_one_hand_card_with_player(other_player: Player, self_card: Card, other_card: Card) -> Card:
	var self_slot = get_hand_slot_index(self_card)
	var other_slot = other_player.get_hand_slot_index(other_card)
	if self_slot == -1 or other_slot == -1:
		return null

	hand_cards[self_slot].card = null
	hand_cards[self_slot].is_empty = true
	other_player.hand_cards[other_slot].card = null
	other_player.hand_cards[other_slot].is_empty = true

	_attach_card_to_slot(self_slot, other_card)
	other_player._attach_card_to_slot(other_slot, self_card)
	update_self_card_z_index()
	other_player.update_self_card_z_index()
	return other_card

# 获取玩家分数
func get_score() -> int:
	return player_score

func clear():
	if score_ui:
		score_ui.text = "当前分数：0"
	player_score = 0


func set_ai_controlled(value: bool) -> void:
	ai_controlled = value

func bind_ai_enable() -> void:
	ai_controlled = true
	bind_ai_agent = AIAgent.new()
	bind_ai_agent.bind_player(self)

func is_ai_player() -> bool:
	return ai_controlled or bind_ai_agent != null

func start_ai_round() -> void:
	if bind_ai_agent:
		bind_ai_agent.start_ai_turn()
	
## 设置玩家选择的特殊卡ID
## 参数：
## - card_ids: 特殊卡ID列表
func set_selected_special_cards(card_ids: Array[int]) -> void:
	selected_special_card_ids = card_ids
	print("玩家 ", player_name, " 选择了 ", selected_special_card_ids.size(), " 张特殊卡")

## 获取玩家选择的特殊卡
## 返回：特殊卡ID列表的副本
func get_selected_special_cards() -> Array[int]:
	return selected_special_card_ids.duplicate()

## 检查玩家手牌中是否有与选中的特殊卡BaseID匹配的卡牌
func check_special_cards() -> bool:
	if selected_special_card_ids.size() == 0:
		print("玩家 ", player_name, " 未选择特殊卡")
		return false
	return true

## 设置玩家选择的特殊卡对象实例
## 参数：
## - cards: 特殊卡对象实例列表
func set_selected_special_cards_instance(cards: Array[Card]) -> void:
	selected_special_cards = cards
	print("玩家 ", player_name, " 拥有 ", selected_special_cards.size(), " 张特殊卡实例")
	play_base_card_upgrade_anim()

func play_base_card_upgrade_anim() -> void:
	var card_special_card_map = get_card_special_card_map()
	if card_special_card_map.size() == 0:
		print("玩家 ", player_name, " 没有可升级的卡牌")
		return
	# 所有可以升级的手牌和可以使用的特殊卡，一起位移
	# 如果是PlayerA，向上位移，否则向下位移
	var animation_manager = AnimationManager.get_instance()
	var vertical_offset = 100  # 垂直位移像素
	var anim_duration = 0.5  # 动画持续时间
	var waiting_time = anim_duration + 0.3  # 动画后等待时间
	
	# 判断玩家位置类型，决定位移方向
	var offset_direction = 1 if player_name == "PlayerA" else -1
	
	# 创建一个数据结构来保存卡牌和原始位置
	var animation_cards = []
	
	# 收集所有需要动画处理的卡牌
	for base_card in card_special_card_map.keys():
		var special_card = card_special_card_map[base_card]
		
		# 确保卡牌是有效的
		if is_instance_valid(base_card) and is_instance_valid(special_card):
			# 记录基础卡的z_index用于后续参考
			var base_z_index = base_card.z_index if "z_index" in base_card else 0
			
			animation_cards.append({
				"base_card": base_card,
				"special_card": special_card,
				"base_original_pos": base_card.position,
				"special_original_pos": special_card.position,
				"base_target_pos": Vector2(base_card.position.x, base_card.position.y + vertical_offset * offset_direction),
				"special_target_pos": Vector2(special_card.position.x, special_card.position.y + vertical_offset * offset_direction),
				"base_z_index": base_z_index
			})
	
	# 执行向目标位置的动画
	for card_data in animation_cards:
		var base_card = card_data["base_card"]
		var special_card = card_data["special_card"]
		
		# 再次检查卡牌是否有效，以防在上次循环后被销毁
		if not is_instance_valid(base_card) or not is_instance_valid(special_card):
			continue
			
		# 确保卡牌有必要的属性
		if not "position" in base_card or not "position" in special_card or not "modulate" in base_card or not "modulate" in special_card:
			continue
		
		# 位移动画
		animation_manager.start_linear_movement_pos(base_card, card_data["base_target_pos"], anim_duration, AnimationManager.EaseType.EASE_IN_OUT)
		animation_manager.start_linear_movement_pos(special_card, card_data["special_target_pos"], anim_duration, AnimationManager.EaseType.EASE_IN_OUT)
		
		# 高亮动画 - 使用分离的透明度控制
		if base_card.modulate != null:
			animation_manager.start_linear_alpha(base_card, 1.2, anim_duration/2, AnimationManager.EaseType.EASE_IN_OUT)
		
		if special_card.modulate != null:
			animation_manager.start_linear_alpha(special_card, 1.2, anim_duration/2, AnimationManager.EaseType.EASE_IN_OUT)
	
	# 等待动画完成
	await GameManager.instance.scene_tree.create_timer(waiting_time).timeout
	
	# 恢复透明度，但保持位移状态
	for card_data in animation_cards:
		# 再次检查卡牌是否有效
		if is_instance_valid(card_data["base_card"]) and is_instance_valid(card_data["special_card"]):
			# 检查卡牌是否有modulate属性
			if "modulate" in card_data["base_card"] and card_data["base_card"].modulate != null:
				animation_manager.start_linear_alpha(card_data["base_card"], 1.0, anim_duration/2, AnimationManager.EaseType.EASE_IN_OUT)
				
			if "modulate" in card_data["special_card"] and card_data["special_card"].modulate != null:
				animation_manager.start_linear_alpha(card_data["special_card"], 1.0, anim_duration/2, AnimationManager.EaseType.EASE_IN_OUT)
	
	# 等待透明度动画完成
	await GameManager.instance.scene_tree.create_timer(anim_duration/2).timeout
	
	# 将特殊卡牌移动到对应的基础卡的位置
	print("玩家 ", player_name, " 开始将特殊卡移动到基础卡位置")
	
	# 对每对卡牌，将特殊卡移动到基础卡位置
	for card_data in animation_cards:
		# 再次检查卡牌是否有效
		if is_instance_valid(card_data["base_card"]) and is_instance_valid(card_data["special_card"]):
			# 确保特殊卡的z_index大于基础卡，这样移动到相同位置后能覆盖在上面
			if "z_index" in card_data["base_card"] and "z_index" in card_data["special_card"]:
				# 将特殊卡的z_index设置为基础卡的z_index
				card_data["special_card"].z_index = card_data["base_card"].z_index
				print("调整特殊卡 z_index: ", card_data["special_card"].z_index, ", 基础卡 z_index: ", card_data["base_card"].z_index)
			
			# 特殊卡移动到基础卡的当前位置（即升起后的位置）
			if "position" in card_data["base_card"] and "position" in card_data["special_card"]:
				var target_pos = card_data["base_card"].position
				animation_manager.start_linear_movement_pos(card_data["special_card"], target_pos, anim_duration, AnimationManager.EaseType.EASE_IN_OUT)
	
	# 等待特殊卡移动到基础卡位置的动画完成
	await GameManager.instance.scene_tree.create_timer(anim_duration).timeout
	
	# 确保所有卡牌的透明度恢复正常
	for card_data in animation_cards:
		if is_instance_valid(card_data["base_card"]):
			if "modulate" in card_data["base_card"] and card_data["base_card"].modulate != null:
				var final_modulate = card_data["base_card"].modulate
				final_modulate.a = 1.0
				card_data["base_card"].modulate = final_modulate
				
		if is_instance_valid(card_data["special_card"]):
			if "modulate" in card_data["special_card"] and card_data["special_card"].modulate != null:
				var final_modulate = card_data["special_card"].modulate
				final_modulate.a = 1.0
				card_data["special_card"].modulate = final_modulate
			
			# 确保特殊卡最终位置与基础卡完全一致
			if "position" in card_data["base_card"] and "position" in card_data["special_card"] and is_instance_valid(card_data["base_card"]):
				card_data["special_card"].position = card_data["base_card"].position
	
	print("玩家 ", player_name, " 完成卡牌升级动画，特殊卡已移动到基础卡位置")
	
	# 危险操作：替换手牌中的卡牌为特殊卡
	print("玩家 ", player_name, " 开始替换手牌中的卡牌为特殊卡")
	replace_hand_cards_with_special_cards(animation_cards)
	
	# 替换完成后，将新手牌移回原始位置
	await return_cards_to_original_positions()

# 将所有手牌移回到它们原始的位置
func return_cards_to_original_positions() -> void:
	print("玩家 ", player_name, " 开始将手牌移回原始位置")
	var animation_manager = AnimationManager.get_instance()
	var anim_duration = 0.5  # 动画持续时间
	
	# 记录需要移动的卡牌，避免在执行动画时修改hand_cards
	var cards_to_move = []
	
	# 收集所有需要移动的卡牌信息
	for slot_index in hand_cards.keys():
		if not hand_cards[slot_index].is_empty and hand_cards[slot_index].card != null:
			if is_instance_valid(hand_cards[slot_index].card):
				cards_to_move.append({
					"card": hand_cards[slot_index].card,
					"target_pos": hand_cards[slot_index].pos
				})
	
	# 执行位移动画
	for card_data in cards_to_move:
		var card = card_data["card"]
		var target_pos = card_data["target_pos"]
		
		if is_instance_valid(card) and "position" in card:
			animation_manager.start_linear_movement_pos(card, target_pos, anim_duration, AnimationManager.EaseType.EASE_IN_OUT)
	
	# 等待所有卡牌移回原位的动画完成
	await GameManager.instance.scene_tree.create_timer(anim_duration).timeout
	
	# 为所有替换的卡牌设置玩家所有者并启用点击
	for slot_index in hand_cards.keys():
		if not hand_cards[slot_index].is_empty and hand_cards[slot_index].card != null:
			var card = hand_cards[slot_index].card
			if is_instance_valid(card):
				# 设置卡牌的玩家所有者
				if "player_owner" in card:
					card.set_player_owner(self)
				
				# 设置卡牌为可点击（非AI玩家）
				if not self.is_ai_player() and "is_enable_click" in card:
					card.enable_click()
				
	print("玩家 ", player_name, " 手牌已移回原始位置并完成属性设置")
	return

# 替换手牌中的卡牌为特殊卡，并将原始卡牌隐藏保存
# 添加协程标记，以便可以使用await等待函数完成
func replace_hand_cards_with_special_cards(animation_cards: Array) -> void:
	# 清空之前可能存在的隐藏卡牌
	hidden_original_cards.clear()
	
	# 记录已使用的特殊卡，用于之后从选择列表中移除
	var used_special_cards = []
	var used_special_card_ids = []
	
	# 遍历所有需要替换的卡牌对
	for card_data in animation_cards:
		var base_card = card_data["base_card"]
		var special_card = card_data["special_card"]
		
		# 确保两张卡牌都有效
		if not is_instance_valid(base_card) or not is_instance_valid(special_card):
			print("警告: 基础卡或特殊卡无效，跳过替换")
			continue
			
		# 查找基础卡在哪个槽位
		var slot_found = false
		var slot_index = -1
		
		for i in hand_cards.keys():
			if not hand_cards[i].is_empty and hand_cards[i].card == base_card:
				slot_index = i
				slot_found = true
				break
				
		if not slot_found:
			print("警告: 未找到基础卡对应的槽位，跳过替换")
			continue
			
		# 保存原始卡牌到隐藏字典中
		var original_card = hand_cards[slot_index].card
		if original_card:
			# 使用卡牌ID作为键，避免直接使用对象引用
			hidden_original_cards[original_card.ID] = original_card
			
			# 从原来的位置移除但不销毁
			original_card.position = Vector2(-1000, -1000)  # 移到屏幕外
			original_card.visible = false
			
			# 转移事件连接
			if original_card.is_connected("card_clicked", Callable(self, "on_card_clicked")):
				original_card.disconnect("card_clicked", Callable(self, "on_card_clicked"))
			
			if not special_card.is_connected("card_clicked", Callable(self, "on_card_clicked")):
				special_card.connect("card_clicked", Callable(self, "on_card_clicked"))
			
			# 替换槽位中的卡牌
			hand_cards[slot_index].card = special_card
			
			# 这里先不设置点击状态，等卡牌移回原位后统一设置
			# 但可以预先设置player_owner，确保卡牌知道它属于哪个玩家
			if "player_owner" in special_card:
				special_card.set_player_owner(self)
			
			# 记录已使用的特殊卡，以便之后从选择列表中移除
			if "ID" in special_card:
				used_special_card_ids.append(special_card.ID)
				used_special_cards.append(special_card)
			
			print("成功替换槽位 ", slot_index, " 中的基础卡为特殊卡")
	
	# 从选择的特殊卡列表中移除已使用的卡牌
	for special_card in used_special_cards:
		var index = selected_special_cards.find(special_card)
		if index != -1:
			selected_special_cards.remove_at(index)
			print("从selected_special_cards中移除已使用的特殊卡: ", special_card.Name)
	
	for special_card_id in used_special_card_ids:
		var index = selected_special_card_ids.find(special_card_id)
		if index != -1:
			selected_special_card_ids.remove_at(index)
			print("从selected_special_card_ids中移除已使用的特殊卡ID: ", special_card_id)
	
	update_self_card_z_index()

	print("玩家 ", player_name, " 完成手牌替换，替换了 ", hidden_original_cards.size(), " 张卡牌，剩余特殊卡 ", selected_special_cards.size(), " 张")

## 获取玩家手牌与特殊卡的匹配映射
## 返回：字典，key为普通卡实例，value为对应的特殊卡实例
func get_card_special_card_map() -> Dictionary:	
	var card_special_card_map: Dictionary = {}
	print("玩家 ", player_name, " 的手牌数量: ", hand_cards.size(), ", 特殊卡数量: ", selected_special_cards.size())
	
	# 遍历所有手牌槽位
	for slot_index in hand_cards.keys():
		var hand_card:PlayerHandCard = hand_cards[slot_index]
		
		# 检查槽位是否有卡牌
		if hand_card.is_empty or hand_card.card == null:
			print("玩家 ", player_name, " 的槽位 ", slot_index, " 为空或没有卡牌")
			continue

		var base_card = hand_card.card
		
		# 确保基本卡有效且有ID属性
		if not is_instance_valid(base_card) or not "ID" in base_card:
			print("玩家 ", player_name, " 的手牌在槽位 ", slot_index, " 不是有效的卡牌")
			continue
			
		var base_card_id = base_card.ID
		
		for special_card in selected_special_cards:
			# 确保特殊卡有效且有BaseID属性
			if not is_instance_valid(special_card) or not "BaseID" in special_card:
				print("玩家 ", player_name, " 的特殊卡无效或缺少BaseID")
				continue
				
			if special_card.BaseID == base_card_id:
				print("玩家 ", player_name, " 的手牌 ", base_card.Name, " 与特殊卡 ", special_card.Name, " BaseID匹配")
				
				# 确认卡牌必须是节点对象，才能作为字典的键
				if base_card is Node and special_card is Node:
					card_special_card_map[base_card] = special_card
				else:
					print("警告: 卡牌不是Node类型，无法作为字典键使用")
	
	if card_special_card_map.size() > 0:
		print("玩家 ", player_name, " 共有 ", card_special_card_map.size(), " 张可升级的卡牌")
	else:
		print("玩家 ", player_name, " 没有可升级的卡牌")
		
	return card_special_card_map
		
# 检查当前卡牌是否可以升级
func check_card_can_upgrade(card:Card) -> Card:
	
	if card.Special:
		print(card.Name, " 已经是特殊卡，无法升级")
		return null
	
	for i in range(selected_special_cards.size() - 1, -1, -1):
		var special_card = selected_special_cards[i]
		if special_card.BaseID == card.BaseID:
			# 玩家当前手中的特殊卡包含这张被选中的公共卡牌的BaseID
			# 从数组中移除特殊卡
			selected_special_cards.remove_at(i)
			print("从selected_special_cards中移除已使用的特殊卡: ", special_card.Name)
			
			# 同时从ID列表中移除
			var id_index = selected_special_card_ids.find(special_card.ID)
			if id_index != -1:
				selected_special_card_ids.remove_at(id_index)
				print("从selected_special_card_ids中移除已使用的特殊卡ID: ", special_card.ID)
			
			# 将玩家手中的特殊卡返回
			return special_card

	return null

## 获取当前选择的手牌
## 返回：当前选择的手牌对象
func get_choosing_hand_card() -> Card:
	return get_current_choosing_card()

## 传入一个卡牌ID，检查当前玩家的牌堆中是否有这个卡牌的特殊牌
## 有的话返回这个特殊牌ID
func check_special_card_in_deal(card_id: int) -> int:
	for card in deal_cards.values():
		if card.BaseID == card_id and card.Special:
			return card.ID
	return -1

## 检查玩家牌堆中是否有这个卡牌
func chenk_card_in_deal(card_id: int) -> bool:
	for card in deal_cards.values():
		if card.ID == card_id or card.BaseID == card_id:
			return true
	return false

## 检查玩家已完成的故事中是否有这个故事
func check_story_in_finished_stories(story_id: int) -> bool:
	for story in finished_stories:
		if story.id == story_id:
			return true
	return false

## 处理玩家选择公共卡牌的事件
func handle_card_selection(player_choosing_card: Card, public_choosing_card: Card, game_instance: GameInstance):
	var input_manager = InputManager.get_instance()
	
	input_manager.block_input()
	
	var target_pos = _get_deal_position()
	var acquired_public_card: Card = public_choosing_card
	
	print("玩家 ", player_name, " 选择了手牌 ", player_choosing_card.ID, player_choosing_card.Name, " 和公共区域的牌 ", public_choosing_card.ID, public_choosing_card.Name)
	
	var anim_duration = 1
	
	# 准备卡牌动画
	_prepare_card_for_animation(player_choosing_card)
	
	# 检查升级逻辑
	var special_card = check_card_can_upgrade(public_choosing_card)
	if special_card:
		acquired_public_card = await _play_upgrade_animation(special_card, public_choosing_card)

	await _execute_card_animations(player_choosing_card, acquired_public_card, target_pos, anim_duration, game_instance)
	_update_player_data(player_choosing_card, acquired_public_card)
	await _wait_for_animation_complete(anim_duration)
	var has_new_story = check_finish_story()
	if has_new_story:
		await new_story_show_finished
	InputManager.get_instance().allow_input()
	action_resolution_completed.emit(self, [player_choosing_card, acquired_public_card])

## 获取当前玩家的发牌位置
func _get_deal_position() -> Vector2:
	if player_name == "PlayerA":
		return card_manager.PLAYER_A_DEAL_CARD_POS
	else:
		return card_manager.PLAYER_B_DEAL_CARD_POS

## 准备卡牌用于动画
func _prepare_card_for_animation(card: Card):
	card.disable_click()
	card.set_card_unchooesd()
	card.set_card_pivot_offset_to_center()

## 执行卡牌动画
func _execute_card_animations(player_choosing_card: Card, public_choosing_card: Card, target_pos: Vector2, anim_duration: float, game_instance: GameInstance):
	var animation_manager = AnimationManager.get_instance()
	
	animation_manager.start_linear_movement_combined(
		player_choosing_card, 
		target_pos, 
		card_manager.get_random_deal_card_rotation(), 
		anim_duration, 
		animation_manager.EaseType.EASE_IN_OUT, 
		Callable(game_instance, "card_animation_end"), [player_choosing_card, true])

	public_choosing_card.set_card_pivot_offset_to_center()

	animation_manager.start_linear_movement_combined(
		public_choosing_card, 
		target_pos, 
		card_manager.get_random_deal_card_rotation(), 
		anim_duration, 
		animation_manager.EaseType.EASE_IN_OUT, 
		Callable(game_instance, "card_animation_end"), [public_choosing_card, true])

## 更新玩家数据
func _update_player_data(player_choosing_card: Card, public_choosing_card: Card):
	# 更新玩家分数
	ScoreManager.get_instance().add_base_card_score(self, player_choosing_card)
	ScoreManager.get_instance().add_base_card_score(self, public_choosing_card)
	
	send_card_to_deal(player_choosing_card)
	send_card_to_deal(public_choosing_card)
	
	remove_hand_card(player_choosing_card)

## 等待动画完成
func _wait_for_animation_complete(anim_duration: float):
	var temp_timer = GameManager.create_timer(anim_duration + 0.1, func(): pass)
	await temp_timer.timeout

## 播放卡牌升级动画
func _play_upgrade_animation(special_card: Card, public_choosing_card: Card) -> Card:
	print("玩家选择的公共卡可以升级为特殊卡: ", special_card.Name)
	
	var animation_manager = AnimationManager.get_instance()
	
	# 保存特殊卡的原始z_index，用于动画结束后恢复
	var original_zindex = special_card.z_index
	
	# 临时提高z_index确保特殊卡显示在最上层
	special_card.z_index = 1000
	
	# 禁用输入，确保动画期间无法点击
	special_card.disable_click()
	public_choosing_card.disable_click()
	
	# 设置卡片中心点用于旋转动画
	special_card.set_card_pivot_offset_to_center()
	public_choosing_card.set_card_pivot_offset_to_center()
			
	# 启动移动动画，将特殊卡移动到公共卡位置
	animation_manager.start_linear_movement_combined(
		special_card, 
		public_choosing_card.position, 
		public_choosing_card.rotation, 
		0.8, 
		animation_manager.EaseType.EASE_IN_OUT, 
		Callable(self, "_on_special_card_upgrade_complete"), 
		[special_card, public_choosing_card, original_zindex]
	)
	
	# 使用await暂停函数执行，直到所有动画完成
	await GameManager.create_timer(1.0, func(): pass).timeout
	public_choosing_card.visible = false
	public_choosing_card.disable_click()
	return special_card

## 特殊卡升级动画完成回调（从GameInstance移植）
func _on_special_card_upgrade_complete(special_card: Card, _public_choosing_card: Card, original_zindex: int):
	# 恢复特殊卡的原始z_index
	special_card.z_index = original_zindex

func on_special_card_upgrade_complete(special_card: Card, original_zindex: int):
	_on_special_card_upgrade_complete(special_card, null, original_zindex)


