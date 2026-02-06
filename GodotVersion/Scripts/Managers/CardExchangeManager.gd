extends Node

class_name CardExchangeManager

static var instance: CardExchangeManager

signal exchange_completed(success: bool)

var game_instance: GameInstance
var card_manager: CardManager
var public_deal: PublicCardDeal

static func get_instance() -> CardExchangeManager:
	if instance == null:
		instance = CardExchangeManager.new()
	return instance

func initialize(game_inst: GameInstance):
	game_instance = game_inst
	card_manager = CardManager.get_instance()
	public_deal = game_inst.get_public_card_deal()

# 处理换牌逻辑的主函数
func handle_card_exchange(current_player: Player):
	# 检查牌库中是否还有匹配季节的卡牌
	var public_seasons = public_deal.get_choosable_seasons()
	var storage_seasons = card_manager.get_storage_seasons()
	var has_matching_season = false

	for season in storage_seasons:
		if public_seasons.find(season) != -1:
			has_matching_season = true
			break

	if not has_matching_season:
		print("牌库中没有匹配季节的卡牌，游戏结束")
		exchange_completed.emit(false)
		return

	# AI玩家自动选择换牌
	if current_player.is_ai_player():
		_handle_ai_exchange(current_player)
	else:
		_handle_human_exchange(current_player)

# 处理AI玩家换牌
func _handle_ai_exchange(current_player: Player):
	print("AI玩家自动换牌")
	var hand_cards = current_player.get_all_hand_cards()
	if hand_cards.size() > 0:
		var random_card = hand_cards[randi() % hand_cards.size()]
		current_player.current_choosing_card_id = random_card.ID

		# 执行换牌逻辑
		card_manager.on_player_choose_change_card(current_player)

		# 等待换牌动画完成后重新检查
		await get_tree().create_timer(1.0).timeout

		# 换牌完成后重新检查手牌季节
		if current_player.check_hand_card_season():
			current_player.set_player_state(Player.PlayerState.SELF_ROUND_UNCHOOSING)
			exchange_completed.emit(true)
		else:
			handle_card_exchange(current_player)

# 处理人类玩家换牌
func _handle_human_exchange(current_player: Player):
	print("等待玩家手动选择换牌")
	current_player.set_player_state(Player.PlayerState.SELF_ROUND_CHANGE_CARD)
	current_player.set_all_hand_card_can_click()

	var callback = Callable(self, "_on_human_selected_exchange_card")
	if not current_player.is_connected("player_choose_change_card", callback):
		current_player.connect("player_choose_change_card", callback, CONNECT_ONE_SHOT)

func _on_human_selected_exchange_card(player: Player):
	# CardManager 已经在 player_choose_change_card 信号上执行了换牌，这里仅做结果检查
	await get_tree().create_timer(1.0).timeout

	if player.check_hand_card_season():
		player.set_player_state(Player.PlayerState.SELF_ROUND_UNCHOOSING)
		exchange_completed.emit(true)
	else:
		print("换牌后仍需继续换牌")
		handle_card_exchange(player)

func clear():
	if game_instance:
		game_instance = null
	if card_manager:
		card_manager = null
	if public_deal:
		public_deal = null
