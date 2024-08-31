extends Node

class_name CardManager

static var instance: CardManager = null

const CARD = preload("res://Scripts/Objects/Card.tscn")

# 公共牌区域
const PUBLIC_CARD_AREA_POS: Vector2 = Vector2(1400, 416)
const PUBLIC_CARD_AREA_SIZE: Vector2 = Vector2(450, 256)
const CARD_WIDTH: int = 192
const CARD_HEIGHT: int = 256


var tableManager = TableManager.get_instance()

var cardIDs = []

func _init():
	if instance == null:
		push_error("CardManager already exists. Use CardManager.get_instance() instead.")

static func get_instance() -> CardManager:
	if instance == null:
		instance = CardManager.new()
	return instance


func collect_cardIDs_for_this_game(types:Array) -> void:
	var cards = tableManager.get_table("Cards")
	for card_id in cards.keys():
		if card_id == 0:
			continue
		var type = int(str(card_id)[0])
		if types.find(type) != -1:
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
	card.initialize(card_id, card_info["Name"], card_info["PinyinName"], card_info["Score"], card_info["Season"], card_info["BaseID"], card_info["Special"])
	return card

func init_cards_position_to_public_area(cards):
	var card_count = cards.size()
	if card_count == 0:
		return

	# 计算最右边卡片的左边缘位置
	var rightmost_pos_x = PUBLIC_CARD_AREA_POS.x + PUBLIC_CARD_AREA_SIZE.x - CARD_WIDTH

	# 计算间隔
	var gap_width = (PUBLIC_CARD_AREA_SIZE.x - CARD_WIDTH) / (card_count - 1)

	# 从左到右放置卡片
	var current_x = PUBLIC_CARD_AREA_POS.x
	for i in range(card_count):
		var card = cards[i]
		if i != 0:
			current_x += gap_width

		# 如果当前位置已经超过最右位置，则将卡片放在最右边
		print("当前X坐标: ", current_x, "最右边位置: ", rightmost_pos_x)
		if current_x < rightmost_pos_x:
			card.position.x = current_x
		else:
			card.position.x = rightmost_pos_x

		# 设置Y坐标（垂直居中）
		card.position.y = PUBLIC_CARD_AREA_POS.y
		print("卡牌位置: ", card.position)
