extends Node

class_name UI_DealStoryStatus

@onready var card1: Card = $ColorRect/Card1
@onready var card2: Card = $ColorRect/Card2
@onready var card3: Card = $ColorRect/Card3
@onready var card4: Card = $ColorRect/Card4
@onready var card5: Card = $ColorRect/Card5
@onready var card6: Card = $ColorRect/Card6
@onready var card7: Card = $ColorRect/Card7
@onready var card8: Card = $ColorRect/Card8

@onready var story_name = $StoryName


var cards = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 设置所有cards不可见 并且禁止点击
	cards = [card1, card2, card3, card4, card5, card6, card7, card8]
	for card in cards:
		card.hide()
		card.disable_click()

# 通过故事ID更新UI，显示故事对应的卡牌，但是保持不可点击
func update_story_status_by_id(story_id: int) -> void:
	var story_manager = StoryManager.get_instance()
	var story = story_manager.stories[story_id]
	var cards_id = story["CardsID"]
	for i in range(cards_id.size()):
		var card_id = cards_id[i]
		var card = cards[i]
		card.update_card_info_by_id(card_id)
		card.show()