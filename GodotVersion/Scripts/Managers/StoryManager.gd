extends Node

class_name StoryManager

static var instance: StoryManager = null

var stories = {}
var card_to_story_map = {}
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
		var story_audio_id = story_info["AudioID"]
		stories[story_id] = {
			"ID": story_id,
			"Name": story_name,
			"CardsName": story_cards_name_array,
			"CardsID": story_cards_id_array,
			"Score": story_score,
			"AudioID": story_audio_id,
			"Finished": false
		}
	create_card_to_story_map()

# 创建卡牌ID到故事ID的映射
func create_card_to_story_map():
	for story_id in stories:
		var story = stories[story_id]
		for card_id in story["CardsID"]:
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
			if stories_id.find(story["ID"]) == -1:
				stories_id.append(story["ID"])
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
func check_story_finish_by_cards_id(cards_id:Array) -> Array:
	if DEBUG_SKIP_STORTY:
		return []
	# print("检查故事完成情况", cards_id)
	var this_time_completed_stories = []
	for story_id in stories:
		var story = stories[story_id]
		# print("准备检查故事 ", story["Name"])
		if story["Finished"]:
			# print(story["Name"], "故事已完成，跳过")
			continue
		var story_cards_id = story["CardsID"]
		# print(story["Name"], "故事所需卡牌ID: ", story_cards_id)
		var finished = true
		for card_id in story_cards_id:
			if cards_id.find(card_id) == -1:
				finished = false
				# print("玩家牌堆中没有卡牌 ", card_id, " 无法完成故事 ", story["Name"])
				break
		if finished:
			story["Finished"] = true
			print(story["Name"], "故事完成")
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
