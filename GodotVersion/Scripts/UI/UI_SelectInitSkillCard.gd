extends Node2D

@onready var label_title: Label = $Label_Title
@onready var card_table_view: VBoxContainer = $ColorRect/ScrollContainer/CardTableView

var card_datas = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_card_datas(cards: Array) -> void:
	card_datas = cards

func init_card_table_view() -> void:
	for card_data in card_datas:
		var card = Card.new()
		card.set_card_data(card_data)
		card_table_view.add_child(card)
		# card.connect("card_selected", self, "_on_card_selected")