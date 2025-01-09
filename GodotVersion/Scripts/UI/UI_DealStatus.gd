extends Node

class_name UI_DealStatus

@onready var card1: Card = $ColorRect/Card1
@onready var card2: Card = $ColorRect/Card2
@onready var card3: Card = $ColorRect/Card3
@onready var card4: Card = $ColorRect/Card4
@onready var card5: Card = $ColorRect/Card5
@onready var card6: Card = $ColorRect/Card6
@onready var card7: Card = $ColorRect/Card7
@onready var card8: Card = $ColorRect/Card8
@onready var card9: Card = $ColorRect/Card9
@onready var card10: Card = $ColorRect/Card10
@onready var card11: Card = $ColorRect/Card11
@onready var card12: Card = $ColorRect/Card12
@onready var card13: Card = $ColorRect/Card13
@onready var card14: Card = $ColorRect/Card14
@onready var card15: Card = $ColorRect/Card15
@onready var card16: Card = $ColorRect/Card16
@onready var card17: Card = $ColorRect/Card17
@onready var card18: Card = $ColorRect/Card18
@onready var card19: Card = $ColorRect/Card19
@onready var card20: Card = $ColorRect/Card20

var cards = []

func _ready() -> void:
	cards = [card1, card2, card3, card4, card5, card6, card7, card8, card9, card10, card11, card12, card13, card14, card15, card16, card17, card18, card19, card20]
	# 设置所有cards不可见 并且禁止点击
	for card in cards:
		card.hide()
		card.disable_click()

	
func set_card_info_by_index_with_id(index: int, card_id: int) -> void:
	if index < 0 or index >= cards.size():
		return
	var card = cards[index]
	card.update_card_info_by_id(card_id)
	card.show()
