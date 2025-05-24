extends Node

class_name UI_DealStoryStatus

@onready var hor_box = $Node2D/HorBox

@onready var card1: Card = $Node2D/HorBox/Card1
@onready var card2: Card = $Node2D/HorBox/Card2
@onready var card3: Card = $Node2D/HorBox/Card3
@onready var card4: Card = $Node2D/HorBox/Card4
@onready var card5: Card = $Node2D/HorBox/Card5
@onready var card6: Card = $Node2D/HorBox/Card6
@onready var card7: Card = $Node2D/HorBox/Card7
@onready var card8: Card = $Node2D/HorBox/Card8


@onready var story_name = $Node2D/Text_StoryName


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
# 如果传入了player参数，会检查玩家牌堆中是否有对应的特殊卡，有则优先显示特殊卡
func update_story_status_by_id(story_id: int, player: Player = null) -> void:
	hor_box.layout_items()
	var story_manager = StoryManager.get_instance()
	var story = story_manager.stories[story_id]
	var cards_id:Array = story.cards_id
	story_name.text = story.name

	var index:int = 0
	for card_id in cards_id:
		var card:Card = cards[index]
		card.show()
		var special_card_id = player.check_special_card_in_deal(card_id)
		if special_card_id != -1:
			card.update_card_info_by_id(special_card_id)
		else:
			card.update_card_info_by_id(card_id)
		index += 1		
	

# 传入一组卡牌ID，检查所有可见的卡牌，ID存在于传入的卡牌ID数组中的卡牌，设置彩色，否则设置灰色
# 特殊处理：如果传入的卡牌ID中包含特殊卡，则其对应的基础卡也视为可用
func set_card_color_by_ids(cards_id:Array) -> void:
	for card in cards:
		if card.is_visible():
			if cards_id.find(card.ID) != -1:
				card.set_card_gray(false)
			else:
				card.set_card_gray(true)
