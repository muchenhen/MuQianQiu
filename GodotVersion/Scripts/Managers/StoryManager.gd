extends Node

class_name StoryManager

static var instance: StoryManager = null



# 存储所有故事，key为故事ID，value为Story对象
var stories:Dictionary[int, Story] = {}
# 卡牌ID到故事ID的映射
var card_to_story_map = {}
# 已完成的故事列表
var completed_stories = []

var DEBUG_SKIP_STORTY = false

func _init():
	if instance != null:
		push_error("StoryManager already exists. Use StoryManager.get_instance() instead.")

static func get_instance() -> StoryManager:
	if instance == null:
		instance = StoryManager.new()
		instance.initialize()
	return instance

# 初始化故事管理器
func initialize() -> void:
	var table_manager = TableManager.get_instance()
	var stories_table = table_manager.tables["Stories"]
	for story_id in stories_table.keys():
		var story_info = stories_table[story_id]
		var story_name = story_info["Name"]
		var story_cards_name = story_info["CardsName"]
		story_cards_name = story_cards_name.replace("(","")
		story_cards_name = story_cards_name.replace(")","")
		var story_cards_name_array = story_cards_name.split(",")
		var story_cards_id = story_info["CardsID"]
		story_cards_id = story_cards_id.replace("(","")
		story_cards_id = story_cards_id.replace(")","")
		var story_cards_id_array_str = story_cards_id.split(",")
		var story_cards_id_array = []
		for card_id_str in story_cards_id_array_str:
			story_cards_id_array.append(int(card_id_str))
		var story_score = story_info["Score"]
		var story_audio_id = str(story_info["AudioID"])  # 确保AudioID为字符串类型
		
		# 创建新的Story对象，直接使用Story类而不是StoryClass
		var story = Story.new(
			story_id,
			story_name,
			story_cards_name_array,
			story_cards_id_array,
			story_score,
			story_audio_id
		)
		
		stories[story_id] = story
	create_card_to_story_map()

# 创建卡牌ID到故事ID的映射
func create_card_to_story_map():
	for story_id in stories:
		var story = stories[story_id]
		for card_id in story.cards_id:
			if card_id not in card_to_story_map:
				card_to_story_map[card_id] = []
			card_to_story_map[card_id].append(story_id)

# 获取与卡牌ID相关的故事
func get_relent_stories(card_id:int) -> Array:
	if card_id not in card_to_story_map:
		return []
	var stories_id = card_to_story_map[card_id]
	var relent_stories = []
	for story_id in stories_id:
		relent_stories.append(stories[story_id])
	return relent_stories

# 通过卡牌ID数组，获取与这些卡牌相关的故事，返回去重后的故事ID数组
func get_relent_stories_id_by_cards_id(cards_id:Array) -> Array:
	var stories_id = []
	for card_id in cards_id:
		var card_relent_stories = get_relent_stories(card_id)
		for story in card_relent_stories:
			if stories_id.find(story.id) == -1:
				stories_id.append(story.id)
	return stories_id

# 通过卡牌ID数组，获取与这些卡牌相关的故事，返回去重后的故事结构所组成的数组
func get_relent_stories_by_cards_id(cards_id:Array) -> Array:
	var relent_stories = []
	for card_id in cards_id:
		var card_relent_stories = get_relent_stories(card_id)
		for story in card_relent_stories:
			if relent_stories.find(story) == -1:
				relent_stories.append(story)
	return relent_stories

# 检查玩家是否完成了某个故事
# 直接使用玩家牌堆数组
func check_story_finish_for_player(player:Player) -> Array[Story]:
	if DEBUG_SKIP_STORTY:
		return []
	var cards:Array[Card] = player.deal_cards.values()
	var this_time_completed_stories:Array[Story] = []
	var cards_id = []
	
	# 获取玩家所有卡牌ID
	for card in cards:
		if card.Special:
			cards_id.append(card.BaseID)
		else:
			cards_id.append(card.ID)
			
	# 检查每个故事是否完成
	for story_id in stories:
		var story = stories[story_id]
		if story.is_finished():
			continue
			
		var all_cards_present = true
		for card_id in story.cards_id:
			if cards_id.find(card_id) == -1:
				all_cards_present = false
				break
				
		if all_cards_present:
			story.mark_as_finished()
			print(story.name, "故事完成")
			completed_stories.append(story)
			this_time_completed_stories.append(story)
			
	return this_time_completed_stories

# 清理所有状态 准备下一轮游戏
func clear():
	stories.clear()
	card_to_story_map.clear()
	completed_stories.clear()
	instance = null
	queue_free()
