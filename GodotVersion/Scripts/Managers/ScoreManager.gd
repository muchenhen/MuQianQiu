extends Node

class_name ScoreManager

# 单例模式
static var _instance: ScoreManager = null

# 分数来源类型
enum ScoreSource {
	CARD_SCORE,           # 卡牌基础分数
	SPECIAL_BONUS,        # 特殊卡加成分数
}

# 分数效果类型
enum ScoreEffectType {
	SPECIFIC_CARD,        # 特定卡牌加分
	SPECIFIC_STORY,       # 特定故事加分
	MULTI_STORIES,        # 多个故事加分（包含自身）
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

# 分数效果结构
class ScoreEffect:
	var effect_type: ScoreEffectType  # 效果类型
	var target_id                     # 目标ID(可能是卡牌ID或故事ID)，如果是多个故事，则为数组
	var target_name: String           # 目标名称
	var value: float                  # 加分值
	var source_card: Card             # 来源卡牌
	var is_applied: bool = false      # 是否已应用
	
	func _init(type: ScoreEffectType, tid, tname: String, val: float, card: Card):
		effect_type = type
		target_id = tid
		target_name = tname
		value = val
		source_card = card

# 玩家分数数据
var player_scores: Dictionary = {}  # 玩家当前分数
var score_history: Dictionary = {}  # 玩家分数历史记录

var player_score_effect: Dictionary = {}  # 玩家分数特效

# 信号
signal score_changed(player: Player, old_score: int, new_score: int, change: int)

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
		player_score_effect[player] = []

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
		for i in range(1, card.card_skill_num + 1):
			var skill_type = CardSkill.get_skill_type_by_index(card, i)
			if skill_type == CardSkill.SKILL_TYPE.ADD_SCORE:
				# 创建增加分数的效果
				_create_score_effect_from_skill(player, card, i)
				
func add_story_score(player: Player, completed_stories: Array):
	if not player_scores.has(player):
		init_player_score(player)
	
	for story in completed_stories:
		var story_name = story["Name"]
		var story_score = story["Score"]
		
		if story_score > 0:
			var desc = "完成故事 '%s' 获得分数" % story_name
			_add_score_record(player, ScoreSource.SPECIAL_BONUS, story_score, desc)
			
	# 应用所有分数效果（在故事完成后检查是否有针对故事的加分效果）
	apply_score_effects(player)

# 从技能创建分数效果
func _create_score_effect_from_skill(player: Player, card: Card, skill_index: int) -> void:
	var table_manager = TableManager.get_instance()
	var card_skill_row = table_manager.get_row("Skills", card.ID)
	
	if not card_skill_row:
		return
	
	var skill_target_key = "Skill%dTarget" % skill_index
	var skill_target_id_key = "Skill%dTargetID" % skill_index
	var skill_value_key = "Skill%dValue" % skill_index
	
	if not card_skill_row.has(skill_target_key) or not card_skill_row.has(skill_target_id_key):
		return
	
	var target_name = card_skill_row[skill_target_key]
	var target_id = card_skill_row[skill_target_id_key]
	var value = 10.0  # 默认值
	
	if card_skill_row.has(skill_value_key) and card_skill_row[skill_value_key]:
		value = float(card_skill_row[skill_value_key])
	
	var effect_type = ScoreEffectType.SPECIFIC_CARD
	var story_manager = StoryManager.get_instance()
	
	# 根据目标确定效果类型
	if target_name == "包含自身":
		# 包含自身一定是对多个故事加分
		effect_type = ScoreEffectType.MULTI_STORIES
		var card_id = card.BaseID if card.Special else card.ID
		var stories_id = story_manager.get_relent_stories_id_by_cards_id([card_id])
		target_id = stories_id  # 多个故事ID的数组
		target_name = "包含卡牌 '%s' 的故事" % card.Name
	else:
		# 通过查询故事表判断目标是故事还是卡牌
		if story_manager.stories.has(target_id):
			effect_type = ScoreEffectType.SPECIFIC_STORY
			# 获取故事的真实名称
			target_name = story_manager.stories[target_id]["Name"]
		else:
			effect_type = ScoreEffectType.SPECIFIC_CARD
	
	# 创建分数效果
	var effect = ScoreEffect.new(
		effect_type,
		target_id,
		target_name,
		value,
		card
	)
	
	# 添加到玩家的分数效果列表中
	player_score_effect[player].append(effect)

# 应用所有分数效果
func apply_score_effects(player: Player) -> void:
	if not player_score_effect.has(player):
		return
	
	var effects = player_score_effect[player]
	for effect in effects:
		if not effect.is_applied:
			_apply_single_effect(player, effect)
			effect.is_applied = true

# 应用单个分数效果
func _apply_single_effect(player: Player, effect: ScoreEffect) -> void:
	var score_value = int(effect.value)  # 转换为整数
	var description = ""
	
	match effect.effect_type:
		ScoreEffectType.SPECIFIC_CARD:
			description = "卡牌 '%s' 对 '%s' 的加成分数" % [effect.source_card.Name, effect.target_name]
		
		ScoreEffectType.SPECIFIC_STORY:
			description = "卡牌 '%s' 对故事 '%s' 的加成分数" % [effect.source_card.Name, effect.target_name]
		
		ScoreEffectType.MULTI_STORIES:
			description = "卡牌 '%s' 对 %s 的加成分数" % [effect.source_card.Name, effect.target_name]
			
			# 如果是多个故事，需要获取故事详情并加分
			var story_manager = StoryManager.get_instance()
			var stories_id = effect.target_id
			if stories_id is Array and stories_id.size() > 0:
				for story_id in stories_id:
					if story_manager.stories.has(story_id):
						var story = story_manager.stories[story_id]
						var story_name = story["Name"]
						description = "卡牌 '%s' 对故事 '%s' 的加成分数" % [effect.source_card.Name, story_name]
						_add_score_record(player, ScoreSource.SPECIAL_BONUS, score_value, description)
				
				# 提前返回，因为我们已经在循环中添加了所有记录
				return
	
	# 添加分数记录（对于非多故事类型）
	_add_score_record(player, ScoreSource.SPECIAL_BONUS, score_value, description)

# 获取玩家的未应用分数效果
func get_pending_score_effects(player: Player) -> Array:
	if not player_score_effect.has(player):
		return []
	
	var pending_effects = []
	for effect in player_score_effect[player]:
		if not effect.is_applied:
			pending_effects.append(effect)
	
	return pending_effects

# 重置所有玩家分数
func reset_scores() -> void:
	player_scores.clear()
	score_history.clear()
	player_score_effect.clear()