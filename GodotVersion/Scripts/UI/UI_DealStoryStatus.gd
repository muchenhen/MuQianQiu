extends Node

class_name UI_DealStoryStatus

@onready var card1: Card = $HorBox/Card1
@onready var card2: Card = $HorBox/Card2
@onready var card3: Card = $HorBox/Card3
@onready var card4: Card = $HorBox/Card4
@onready var card5: Card = $HorBox/Card5
@onready var card6: Card = $HorBox/Card6
@onready var card7: Card = $HorBox/Card7
@onready var card8: Card = $HorBox/Card8

@onready var hor_box = $HorBox

@onready var story_name = $Text_StoryName


var cards:Array[Card] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hor_box.layout_items()
	# 设置所有cards不可见 并且禁止点击
	cards = [card1, card2, card3, card4, card5, card6, card7, card8]
	for card in cards:
		card.hide()
		card.disable_click()

# 通过故事ID更新UI，显示故事对应的卡牌，但是保持不可点击
func update_story_status_by_id(story_id: int) -> void:
	hor_box.layout_items()
	var story_manager = StoryManager.get_instance()
	var story = story_manager.stories[story_id]
	var cards_id:Array = story["CardsID"]
	story_name.text = story["Name"]

	var index:int = 0
	for card_id in cards_id:
		var card = cards[index]
		card.show()
		card.update_card_info_by_id(card_id)
		index += 1		
	
