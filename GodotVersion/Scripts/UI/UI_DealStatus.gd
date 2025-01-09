extends Node

class_name UI_DealStatus

@onready var card1: Card = $CurrentDeal/Card1
@onready var card2: Card = $CurrentDeal/Card2
@onready var card3: Card = $CurrentDeal/Card3
@onready var card4: Card = $CurrentDeal/Card4
@onready var card5: Card = $CurrentDeal/Card5
@onready var card6: Card = $CurrentDeal/Card6
@onready var card7: Card = $CurrentDeal/Card7
@onready var card8: Card = $CurrentDeal/Card8
@onready var card9: Card = $CurrentDeal/Card9
@onready var card10: Card = $CurrentDeal/Card10
@onready var card11: Card = $CurrentDeal/Card11
@onready var card12: Card = $CurrentDeal/Card12
@onready var card13: Card = $CurrentDeal/Card13
@onready var card14: Card = $CurrentDeal/Card14
@onready var card15: Card = $CurrentDeal/Card15
@onready var card16: Card = $CurrentDeal/Card16
@onready var card17: Card = $CurrentDeal/Card17
@onready var card18: Card = $CurrentDeal/Card18
@onready var card19: Card = $CurrentDeal/Card19
@onready var card20: Card = $CurrentDeal/Card20

@onready var button_back = $ButtonBack

var ui_manager:UIManager = UIManager.get_instance()

var cards = []

func _ready() -> void:
	cards = [card1, card2, card3, card4, card5, card6, card7, card8, card9, card10, card11, card12, card13, card14, card15, card16, card17, card18, card19, card20]
	# 设置所有cards不可见 并且禁止点击
	for card in cards:
		card.hide()
		card.disable_click()
	# 绑定返回按钮点击事件
	button_back.connect("pressed", Callable(self, "_on_button_back_click"))


func set_card_info_by_index_with_id(index: int, card_id: int) -> void:
	if index < 0 or index >= cards.size():
		return
	var card = cards[index]
	card.update_card_info_by_id(card_id)
	card.show()

func update_deal_status_by_player(player: Player) -> void:
	var deal_cards:Dictionary = player.deal_cards
	var index = 0
	for i in range(deal_cards.size()):
		var card_id = deal_cards.keys()[i]
		set_card_info_by_index_with_id(index, card_id)
		index += 1


func _on_button_back_click():
	ui_manager.destroy_ui("UI_DealStatus")
