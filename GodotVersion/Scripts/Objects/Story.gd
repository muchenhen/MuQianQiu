extends RefCounted

class_name Story

var id: int  # 故事ID
var name: String  # 故事名称
var cards_name: Array  # 卡牌名称数组
var cards_id: Array  # 卡牌ID数组
var score: int  # 完成故事获得的分数
var audio_id: String  # 故事相关的音频ID
var finished: bool = false  # 故事是否已完成

# 构造函数
func _init(p_id: int, p_name: String, p_cards_name: Array, 
            p_cards_id: Array, p_score: int, p_audio_id: String):
    id = p_id
    name = p_name
    cards_name = p_cards_name
    cards_id = p_cards_id
    score = p_score
    audio_id = p_audio_id

# 标记故事为已完成
func mark_as_finished() -> void:
    finished = true

# 检查故事是否已完成
func is_finished() -> bool:
    return finished
    
# 获取完成故事所需的卡牌数量
func get_required_cards_count() -> int:
    return cards_id.size()
    
# 转为字符串，方便调试
func _to_string() -> String:
    return "Story[id: %s, name: %s, cards: %s, finished: %s]" % [
        id, name, cards_id, finished
    ]	