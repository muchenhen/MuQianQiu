extends Node

class_name StoryManager

static var instance: StoryManager = null

var stories = {}

func _init():
    if instance != null:
        push_error("StoryManager already exists. Use StoryManager.get_instance() instead.")

static func get_instance() -> StoryManager:
    if instance == null:
        instance = StoryManager.new()
    return instance


func init_all_stories_state() -> void:
    var table_manager = TableManager.get_instance()
    table_manager.load_csv("res://Tables/Stories.txt")
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
        var story_cards_id_array = story_cards_id.split(",")
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
