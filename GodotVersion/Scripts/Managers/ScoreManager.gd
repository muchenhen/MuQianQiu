extends Node

class_name ScoreManager

# 单例模式
static var _instance: ScoreManager = null

# 玩家枚举
enum Player {
	PLAYER1,
	PLAYER2
}

# 分数来源类型
enum ScoreSource {
	CARD_SCORE,           # 卡牌基础分数
	STORY_SCORE,          # 故事完成分数
	SPECIAL_STORY_BONUS,  # 特殊卡对故事的加成
	SPECIAL_CARD_BONUS,   # 特殊卡对卡牌的加成
	SPECIAL_SELF_BONUS    # 特殊卡对包含自身的故事加成
}

# 分数记录结构
class ScoreRecord:
	var timestamp: float        # 时间戳
	var source: ScoreSource     # 分数来源
	var score: int             # 获得的分数
	var description: String    # 描述信息
	
	func _init(src: ScoreSource, sc: int, desc: String):
		timestamp = Time.get_unix_time_from_system()
		source = src
		score = sc
		description = desc

# 玩家数据
var player_scores: Array[int] = [0, 0]  # 玩家当前分数
var score_history: Array[Array] = [[], []]  # 玩家分数历史记录

# 信号
signal score_changed(player: Player, old_score: int, new_score: int, change: int)
signal score_added(player: Player, source: ScoreSource, score: int, description: String)

# 获取单例实例
static func get_instance() -> ScoreManager:
	if not _instance:
		_instance = ScoreManager.new()
	return _instance

# 初始化
func reset_scores() -> void:
	player_scores = [0, 0]
	score_history = [[], []]

# 获取玩家分数
func get_player_score(player: Player) -> int:
	return player_scores[player]

# 记录分数变化
func _add_score_record(player: Player, source: ScoreSource, score: int, description: String) -> void:
	var record = ScoreRecord.new(source, score, description)
	score_history[player].append(record)
	
	var old_score = player_scores[player]
	player_scores[player] += score
	
	score_changed.emit(player, old_score, player_scores[player], score)
	score_added.emit(player, source, score, description)

# 添加卡牌基础分数
func add_card_score(player: Player, card: Card) -> void:
	var score = card.Score
	if score > 0:
		var desc = "使用卡牌 '%s' 获得基础分数" % card.Name
		_add_score_record(player, ScoreSource.CARD_SCORE, score, desc)

# 添加故事完成分数
func add_story_score(player: Player, story_name: String, score: int) -> void:
	if score > 0:
		var desc = "完成故事 '%s' 获得分数" % story_name
		_add_score_record(player, ScoreSource.STORY_SCORE, score, desc)

# 添加特殊卡对故事的加成分数
func add_special_story_bonus(player: Player, card: Card, story_name: String, bonus: int) -> void:
	if not card.Special:
		return
		
	if bonus > 0:
		var desc = "特殊卡 '%s' 对故事 '%s' 的加成" % [card.Name, story_name]
		_add_score_record(player, ScoreSource.SPECIAL_STORY_BONUS, bonus, desc)

# 添加特殊卡对卡牌的加成分数
func add_special_card_bonus(player: Player, special_card: Card, target_card: Card, bonus: int) -> void:
	if not special_card.Special:
		return
		
	if bonus > 0:
		var desc = "特殊卡 '%s' 对卡牌 '%s' 的加成" % [special_card.Name, target_card.Name]
		_add_score_record(player, ScoreSource.SPECIAL_CARD_BONUS, bonus, desc)

# 添加特殊卡对包含自身的故事的加成分数
func add_special_self_bonus(player: Player, card: Card, story_name: String, bonus: int) -> void:
	if not card.Special:
		return
		
	if bonus > 0:
		var desc = "特殊卡 '%s' 对包含自身的故事 '%s' 的加成" % [card.Name, story_name]
		_add_score_record(player, ScoreSource.SPECIAL_SELF_BONUS, bonus, desc)

# 获取玩家的分数历史记录
func get_score_history(player: Player) -> Array:
	return score_history[player]

# 获取玩家指定类型的分数总和
func get_source_total(player: Player, source: ScoreSource) -> int:
	var total = 0
	for record in score_history[player]:
		if record.source == source:
			total += record.score
	return total