extends Node

class_name CardManager

static var instance: CardManager = null

var tableManager = TableManager.get_instance()

const CARD = preload("res://Scripts/Objects/Card.tscn")

# 公共牌区域
const PUBLIC_CARD_AREA_POS: Vector2 = Vector2(1400, 416)
const PUBLIC_CARD_AREA_SIZE: Vector2 = Vector2(450, 256)
const CARD_WIDTH: int = 192
const CARD_HEIGHT: int = 256
# 玩家牌堆随机旋转角度
const PLAYER_DEAL_CARD_ROTATION_MIN: float = -30
const PLAYER_DEAL_CARD_ROTATION_MAX: float = 30
# 玩家牌堆位置
var PLAYER_A_DEAL_CARD_POS: Vector2
var PLAYER_B_DEAL_CARD_POS: Vector2
# 玩家A区域
const PLAYER_A_CARD_AREA_POS: Vector2 = Vector2(384, 768)
const PLAYER_A_CARD_AREA_SIZE: Vector2 = Vector2(1152, 256)
# 玩家B区域
const PLAYER_B_CARD_AREA_POS: Vector2 = Vector2(384, 64)
const PLAYER_B_CARD_AREA_SIZE: Vector2 = Vector2(1152, 256)
# 公共牌堆的八张牌的位置
var PUBLIC_CARDS_POS = []
var PUBLIC_CRADS_ROTATION = []

var player_a = null
var player_b = null

# 所有卡牌
var all_scene_cards = []
# 所有公共牌库中的卡牌
var all_storage_cards = []
var cardIDs = []

var skill_cardIDs: Array[int] = []
var skill_card_map = {}

# 添加发牌相关的变量
var current_card_index = 0
var game_instance_ref = null

func _init():
	if instance == null:
		print("CardManager already exists. Use CardManager.get_instance() instead.")

static func get_instance() -> CardManager:
	if instance == null:
		instance = CardManager.new()
	return instance

func get_card_season(card_id:int) -> String:
	var card_info = tableManager.get_row("Cards", card_id)
	return card_info["Season"]

func collect_public_deal_cards_pos(cards_pos:Array, cards_rotation:Array) -> void:
	for i in range(cards_pos.size()):
		var pos = cards_pos[i]
		PUBLIC_CARDS_POS.append(pos)
		PUBLIC_CRADS_ROTATION.append(cards_rotation[i])

# 为当前游戏会话准备卡牌。
# 此函数根据提供的类型收集并洗牌卡牌ID。
#
# @param types 包含在游戏中的卡牌类型数组。
# @return void
func prepare_cards_for_this_game(types:Array) -> void:
	cardIDs.clear()
	all_storage_cards.clear()
	collect_cardIDs_for_this_game(types)
	shuffle_cardIDs()
	collect_skill_cardIDs_for_this_game()

func collect_cardIDs_for_this_game(types:Array) -> void:
	var cards = tableManager.get_table("Cards")
	for card_id in cards.keys():
		if card_id == 0:
			continue
		var card_info = cards[card_id]
		var type = int(str(card_id)[0])
		if types.find(type) != -1:
			if not card_info["Special"]:
				cardIDs.append(card_id)

func collect_skill_cardIDs_for_this_game() -> void:
	skill_cardIDs = []
	var index_to_card_skill = tableManager.get_table("Skills")
	for card_id in index_to_card_skill.keys():
		if card_id == 0:
			continue
		skill_cardIDs.append(card_id)
		print_debug("skill_cardIDs: ", skill_cardIDs)

func shuffle_cardIDs() -> void:
	cardIDs.shuffle()

## 执行发牌流程，包含发牌和动画
## 参数：
## - cards: 要发放的卡牌数组
## - game_instance: GameInstance引用，用于回调
func send_cards_for_play(cards: Array, game_instance):
	game_instance_ref = game_instance
	
	# 阶段1: 准备要动画的卡牌数据
	var cards_to_deal = []  # 存储所有需要发牌的数据
	
	# 处理玩家手牌
	for i in range(player_a.hand_cards_pos_array.size() + player_b.hand_cards_pos_array.size()):
		# A和B玩家轮流发牌
		var card = cards.pop_back()
		if i % 2 == 0:
			cards_to_deal.append({"card": card, "position": player_a.hand_cards_pos_array.pop_front()})
			var index:int = player_a.get_player_first_enpty_hand_card_index()
			player_a.assign_player_hand_card_to_slot(card, index)
		else:
			cards_to_deal.append({"card": card, "position": player_b.hand_cards_pos_array.pop_front()})
			var index:int = player_b.get_player_first_enpty_hand_card_index()
			player_b.assign_player_hand_card_to_slot(card, index)
	
	# 处理公共卡牌
	for i in range(PUBLIC_CARDS_POS.size()):
		var position = PUBLIC_CARDS_POS[i]
		var rotation = PUBLIC_CRADS_ROTATION[i]
		var card = cards.pop_back()
		card.z_index = 8 - i
		card.set_input_priority(card.z_index)
		# 公共卡池点击交由 PublicCardDeal 统一处理
		game_instance.public_deal.set_one_hand_card(card, position, rotation)
		cards_to_deal.append({"card": card, "position": position, "rotation": rotation})
	
	game_instance.public_deal.disable_all_hand_card_click()
	
	# 开始发牌动画
	_start_card_dealing_sequence(cards_to_deal)

## 开始发牌动画序列
func _start_card_dealing_sequence(cards_to_deal: Array):
	current_card_index = 0
	_deal_next_card(cards_to_deal)

## 处理下一张卡的发牌动画
func _deal_next_card(cards_to_deal: Array):
	if current_card_index < cards_to_deal.size():
		var card_data = cards_to_deal[current_card_index]
		var card = card_data["card"]
		var position = card_data["position"]
		
		# 启动移动动画
		AnimationManager.get_instance().start_linear_movement_pos(card, position, 0.6, 
			AnimationManager.EaseType.EASE_IN_OUT, 
			Callable(game_instance_ref, "card_animation_end"), [card, false])
		
		# 如果需要旋转，添加旋转动画
		if "rotation" in card_data:
			var rotation = card_data["rotation"]
			AnimationManager.get_instance().start_linear_movement_rotation(card, rotation, 0.6, 
				AnimationManager.EaseType.EASE_IN_OUT)
		
		current_card_index += 1
		
		# 使用GameManager创建定时器处理下一张卡
		GameManager.create_timer(0.1, Callable(self, "_deal_next_card").bind(cards_to_deal))
	else:
		# 所有卡牌发放完毕
		_on_all_cards_dealt()

## 所有卡牌发放完毕的回调
func _on_all_cards_dealt():
	_on_all_cards_dealt_async.call_deferred()

func _on_all_cards_dealt_async():
	for key in game_instance_ref.public_deal.hand_cards.keys():
		var public_card = game_instance_ref.public_deal.hand_cards[key]
		if public_card.isEmpty:
			continue
		print("公共区域手牌 ", key, " ID: ", public_card.card.ID)
	print("发牌完毕")
	
	# 触发游戏开始信号
	game_instance_ref.game_start.emit()
	
	# 检查并处理玩家特殊卡（等待动画完成）
	await game_instance_ref.process_special_cards()
	
	game_instance_ref.prepare_first_round()
	
	InputManager.get_instance().allow_input()


# 创建技能牌的映射
func create_skill_card_map():
	skill_card_map = {}
	var skills = tableManager.get_table("Skills")
	for card_id in skills.keys():
		var skill_info = skills[card_id]
		skill_card_map[card_id] = skill_info

	for card_id in cardIDs:
		var card_info = tableManager.get_row("Cards", card_id)
		if card_info["Special"]:
			skill_card_map[card_id] = card_info
	return skill_card_map

# 检查卡牌是否是技能牌目标
func check_card_is_skill(card_id:int) -> bool:
	return skill_card_map.has(card_id)


func create_cards_for_this_game(cards_node:Node) -> void:
	for card_id in cardIDs:
		var card = create_one_card(card_id)
		all_storage_cards.append(card)
		all_scene_cards.append(card)
		cards_node.add_child(card)
	
	PLAYER_A_DEAL_CARD_POS = cards_node.get_node("PlayerADealCard").position
	PLAYER_B_DEAL_CARD_POS = cards_node.get_node("PlayerBDealCard").position

	set_all_card_back()
	init_cards_position_for_public()

func create_one_card(card_id:int) -> Node:
	var card = CARD.instantiate()
	var card_info = tableManager.get_row("Cards", card_id)
	card.initialize(card_id, card_info)
	card.name = "Card_" + str(card_id)
	return card

func pop_one_card() -> Node:
	if all_storage_cards.size() == 0:
		return null
	var card = all_storage_cards.pop_back()
	return card

func pop_card_by_id(card_id: int) -> Card:
	for i in range(all_storage_cards.size() - 1, -1, -1):
		var card: Card = all_storage_cards[i]
		if card.ID == card_id or card.BaseID == card_id:
			all_storage_cards.remove_at(i)
			return card
	return null

func push_one_card(card:Card) -> void:
	all_storage_cards.append(card)

func re_shuffle_all_cards() -> void:
	all_storage_cards.shuffle()

# 初始化公共区域手牌的每一个位置
func init_cards_position_for_public():
	var card_count = all_storage_cards.size()
	if card_count == 0:
		return

	var pos_array = init_cards_position_tile(PUBLIC_CARD_AREA_SIZE, PUBLIC_CARD_AREA_POS, card_count)
	# 从左到右放置卡片
	for i in range(card_count):
		var card = all_storage_cards[i]
		card.position.x = pos_array[i].x
		# 设置Y坐标（垂直居中）
		card.position.y = PUBLIC_CARD_AREA_POS.y


func init_cards_position_tile(area_size:Vector2, area_pos:Vector2, card_count:int) -> Array:
	# 最右的位置
	var rightmost_pos_x = area_pos.x + area_size.x - CARD_WIDTH

	var gap_width = (area_size.x - CARD_WIDTH) / (card_count - 1)

	var card_pos_array = []
	var current_x = area_pos.x
	for i in range(card_count):
		if i != 0:
			current_x += gap_width
		
		if current_x < rightmost_pos_x:
			card_pos_array.push_back(Vector2(current_x, area_pos.y))
		else:
			card_pos_array.push_back(Vector2(rightmost_pos_x, area_pos.y))
	
	return card_pos_array

func get_random_deal_card_rotation() -> float:
	var random_angle = randf_range(PLAYER_DEAL_CARD_ROTATION_MIN, PLAYER_DEAL_CARD_ROTATION_MAX)
	# 角度转弧度
	return deg_to_rad(random_angle)

func set_all_card_back() -> void:
	for card in all_storage_cards:
		card.set_card_back()
		card.disable_click()

func bind_players(p_a, p_b) -> void:
	player_a = p_a
	player_b = p_b
	player_a.connect("player_choose_change_card", Callable(self, "on_player_choose_change_card"))
	player_b.connect("player_choose_change_card", Callable(self, "on_player_choose_change_card"))

# 获取牌库中所有牌的季节，季节不重复
func get_storage_seasons() -> Array:
	var seasons = []
	for card in all_storage_cards:
		if seasons.find(card.Season) == -1:
			seasons.append(card.Season)
	return seasons

# 此时玩家手上已经没可以和公共区域匹配的牌了，需要从没有放到公共区域的牌中随机选择一张，和玩家的current_choosing_card_id的对应Card进行交换
# 交换包括位置和所属权，并且更新显示
func on_player_choose_change_card(player:Player) -> void:
	
	var current_choosing_player_hand_card:PlayerHandCard = player.get_current_choosing_player_hand_card()
	
	# 玩家现在手上选择的去交换的牌
	var current_card_in_player:Card = current_choosing_player_hand_card.card
	# 当前公共区域可以选择的seasons
	var current_public_card_seasons = GameManager.instance.get_public_card_deal().get_choosable_seasons()

	# 确认牌库中是否还存在和公共区域的season匹配的牌
	var storage_seasons = get_storage_seasons()
	var has_season_in_storage = false
	for season in storage_seasons:
		if current_public_card_seasons.find(season) != -1:
			has_season_in_storage = true
			break
	
	# 至少还有一张牌的season和公共区域的season匹配，可以尝试交换
	if has_season_in_storage:
		# 重新洗牌 然后pop_one_card, 然后检查这张卡的season是否存在于current_public_card_seasons中，如果存在则继续，否则重新洗牌
		var new_card_to_player:Card = pop_one_card() # 这是从牌库获取的新牌
		while new_card_to_player.get_season() not in current_public_card_seasons:
			push_one_card(new_card_to_player)
			re_shuffle_all_cards()
			new_card_to_player = pop_one_card()
		# 标记两张卡的z
		var current_card_z = current_card_in_player.z_index
		var new_card_z = new_card_to_player.z_index
		# 标记两张卡的位置
		var current_card_pos = current_card_in_player.position
		var new_card_pos = new_card_to_player.position
		# 标记玩家当前要被换走的卡的slot_index
		var new_card_slot_index = current_choosing_player_hand_card.slot_index
		# 动画位移交换两张卡的位置
		AnimationManager.get_instance().start_linear_movement_pos(current_card_in_player, new_card_pos, 0.5, AnimationManager.EaseType.EASE_IN_OUT)
		AnimationManager.get_instance().start_linear_movement_pos(new_card_to_player, current_card_pos, 0.5, AnimationManager.EaseType.EASE_IN_OUT)
		# 等动画结束
		await GameManager.instance.scene_tree.create_timer(0.5).timeout
		# 交换两张卡的z
		current_card_in_player.z_index = new_card_z
		new_card_to_player.z_index = current_card_z

		new_card_to_player.update_card()
		new_card_to_player.set_card_unchooesd()
		current_card_in_player.set_card_back()
		current_card_in_player.disable_click()
		current_card_in_player.set_card_unchooesd()

		# 将玩家的交还的卡放到公共区域
		push_one_card(current_card_in_player)
		player.recover_hand_card_free(current_card_in_player)

		re_shuffle_all_cards()
		# 将新的卡放到玩家手上
		player.assign_player_hand_card_to_slot(new_card_to_player, new_card_slot_index)

		var has_season:bool = player.check_hand_card_season()
		if not has_season:
			push_error("Player has no hand card to choose.")
			return

		player.set_player_state(Player.PlayerState.SELF_ROUND_UNCHOOSING, true)

		player.update_self_card_z_index()
		if player.is_ai_player():
			return

		new_card_to_player.enable_click()

## 特殊卡升级动画完成的回调函数
func on_special_card_upgrade_complete(special_card, public_card, original_zindex, continue_callback):
	print("特殊卡升级动画完成")
	# 确保特殊卡与公共卡完全对齐
	special_card.position = public_card.position
	special_card.rotation = public_card.rotation
	
	# 将公共卡升级为特殊卡
	public_card.upgrade_to_special(special_card.ID)
	
	# 隐藏特殊卡，因为公共卡已经升级成特殊卡了
	special_card.visible = false
	
	# 恢复特殊卡的原始z_index
	special_card.z_index = original_zindex
	
	# 启用公共卡的点击（现在是升级后的特殊卡）
	public_card.enable_click()
	
	# 继续执行选择卡牌的后续流程
	continue_callback.call()


func destroy_all_scene_cards() -> void:
	for card in all_scene_cards:
		card.queue_free()
	all_scene_cards.clear()

func clear():
	PUBLIC_CARDS_POS = []
	PUBLIC_CRADS_ROTATION = []
	destroy_all_scene_cards()
	all_storage_cards.clear()
	cardIDs.clear()
	skill_cardIDs.clear()
	if player_a != null and player_a.is_connected("player_choose_change_card", Callable(self, "on_player_choose_change_card")):
		player_a.disconnect("player_choose_change_card", Callable(self, "on_player_choose_change_card"))
	if player_b != null and player_b.is_connected("player_choose_change_card", Callable(self, "on_player_choose_change_card")):
		player_b.disconnect("player_choose_change_card", Callable(self, "on_player_choose_change_card"))
	player_a = null
	player_b = null
