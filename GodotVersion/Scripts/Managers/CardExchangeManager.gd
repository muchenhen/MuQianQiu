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
		await get_tree().create_timer(1.5).timeout

		# 换牌完成后重新检查手牌季节
		if current_player.check_hand_card_season():
			# 换牌成功，继续游戏
			current_player.set_player_state(Player.PlayerState.SELF_ROUND_UNCHOOSING)
			exchange_completed.emit(true)
		else:
			# 仍然没有匹配卡牌，递归重新换牌
			handle_card_exchange(current_player)

# 处理人类玩家换牌
func _handle_human_exchange(current_player: Player):
	print("等待玩家手动选择换牌")
	current_player.set_player_state(Player.PlayerState.SELF_ROUND_CHANGE_CARD)

	# 连接换牌完成信号（使用一次性连接）
	if not current_player.is_connected("card_exchange_completed", _on_player_exchange_complete):
		current_player.connect("card_exchange_completed", _on_player_exchange_complete, CONNECT_ONE_SHOT)

# 处理玩家换牌完成信号的回调函数
func _on_player_exchange_complete():
	var current_player = game_instance.get_current_active_player()
	if current_player == null:
		return

	# 重新检查手牌季节
	if current_player.check_hand_card_season():
		# 换牌成功，继续游戏
		current_player.set_player_state(Player.PlayerState.SELF_ROUND_UNCHOOSING)
		exchange_completed.emit(true)
	else:
		# 仍然需要换牌，继续处理
		print("换牌后仍需继续换牌")
		handle_card_exchange(current_player)

func clear():
	if game_instance:
		game_instance = null
	if card_manager:
		card_manager = null
	if public_deal:
		public_deal = null