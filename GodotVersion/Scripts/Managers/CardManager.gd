extends Node

class_name CardManager

static var instance: CardManager = null

const CARD = preload("res://Scripts/Objects/Card.tscn")


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
