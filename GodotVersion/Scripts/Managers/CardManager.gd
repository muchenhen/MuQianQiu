extends Node

class_name CardManager

static var instance: CardManager = null

var player_a = null
var player_b = null

const CARD = preload("res://Scripts/Objects/Card.tscn")

var all_cards = []

# 公共牌区域
const PUBLIC_CARD_AREA_POS: Vector2 = Vector2(1400, 416)
const PUBLIC_CARD_AREA_SIZE: Vector2 = Vector2(450, 256)
const CARD_WIDTH: int = 192
const CARD_HEIGHT: int = 256

var PLAYER_DEAL_CARD_ROTATION_MIN: float = -30
var PLAYER_DEAL_CARD_ROTATION_MAX: float = 30

# 玩家B区域
const PLAYER_B_CARD_AREA_POS: Vector2 = Vector2(384, 64)
const PLAYER_B_CARD_AREA_SIZE: Vector2 = Vector2(1152, 256)

var PLAYER_B_DEAL_CARD_POS: Vector2

# 玩家A区域
const PLAYER_A_CARD_AREA_POS: Vector2 = Vector2(384, 768)
const PLAYER_A_CARD_AREA_SIZE: Vector2 = Vector2(1152, 256)

var PLAYER_A_DEAL_CARD_POS: Vector2

# 公共牌堆的八张牌的位置
var PUBLIC_CARDS_POS = []
var PUBLIC_CRADS_ROTATION = []



var tableManager = TableManager.get_instance()

var cardIDs = []

func _init():
	if instance == null:
		push_error("CardManager already exists. Use CardManager.get_instance() instead.")

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
	collect_cardIDs_for_this_game(types)
	shuffle_cardIDs()

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

func shuffle_cardIDs() -> void:
	cardIDs.shuffle()

func create_cards_for_this_game(scene) -> void:
	for card_id in cardIDs:
		var card = create_one_card(card_id)
		all_cards.append(card)
		scene.get_node("Cards").add_child(card)
	
	PLAYER_A_DEAL_CARD_POS = scene.get_node("Cards").get_node("PlayerADealCard").position
	PLAYER_B_DEAL_CARD_POS = scene.get_node("Cards").get_node("PlayerBDealCard").position

	set_all_card_back()
	init_cards_position_for_public()

func create_one_card(card_id:int) -> Node:
	var card = CARD.instantiate()
	var card_info = tableManager.get_row("Cards", card_id)
	card.initialize(card_id, card_info)
	card.name = "Card_" + str(card_id)
	return card

func pop_one_card() -> Node:
	if all_cards.size() == 0:
		return null
	var card = all_cards.pop_back()
	return card

func push_one_card(card:Card) -> void:
	all_cards.append(card)

func re_shuffle_all_cards() -> void:
	all_cards.shuffle()

# 初始化公共区域手牌的每一个位置
func init_cards_position_for_public():
	var card_count = all_cards.size()
	if card_count == 0:
		return

	var pos_array = init_cards_position_tile(PUBLIC_CARD_AREA_SIZE, PUBLIC_CARD_AREA_POS, card_count)
	# 从左到右放置卡片
	for i in range(card_count):
		var card = all_cards[i]
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
	for card in all_cards:
		card.set_card_back()
		card.disable_click()

func bind_players(p_a, p_b) -> void:
	player_a = p_a
	player_b = p_b
	player_a.connect("player_choose_change_card", Callable(self, "on_player_choose_change_card"))
	player_b.connect("player_choose_change_card", Callable(self, "on_player_choose_change_card"))

# 此时玩家手上已经没可以和公共区域匹配的牌了，需要从没有放到公共区域的牌中随机选择一张，和玩家的current_choosing_card_id的对应Card进行交换
# 交换包括位置和所属权，并且更新显示
func on_player_choose_change_card(player:Player) -> void:
	
	var current_choosing_player_hand_card:PlayerHandCard = player.get_current_choosing_player_hand_card()
	
	# 玩家现在手上选择的去交换的牌
	var current_card_in_player:Card = current_choosing_player_hand_card.card
	# 当前公共区域可以选择的seasons
	var current_public_card_seasons = GameManager.instance.get_public_card_deal().get_choosable_seasons()

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
	await GameManager.instance.get_tree().create_timer(0.5).timeout

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
	re_shuffle_all_cards()

	# 将新的卡放到玩家手上
	player.assign_player_hand_card_to_slot(new_card_to_player, new_card_slot_index)

	var has_season:bool = player.check_hand_card_season()
	if has_season:
		player.set_player_state(Player.PlayerState.SELF_ROUND_UNCHOOSING)
		player.update_self_card_z_index()
		new_card_to_player.enable_click()

	
