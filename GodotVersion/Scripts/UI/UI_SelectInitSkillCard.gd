extends Node2D

@onready var label_title: Label = $Label_Title
@onready var card_table_view: VBoxContainer = $ColorRect/ScrollContainer/CardTableView

var card_ids: Array[int] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_card_datas(in_card_ids: Array[int]) -> void:
	card_ids = in_card_ids

func init_card_table_view() -> void:
	for card_id in card_ids:
		var card:Card = Card.new()
		# 使用Card类中正确的initialize方法初始化卡片
		card.update_card_info_by_id(card_id)
		card_table_view.add_child(card)
		# 连接card_clicked信号
		# card.connect("card_clicked", Callable(self, "_on_card_selected"))
