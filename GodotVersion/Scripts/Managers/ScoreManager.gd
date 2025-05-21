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
		var skills = _get_card_skills(card.ID)
		if skills != null:
			_apply_skill_bonus(player, card, skills)

# 从技能表获取卡牌的技能数据
func _get_card_skills(card_id: int) -> Dictionary:
	var skills_table = TableManager.get_instance().get_all_rows("Skills")
	for skill_id in skills_table:
		var skill = skills_table[skill_id]
		if skill["CardID"] == card_id:
			return skill
	return {}

# 检查是否应该应用特定的技能加成
func _should_apply_special_bonus(special_card: Card, target_card: Card, target_id: int) -> bool:
	if not special_card.Special:
		return false
		
	# 特殊卡不能对自己加成
	if special_card.ID == target_card.ID:
		return false
		
	# 检查目标卡是否匹配指定的目标ID
	if target_id > 0:
		return target_card.ID == target_id or target_card.BaseID == target_id
	
	return false

# 应用技能加成
func _apply_skill_bonus(player: Player, special_card: Card, skills: Dictionary) -> void:
	# 检查两个技能槽位
	for i in range(1, 3):
		var skill_type = skills.get("Skill%dType" % i, "")
		if skill_type != "增加分数":
			continue
			
		var target = skills.get("Skill%dTarget" % i, "")
		var target_id = skills.get("Skill%dTargetID" % i, 0)
		var value = float(skills.get("Skill%dValue" % i, 0))
		
		# 特殊处理"包含自身"的情况
		if target == "包含自身":
			_apply_self_contained_bonus(player, special_card, value)
			continue
		
		# 处理针对特定卡牌或故事的加成
		var deal_cards = player.deal_cards
		for target_card_id in deal_cards:
			var target_card = deal_cards[target_card_id]
			if _should_apply_special_bonus(special_card, target_card, target_id):
				var bonus_score = int(value)
				if bonus_score > 0:
					var desc = "特殊卡 '%s' 对卡牌 '%s' 的加成" % [special_card.Name, target_card.Name]
					_add_score_record(player, ScoreSource.SPECIAL_BONUS, bonus_score, desc)

# 应用"包含自身"的加成
func _apply_self_contained_bonus(player: Player, special_card: Card, bonus_value: float) -> void:
	# 获取包含此卡的所有故事
	var story_manager = StoryManager.get_instance()
	var relevant_stories = story_manager.get_relent_stories(special_card.ID)
	
	# 对于每个包含此卡的未完成故事，应用加成
	for story in relevant_stories:
		if not story["Finished"]:
			var desc = "特殊卡 '%s' 对包含自身的故事 '%s' 的加成" % [special_card.Name, story["Name"]]
			var bonus_score = int(bonus_value)
			_add_score_record(player, ScoreSource.SPECIAL_BONUS, bonus_score, desc)

# 获取玩家的分数历史记录
func get_score_history(player: Player) -> Array:
	if not score_history.has(player):
		init_player_score(player)
	return score_history[player]

# 获取玩家指定类型的分数总和
func get_source_total(player: Player, source: ScoreSource) -> int:
	if not score_history.has(player):
		init_player_score(player)
		
	var total = 0
	for record in score_history[player]:
		if record.source == source:
			total += record.score
	return total

# 重置所有玩家分数
func reset_scores() -> void:
	player_scores.clear()
	score_history.clear()