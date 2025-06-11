extends Node

class_name AIAgent

var ai_level: int = AILevel.SIMPLE

var current_player: Player = null

enum AILevel{
	# 简单AI
	SIMPLE = 1,
	# 中等AI
	MEDIUM = 2,
	# 困难AI
	HARD = 3,
}

func set_level(level: int) -> void:
	ai_level = level

func bind_player(player: Player) -> void:
	current_player = player
	current_player.connect("player_state_changed", Callable(self, "on_player_state_changed"))

func common_operation() -> bool:
	if current_player.has_hand_card():
		return current_player.check_hand_card_season()

	return false
	
func start_ai_turn() -> void:
	if current_player == null:
		push_error("AIAgent: Player not binded.")
		return
	
	# 通用操作
	var enter_next = common_operation()
	if not enter_next:
		push_warning("AIAgent: Player has no valid card to choose.")
		return
	
	# 根据AI等级选择AI操作进入选卡逻辑
	match ai_level:
		AILevel.SIMPLE:
			select_simple_ai()
		AILevel.MEDIUM:
			select_medium_ai()
		AILevel.HARD:
			select_hard_ai()


func on_player_state_changed(player: Player, state: Player.PlayerState) -> void:
	if state == Player.PlayerState.SELF_ROUND_CHANGE_CARD:
		enter_change_card_state(player)
	elif state == Player.PlayerState.SELF_ROUND_UNCHOOSING:
		start_ai_turn()


func enter_change_card_state(player: Player) -> void:
	if self.current_player != player:
		push_error("AIAgent: Player not binded.")
		return
	
	# 检查玩家回合状态
	if current_player.player_state!= Player.PlayerState.SELF_ROUND_CHANGE_CARD:
		push_error("AIAgent: Player state error.", current_player.player_state)
		return
	
	# 玩家选择了手牌, 等待一段时间, 然后选择公共区域的牌
	await GameManager.instance.scene_tree.create_timer(1).timeout

	# 进入选卡状态：随机从手牌中选一张卡
	var available_card_indexes = current_player.get_available_hand_cards()
	var card_num = available_card_indexes.size()
	var random_index = randi() % card_num
	# 选择这张卡牌
	var hand_card = current_player.hand_cards[available_card_indexes[random_index]].card
	hand_card.print_card_info()
	# 设置卡牌为选中状态
	hand_card.change_card_chooesd()
	# 发送选中信号
	hand_card.card_clicked.emit(hand_card)

############################################################################################################
# 简单AI: 
# 从手牌堆从前往后顺序选择一张手牌，判断当前卡牌是否和公共牌堆有相同季节的卡牌，如果有则选择这张卡牌。
func select_simple_ai() -> void:
	if not current_player.has_hand_card():
		push_error("AIAgent: Player has no hand card.")
		return

	var enter_next = enter_simple_choose_hand_card_state()
	if not enter_next:
		push_error("AIAgent: Player has no hand card to choose.")
		return

	# 玩家选择了手牌, 等待一段时间, 然后选择公共区域的牌
	await GameManager.instance.scene_tree.create_timer(1).timeout

	enter_next = enter_simple_choose_public_card_state()
	if not enter_next:
		push_error("AIAgent: Player has no public card to choose.")
		return

# 选择手牌
func enter_simple_choose_hand_card_state() -> bool:
	print("AIAgent: enter_simple_choose_hand_card_state")
	# 检查玩家回合状态
	if current_player.player_state != Player.PlayerState.SELF_ROUND_UNCHOOSING:
		push_error("AIAgent: Player state error.", current_player.player_state)	
		return false

	# 从前往后顺序选择一张手牌
	for i in current_player.hand_cards.keys():
		var card_info = current_player.hand_cards[i]
		if card_info.is_empty:
			push_warning("AIAgent: Hand card is empty. card index=", i)
			continue

		var hand_card = card_info.card
		var public_deal = GameManager.instance.get_public_card_deal()
		var seasons = public_deal.get_choosable_seasons()
		if hand_card.Season in seasons:
			# 选择这张卡牌
			hand_card.print_card_info()
			# 设置卡牌为选中状态
			hand_card.change_card_chooesd()
			# 发送选中信号
			hand_card.card_clicked.emit(hand_card)

			return true

	return false

# 选择公共区域的牌
func enter_simple_choose_public_card_state() -> bool:
	# 选择公共区域的牌
	if current_player.player_state != Player.PlayerState.SELF_ROUND_CHOOSING:
		push_error("AIAgent: Player state error.", current_player.player_state)

	var player_current_choosing_card = current_player.get_player_hand_card_by_id(current_player.current_choosing_card_id)
	# 从前往后顺序选择一张公共区域的牌
	var public_card_deal = GameManager.instance.get_public_card_deal()
	for i in public_card_deal.hand_cards.keys():
		var card_info = public_card_deal.hand_cards[i]
		if not card_info.isEmpty:
			var public_card = card_info.card
			if player_current_choosing_card.Season == public_card.Season:
				# 选择这张卡牌
				public_card.print_card_info()
				# 设置卡牌为选中状态
				public_card.change_card_chooesd()
				# 发送选中信号
				public_card.card_clicked.emit(public_card)

				return true

	return false
############################################################################################################


func select_medium_ai() -> void:
	#TODO 中等难度AI
	pass


func select_hard_ai() -> void:
	#TODO 困难AI
	pass
