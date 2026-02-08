extends Node

# 公共卡池
class_name PublicCardDeal

var card_manager = CardManager.get_instance()
var animation_manager = AnimationManager.get_instance()

var player_a:Player = null
var player_b:Player = null
var player_current_choosing_card:Card = null
var current_player:Player = null

var skip_supply_anim:bool = false

var debug_player_change_card:bool = false


signal player_choose_public_card(player_choosing_card, public_choosing_card)
signal common_suply_public_card(type)

class PublicHandCardInfo:
	var card: Node
	var position: Vector2
	var rotation: float
	var isEmpty: bool

	func _init(p_card = null, p_position = Vector2(), p_rotation = 0, p_isEmpty = true):
		self.card = p_card
		self.position = p_position
		self.rotation = p_rotation
		self.isEmpty = p_isEmpty

var hand_cards = {}

const PUBLIC_HAND_MAX = 8

func initialize() -> void:
	# 初始化公共区域手牌的每一个位置
	pass

# tick
func set_all_card_one_season():
	for i in hand_cards.keys():
		var card_info = hand_cards[i]
		if not card_info.isEmpty:
			if debug_player_change_card:
				var new_card_info = TableManager.get_instance().get_row("Cards", 201)
				card_info.card.update_card_info(201, new_card_info)

func bind_players(p_a, p_b) -> void:
	player_a = p_a
	player_b = p_b
	player_a.connect("player_choose_card", Callable(self, "on_player_choose_card"))
	player_b.connect("player_choose_card", Callable(self, "on_player_choose_card"))

func set_one_hand_card(card, position, rotation) -> void:
	hand_cards[hand_cards.size() + 1] = PublicHandCardInfo.new(card, position, rotation, false)
	card.connect("card_clicked", Callable(self, "on_card_clicked"))

func on_card_clicked(card):
	print("Card clicked: ", card.Name, " ID: ", card.ID)
	# 如果此时有玩家已经选中了手牌
	if player_current_choosing_card != null:
		# 如果当前被点击的牌的Season和已选中的牌的Season不同，则不做任何操作
		if card.Season != player_current_choosing_card.Season:
			return
		# Season相同，则视为玩家要取走这张牌
		disable_all_hand_card_click()
		set_all_hand_card_unchooesd()
		set_aim_hand_card_empty(card)
		player_choose_public_card.emit(player_current_choosing_card, card)

func on_player_choose_card(player:Player):
	set_all_hand_card_unchooesd()
	current_player = player
	print("Player choose card: ", player.player_name)

	if player.current_choosing_card_id == -1:
		set_all_hand_card_unchooesd()
		disable_all_hand_card_click()
		return

	player_current_choosing_card = player.get_player_hand_card_by_id(player.current_choosing_card_id)
	var season = player_current_choosing_card.Season
	set_aim_season_hand_card_chooesd(season)
	disable_all_hand_card_click()

	# AI玩家，禁止点击
	if not player.is_ai_player():		
		enable_aim_season_hand_card_click(season)

func set_all_hand_card_unchooesd() -> void:
	for i in hand_cards.keys():
		var card_info = hand_cards[i]
		if not card_info.isEmpty:
			card_info.card.set_card_unchooesd()

func set_aim_season_hand_card_chooesd(season) -> void:
	for i in hand_cards.keys():
		var card_info = hand_cards[i]
		if not card_info.isEmpty:
			if card_info.card.Season == season:
				card_info.card.set_card_chooesd()

func disable_all_hand_card_click() -> void:
	for i in hand_cards.keys():
		var card_info = hand_cards[i]
		if card_info != null and not card_info.isEmpty and card_info.card != null:
			card_info.card.disable_click()

func enable_all_hand_card_click() -> void:
	for i in hand_cards.keys():
		var card_info = hand_cards[i]
		if card_info != null and not card_info.isEmpty and card_info.card != null:
			card_info.card.enable_click()

func get_hand_card_by_id(card_id) -> Node:
	for i in hand_cards.keys():
		var card_info = hand_cards[i]
		if not card_info.isEmpty:
			if card_info.card.ID == card_id:
				return card_info.card
	return null

func need_supply_hand_card() -> bool:
	# 检查是否有空位需要补充
	for i in hand_cards.keys():
		var card_info: PublicHandCardInfo = hand_cards[i]
		if card_info.isEmpty:
			return true
	return false

# 或者更详细的版本，返回需要补充的数量
func get_empty_hand_card_count() -> int:
	var empty_count = 0
	for i in hand_cards.keys():
		var card_info: PublicHandCardInfo = hand_cards[i]
		if card_info.isEmpty:
			empty_count += 1
	return empty_count

# 检查公共牌区域是否已满
func is_hand_cards_full() -> bool:
	return hand_cards.size() >= PUBLIC_HAND_MAX and not need_supply_hand_card()

func supply_hand_card():
	_supply_with_card(card_manager.pop_one_card())

func supply_specific_card(card: Card):
	_supply_with_card(card)

func _supply_with_card(card: Card):
	if card == null:
		common_suply_public_card.emit("supply_end")
		return

	for i in hand_cards.keys():
		var card_info: PublicHandCardInfo = hand_cards[i]
		if card_info.isEmpty:
			card.move_to_top()
			card.z_index = i
			card.set_input_priority(card.z_index)
			print("补充公共牌手牌: ", i, " ", card.ID)
			card_info.card = card
			card_info.isEmpty = false

			if skip_supply_anim:
				card_info.card.global_position = card_info.position
				card_info.card.position = card_info.position
				card_info.card.rotation = card_info.rotation
				card_info.card.disable_click()
				card.update_card()
				if not card.card_clicked.is_connected(Callable(self, "on_card_clicked")):
					card.card_clicked.connect(Callable(self, "on_card_clicked"))
				common_suply_public_card.emit("supply_end")
			else:
				# 播放动画
				var taget_pos = card_info.position
				var target_rotation = card_info.rotation
				animation_manager.start_linear_movement_combined(card, taget_pos, target_rotation, 1, animation_manager.EaseType.EASE_IN_OUT, Callable(self, "supply_hand_card_anim_end"), [card])
			return

	# 没有空位，放回牌库
	card_manager.push_one_card(card)
	common_suply_public_card.emit("supply_end")

# 补充公共手牌的动画结束回调
func supply_hand_card_anim_end(card: Card):
	# 重排所有手牌的ZIndex godot实际上是通过树节点的顺讯来决定点击的优先级的
	# 倒序遍历 进行move_to_top操作
	var hand_card_count = hand_cards.size()
	for i in range(hand_card_count, 0, -1):
		var card_info = hand_cards[i]
		card_info.card.z_index = i
		card_info.card.disable_click()
		card_info.card.move_to_top()
		card_info.card.global_position = card_info.position
		card_info.card.position = card_info.position
		card_info.card.rotation = card_info.rotation
		
	card.update_card()
	if not card.card_clicked.is_connected(Callable(self, "on_card_clicked")):
		card.card_clicked.connect(Callable(self, "on_card_clicked"))
	print("补充公共手牌动画结束: ", card.ID)

	# 动画结束后，发送公共区域补充牌的信号
	common_suply_public_card.emit("supply_end")

func set_aim_hand_card_empty(card) -> void:
	if card == null:
		return
	for i in hand_cards.keys():
		var card_info = hand_cards[i]
		if card_info == null or card_info.card == null:
			continue
		if card_info.card.ID == card.ID:
			if card_info.card.is_connected("card_clicked", Callable(self, "on_card_clicked")):
				card_info.card.disconnect("card_clicked", Callable(self, "on_card_clicked"))
			card_info.card.disable_click()
			card_info.card.set_card_unchooesd()
			card_info.card = null
			card_info.isEmpty = true
			print("Set card empty: ", card.ID)
			return

func enable_aim_season_hand_card_click(season) -> void:
	for i in hand_cards.keys():
		var card_info = hand_cards[i]
		if not card_info.isEmpty and card_info.card != null:
			if card_info.card.Season == season:
				card_info.card.enable_click()

# 获取当前公共区域可选的8张牌的季节，季节不重复
func get_choosable_seasons() -> Array:
	var seasons = []
	for i in hand_cards.keys():
		var card_info = hand_cards[i]
		if not card_info.isEmpty and card_info.card != null:
			if seasons.find(card_info.card.Season) == -1:
				seasons.append(card_info.card.Season)
	return seasons

func get_all_public_cards() -> Array[Card]:
	var result: Array[Card] = []
	for i in hand_cards.keys():
		var card_info = hand_cards[i]
		if card_info != null and not card_info.isEmpty and card_info.card != null:
			result.append(card_info.card)
	return result

# 清理所有状态 准备下一轮
func clear():
	for i in hand_cards.keys():
		var card_info = hand_cards[i]
		if not card_info.isEmpty and card_info.card != null:
			card_info.card.queue_free()
	hand_cards = {}
	if player_a != null and player_a.is_connected("player_choose_card", Callable(self, "on_player_choose_card")):
		player_a.disconnect("player_choose_card", Callable(self, "on_player_choose_card"))
	if player_b != null and player_b.is_connected("player_choose_card", Callable(self, "on_player_choose_card")):
		player_b.disconnect("player_choose_card", Callable(self, "on_player_choose_card"))
	player_a = null
	player_b = null
	player_current_choosing_card = null
	current_player = null
	skip_supply_anim = false
	debug_player_change_card = false
