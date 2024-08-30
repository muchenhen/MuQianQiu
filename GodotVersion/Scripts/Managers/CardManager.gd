extends Node

const CARD = preload("res://Scripts/Objects/Card.tscn")

func generate_deck():
	pass

func create_one_card(card_id:int) -> Node:
	var card = CARD.instantiate()
	return card
