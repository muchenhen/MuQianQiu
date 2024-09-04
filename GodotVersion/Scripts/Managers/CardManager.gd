extends Node

class_name CardManager

static var instance: CardManager = null

const CARD = preload("res://Scripts/Objects/Card.tscn")

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

func get_one_card() -> Node:
	if cardIDs.size() == 0:
		return null
	var card_id = cardIDs.pop_front()
	return create_one_card(card_id)

func create_cards_for_this_game() -> Array:
	var cards = []
	for card_id in cardIDs:
		cards.append(create_one_card(card_id))
	return cards

func create_one_card(card_id:int) -> Node:
	var card = CARD.instantiate()
	var card_info = tableManager.get_row("Cards", card_id)
	card.initialize(card_id, card_info)
	return card

# 初始化公共区域手牌的每一个位置
func init_cards_position_to_public_area(cards):
	var card_count = cards.size()
	if card_count == 0:
		return

	var pos_array = init_cards_position_tile(PUBLIC_CARD_AREA_SIZE, PUBLIC_CARD_AREA_POS, card_count)
	# 从左到右放置卡片
	for i in range(card_count):
		var card = cards[i]
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
