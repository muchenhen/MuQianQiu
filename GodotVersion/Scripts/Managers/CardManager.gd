extends Node

const CARD = preload("res://Scripts/Objects/Card.tscn")

const MAIN_SCENE = preload("res://main.tscn")

func generate_deck():
	var deck = []
	for i in range(56):
		var card =  CARD.instantiate()
		card.position = Vector2.ZERO + Vector2(0, i * 2)
		# 生成到main场景中
		var main_scene_ui_node = MAIN_SCENE.get_node("UI")
		main_scene_ui_node.add_child(card)
		deck.append(card)
	return deck
