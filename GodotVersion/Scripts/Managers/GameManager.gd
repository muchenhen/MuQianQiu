extends Node

var card_manager = preload("res://Scripts/Managers/CardManager.gd").new()

func _ready():
	# 将卡牌管理器添加到场景中
	add_child(card_manager)

func game_start():
	print("Game start")
	card_manager.generate_deck()
