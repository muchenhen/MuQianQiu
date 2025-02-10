extends Node2D

class_name UI_StoryShow

@onready var text_story_name:Label = $Text_StoryName

var card_box:HorizontalBox = null

func _ready() -> void:
	card_box = get_node("CardBox")
	clear_all_cards()

func add_card(card:Node) -> void:
	card_box.add_child(card)

func layout_children() -> void:
	card_box.layout_items()

func set_story_name(story_name:String) -> void:
	text_story_name.text = story_name

func clear_all_cards() -> void:
	if card_box == null:
		print_debug("card_box is null")
		return
	# 销毁card_box中的所有子节点
	for child in card_box.get_children():
		card_box.remove_child(child)
		child.queue_free()
		
