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

@onready var finished_stroy_scroll = $FinishedStoryScroll
@onready var finished_story_vb = $FinishedStoryScroll/FinishedStoryVB
@onready var unfinished_story_scroll = $UnFinishedStoryScroll
@onready var unfinished_story_vb = $UnFinishedStoryScroll/UnFinishedStoryVB

@onready var current_deal = $CurrentDeal

@onready var button_back = $ButtonBack
@onready var button_current_deal = $ButtonCurrentDeal
@onready var button_finished_story = $ButtonFinishedStory
@onready var button_no_complete_story = $ButtonNoCompleteStory

var ui_manager:UIManager = UIManager.get_instance()
var story_manager:StoryManager = StoryManager.get_instance()

var current_player:Player = null

var test_index = 0;

var cards = []

func _ready() -> void:
	# 绑定返回按钮点击事件
	button_back.connect("pressed", Callable(self, "_on_button_back_click"))
	button_current_deal.connect("pressed", Callable(self, "_on_button_current_deal_click"))
	button_finished_story.connect("pressed", Callable(self, "_on_button_finished_story_click"))
	button_no_complete_story.connect("pressed", Callable(self, "_on_button_no_complete_story_click"))

	cards = [card1, card2, card3, card4, card5, card6, card7, card8, card9, card10, card11, card12, card13, card14, card15, card16, card17, card18, card19, card20]
	# 设置所有cards不可见 并且禁止点击
	for card in cards:
		card.hide()
		card.disable_click()

	current_deal.show()
	finished_stroy_scroll.hide()
	unfinished_story_scroll.hide()


func set_card_info_by_index_with_id(index: int, card_id: int) -> void:
	if index < 0 or index >= cards.size():
		return
	var card = cards[index]
	card.update_card_info_by_id(card_id)
	card.show()


func update_deal_status_by_player(player: Player) -> void:
	update_current_deal_status_by_player(player)
	update_finished_story_by_player(player)
	update_unfinished_story_by_player(player)


func update_current_deal_status_by_player(player: Player) -> void:
	current_player = player
	var deal_cards:Dictionary = player.deal_cards
	var index = 0
	for i in range(deal_cards.size()):
		var card_id = deal_cards.keys()[i]
		set_card_info_by_index_with_id(index, card_id)
		index += 1


## 根据玩家已完成的故事内容更新UI显示
## 为每个已完成的故事创建并添加一个UI_DealStoryStatus实例到垂直容器中
## [param] player: 需要更新UI的玩家实例
func update_finished_story_by_player(player: Player) -> void:
	var finished_stories = player.finished_stories
	for story in finished_stories:
		var story_id = story["ID"]
		# 创建一个UI_DealStoryStatus实例
		var deal_story_status:UI_DealStoryStatus = ui_manager.create_ui_instance_for_multi("UI_DealStoryStatus")
		# 将deal_story_status添加到finished_story_vb
		deal_story_status.name = story["Name"]
		finished_story_vb.add_child(deal_story_status)
		# 传入玩家参数，使其能检查特殊卡
		deal_story_status.update_story_status_by_id(story_id, player)


func update_unfinished_story_by_player(player: Player) -> void:
	# 获取玩家所有手牌的ID
	var deal_cards_id:Array
	current_player = player
	var deal_cards:Dictionary = player.deal_cards
	for i in range(deal_cards.size()):
		var card_id = deal_cards.keys()[i]
		deal_cards_id.append(card_id)
	# 获取所有和这些手牌相关的故事ID
	var stories_id:Array = story_manager.get_relent_stories_id_by_cards_id(deal_cards_id)
	# 从所有故事中去掉已完成的故事
	var finished_stories = player.finished_stories
	for story in finished_stories:
		stories_id.erase(story["ID"])
	# 创建UI_DealStoryStatus实例
	for story_id in stories_id:
		var deal_story_status:UI_DealStoryStatus = ui_manager.create_ui_instance_for_multi("UI_DealStoryStatus")
		deal_story_status.name = story_manager.stories[story_id]["Name"]
		unfinished_story_vb.add_child(deal_story_status)
		# 传入玩家参数，使其能检查特殊卡
		deal_story_status.update_story_status_by_id(story_id, player)
		# 玩家没有的卡牌设置为灰色
		deal_story_status.set_card_color_by_ids(deal_cards_id)


# 显示当前玩家手牌，隐藏已完成故事和未完成故事
func _on_button_current_deal_click():
	current_deal.show()
	finished_stroy_scroll.hide()
	unfinished_story_scroll.hide()


# 显示已完成故事，隐藏当前玩家手牌和未完成故事
func _on_button_finished_story_click():
	current_deal.hide()
	finished_stroy_scroll.show()
	unfinished_story_scroll.hide()


# 显示未完成故事，隐藏当前玩家手牌和已完成故事
func _on_button_no_complete_story_click():
	current_deal.hide()
	finished_stroy_scroll.hide()
	unfinished_story_scroll.show()


func _on_button_back_click():
	ui_manager.destroy_ui("UI_DealStatus")
