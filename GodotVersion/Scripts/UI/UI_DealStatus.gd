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

@onready var finished_story = $FinishedStory

@onready var current_deal = $CurrentDeal

@onready var button_back = $ButtonBack
@onready var button_current_deal = $ButtonCurrentDeal
@onready var button_finished_story = $ButtonFinishedStory

var ui_manager:UIManager = UIManager.get_instance()
var story_manager:StoryManager = StoryManager.get_instance()

var current_player:Player = null

var cards = []

func _ready() -> void:
	# 绑定返回按钮点击事件
	button_back.connect("pressed", Callable(self, "_on_button_back_click"))
	button_current_deal.connect("pressed", Callable(self, "_on_button_current_deal_click"))
	button_finished_story.connect("pressed", Callable(self, "_on_button_finished_story_click"))

	cards = [card1, card2, card3, card4, card5, card6, card7, card8, card9, card10, card11, card12, card13, card14, card15, card16, card17, card18, card19, card20]
	# 设置所有cards不可见 并且禁止点击
	for card in cards:
		card.hide()
		card.disable_click()

	current_deal.show()
	finished_story.hide()


func set_card_info_by_index_with_id(index: int, card_id: int) -> void:
	if index < 0 or index >= cards.size():
		return
	var card = cards[index]
	card.update_card_info_by_id(card_id)
	card.show()


func update_deal_status_by_player(player: Player) -> void:
	current_player = player
	var deal_cards:Dictionary = player.deal_cards
	var index = 0
	for i in range(deal_cards.size()):
		var card_id = deal_cards.keys()[i]
		set_card_info_by_index_with_id(index, card_id)
		index += 1
	
	update_finished_story_by_player(player)

	# var card_ids = deal_cards.keys()
	# # 通过已经属于玩家的卡牌，检索所有包含这些卡牌的故事
	# var story_ids = story_manager.get_relent_stories_by_cards_id(card_ids)
	# for story_id in story_ids:
	# 	# 创建一个UI_DealStoryStatus实例
	# 	var deal_story_status:UI_DealStoryStatus = ui_manager.create_ui_instance_for_multi("UI_DealStoryStatus")
	# 	# 将deal_story_status添加到finished_story
	# 	finished_story.add_child(deal_story_status)
	# 	deal_story_status.update_story_status_by_id(story_id)
	
func update_finished_story_by_player(player: Player) -> void:
	var finished_stories = player.finished_stories
	for story in finished_stories:
		var story_id = story["ID"]
		# 创建一个UI_DealStoryStatus实例
		var deal_story_status:UI_DealStoryStatus = ui_manager.create_ui_instance_for_multi("UI_DealStoryStatus")
		# 将deal_story_status添加到finished_story
		finished_story.add_child(deal_story_status)
		deal_story_status.update_story_status_by_id(story_id)


func _on_button_current_deal_click():
	current_deal.show()
	finished_story.hide()

func _on_button_finished_story_click():
	current_deal.hide()
	finished_story.show()


func _on_button_back_click():
	ui_manager.destroy_ui("UI_DealStatus")
