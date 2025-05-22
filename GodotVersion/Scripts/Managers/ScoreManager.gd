extends Node

class_name ScoreManager

# 单例模式
static var _instance: ScoreManager = null

# 分数来源类型
enum ScoreSource {
	CARD_SCORE,           # 卡牌基础分数
	SPECIAL_BONUS,        # 特殊卡加成分数
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

# 玩家分数数据
var player_scores: Dictionary = {}  # 玩家当前分数
var score_history: Dictionary = {}  # 玩家分数历史记录

# 信号
signal score_changed(player: Player, old_score: int, new_score: int, change: int)
signal score_added(player: Player, source: ScoreSource, score: int, description: String)

# 获取单例实例
static func get_instance() -> ScoreManager:
	if not _instance:
		_instance = ScoreManager.new()
	return _instance

# 初始化玩家分数
func init_player_score(player: Player) -> void:
	if not player_scores.has(player):
		player_scores[player] = 0
		score_history[player] = []

# 获取玩家分数
func get_player_score(player: Player) -> int:
	if not player_scores.has(player):
		init_player_score(player)
	return player_scores[player]

# 记录分数变化
func _add_score_record(player: Player, source: ScoreSource, score: int, description: String) -> void:
	if not score_history.has(player):
		init_player_score(player)
		
	var record = ScoreRecord.new(source, score, description)
	score_history[player].append(record)
	
	var old_score = player_scores[player]
	player_scores[player] += score
	
	score_changed.emit(player, old_score, player_scores[player], score)
	score_added.emit(player, source, score, description)

# 添加卡牌得分
# 统一处理普通卡和特殊卡的得分逻辑
func add_card_score(player: Player, card: Card) -> void:
	if not player_scores.has(player):
		init_player_score(player)
	
	# 1. 添加卡牌基础分数
	var base_score = card.Score
	if base_score > 0:
		var desc = "使用卡牌 '%s' 获得基础分数" % card.Name
		_add_score_record(player, ScoreSource.CARD_SCORE, base_score, desc)

	# 2. 如果是特殊卡，检查技能表中的加分效果
	if card.Special:
		for i in range(1,card.card_skill_num):
			var skill_type = CardSkill.get_skill_type_by_index(card, i)
			print("特殊卡名称: ", card.Name, " 技能类型: ", CardSkill.skill_type_to_string(skill_type))
			if skill_type == CardSkill.SKILL_TYPE.ADD_SCORE:
				print("特殊卡名称: ", card.Name, " 技能类型: 增加分数")


func add_story_score(player: Player):
	print(player)
	pass

# 重置所有玩家分数
func reset_scores() -> void:
	player_scores.clear()
	score_history.clear()