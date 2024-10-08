extends Node2D

var card_box:HorizontalBox = null

func _ready() -> void:
	card_box = get_node("CardBox")
	# 初始化手牌

func add_card(card:Node) -> void:
	card_box.add_child(card)

func layout_children() -> void:
	card_box.layout_items()
