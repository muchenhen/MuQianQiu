extends Node


class_name ScoreManager

# 单例模式
static var _instance: ScoreManager = null

# 分数来源类型
enum ScoreSource {
	CARD_SCORE, # 卡牌基础分数
	STORY_SCORE, # 故事组合分数
	SKILL_BONUS, # 技能加分效果
	SPECIAL_BONUS, # 特殊卡加成分数（兼容旧代码）
}

# 分数操作类型
enum ScoreOperationType {
	ADD, # 加分
	REVOKE, # 撤销/扣分
}

# 分数效果类型
enum ScoreEffectType {
	SPECIFIC_CARD, # 特定卡牌加分
	SPECIFIC_STORY, # 特定故事加分
	MULTI_STORIES, # 多个故事加分（包含自身）
}

# 分数记录结构
class ScoreRecord:
	var timestamp: float # 时间戳
	var source: ScoreSource # 分数来源
	var score: int # 获得的分数
	var description: String # 描述信息
	
	func _init(src: ScoreSource, sc: int, desc: String):
		timestamp = Time.get_unix_time_from_system()
		source = src
		score = sc
		description = desc

# 分数操作日志（用于交换卡牌等场景的详细记录）
class ScoreOperationLog:
	var operation_type: ScoreOperationType # 操作类型
	var source: ScoreSource # 分数来源
	var score: int # 分数值（正数）
	var description: String # 描述
	var related_card_id: int = -1 # 相关卡牌ID
	var related_story_id: int = -1 # 相关故事ID
	var timestamp: float # 时间戳
	
	func _init(op_type: ScoreOperationType, src: ScoreSource, sc: int, desc: String):
		operation_type = op_type
		source = src
		score = sc
		description = desc
		timestamp = Time.get_unix_time_from_system()

# 分数效果结构
class ScoreEffect:
	var effect_type: ScoreEffectType # 效果类型
	var target_ids: Array # 目标ID数组(可能是卡牌ID或故事ID)
	var target_name: String # 目标名称描述
	var value: float # 加分值
	var source_card: Card # 来源卡牌
	var source_card_id: int # 来源卡牌ID（用于效果转移后追踪）
	var is_applied: bool = false # 整个效果是否已应用完成
	var applied_targets: Dictionary = {} # 记录每个目标是否已应用 {target_id: bool}
	var applied_scores: Dictionary = {} # 记录每个目标已获得的分数 {target_id: int}
	
	func _init(type: ScoreEffectType, tid, tname: String, val: float, card: Card):
		effect_type = type
		# 确保 target_ids 始终是数组
		if tid is Array:
			target_ids = tid
		else:
			target_ids = [tid]
		target_name = tname
		value = val
		source_card = card
		source_card_id = card.ID if card else -1
		
		# 初始化所有目标为未应用
		for target_id in target_ids:
			applied_targets[target_id] = false
			applied_scores[target_id] = 0

# 玩家分数数据
var player_scores: Dictionary = {} # 玩家当前分数
var score_history: Dictionary = {} # 玩家分数历史记录

var player_score_effect: Dictionary = {} # 玩家分数特效

# 交换操作日志（临时存储，用于UI展示）
var exchange_operation_logs: Dictionary = {} # {player: Array[ScoreOperationLog]}

# 信号
signal score_changed(player: Player, old_score: int, new_score: int, change: int, description: String)
signal score_skill_event(event: Dictionary)

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

# 获取玩家分数历史记录
func get_player_score_history(player: Player) -> Array:
	if not score_history.has(player):
		init_player_score(player)
	return score_history[player].duplicate()

# 记录分数变化
func _add_score_record(player: Player, source: ScoreSource, score: int, description: String) -> void:
	if not score_history.has(player):
		init_player_score(player)
		
	var record = ScoreRecord.new(source, score, description)
	score_history[player].append(record)
	
	var old_score = player_scores[player]
	player_scores[player] += score
	
	score_changed.emit(player, old_score, player_scores[player], score, description)

# 添加卡牌得分
# 统一处理普通卡和珍稀牌的得分逻辑
func add_card_score(player: Player, card: Card) -> void:
	if not player_scores.has(player):
		init_player_score(player)
	add_base_card_score(player, card)
	if card.Special:
		for i in range(1, card.card_skill_num + 1):
			var skill_type = CardSkill.get_skill_type_by_index(card, i)
			if skill_type == CardSkill.SKILL_TYPE.ADD_SCORE:
				register_add_score_effect_for_skill(player, card, i)

func add_base_card_score(player: Player, card: Card) -> void:
	if not player_scores.has(player):
		init_player_score(player)

	var base_score = card.Score
	if base_score > 0:
		var desc = "使用卡牌 '%s' 获得基础分数" % card.Name
		_add_score_record(player, ScoreSource.CARD_SCORE, base_score, desc)
		# 如果在交换日志记录期间，添加日志
		_add_exchange_log(player, ScoreOperationType.ADD, ScoreSource.CARD_SCORE, base_score, "交换获得卡牌 '%s' +%d" % [card.Name, base_score], card.ID)

func register_add_score_effect_for_skill(player: Player, card: Card, skill_index: int) -> void:
	_create_score_effect_from_skill(player, card, skill_index)
				
# 计算单个故事的分数（不应用分数效果）
# 返回该故事的分数值
func add_single_story_score(player: Player, story: Story) -> int:
	if not player_scores.has(player):
		init_player_score(player)
	
	var story_score = story.score
	
	if story_score > 0:
		var desc = "完成故事 '%s' 获得分数" % story.name
		_add_score_record(player, ScoreSource.SPECIAL_BONUS, story_score, desc)
		# 如果在交换日志记录期间，添加日志
		_add_exchange_log(player, ScoreOperationType.ADD, ScoreSource.STORY_SCORE, story_score, "交换后新完成故事 '%s' +%d" % [story.name, story_score], -1, story.id)
	
	return story_score

# 批量添加故事分数（一次性计算所有故事）
func add_story_score(player: Player, completed_stories: Array[Story]) -> void:
	if not player_scores.has(player):
		init_player_score(player)
	
	for story in completed_stories:
		var story_name = story.name
		var story_score = story.score
		
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
	var skill_target_type_key = "Skill%dTargetType" % skill_index

	if not card_skill_row.has(skill_target_key) or not card_skill_row.has(skill_target_id_key):
		return

	var target_name = card_skill_row[skill_target_key]
	var target_id = card_skill_row[skill_target_id_key]
	var value = 10.0 # 默认值
	
	if card_skill_row.has(skill_value_key) and card_skill_row[skill_value_key]:
		value = float(card_skill_row[skill_value_key])
	
	var explicit_target_type := ""
	if card_skill_row.has(skill_target_type_key):
		explicit_target_type = str(card_skill_row[skill_target_type_key]).strip_edges().to_upper()

	var effect_type = ScoreEffectType.SPECIFIC_CARD
	if explicit_target_type != "":
		match explicit_target_type:
			"CARD":
				effect_type = ScoreEffectType.SPECIFIC_CARD
			"STORY":
				effect_type = ScoreEffectType.SPECIFIC_STORY
				if StoryManager.get_instance().stories.has(target_id):
					var target_story: Story = StoryManager.get_instance().stories[target_id]
					target_name = target_story.name
			"STORIES":
				effect_type = ScoreEffectType.MULTI_STORIES
				if target_name == "包含自身":
					var card_id = card.BaseID if card.Special else card.ID
					var stories_ids = StoryManager.get_instance().get_relent_stories_id_by_cards_id([card_id])
					target_id = stories_ids
					target_name = "包含卡牌 '%s' 的故事" % card.Name
				elif target_id is String:
					target_id = _parse_target_ids(str(target_id))
			_:
				push_warning("ScoreManager: 未知 TargetType='%s'，回退到旧逻辑。" % explicit_target_type)
				effect_type = _infer_legacy_effect_type(card, target_name, target_id)
				if effect_type == ScoreEffectType.MULTI_STORIES:
					var card_id2 = card.BaseID if card.Special else card.ID
					var stories_ids2 = StoryManager.get_instance().get_relent_stories_id_by_cards_id([card_id2])
					target_id = stories_ids2
					target_name = "包含卡牌 '%s' 的故事" % card.Name
				elif effect_type == ScoreEffectType.SPECIFIC_STORY and StoryManager.get_instance().stories.has(target_id):
					var target_story2: Story = StoryManager.get_instance().stories[target_id]
					target_name = target_story2.name
	else:
		# 兼容旧表：缺少 TargetType 时沿用旧推断并给出警告
		push_warning("ScoreManager: CardID=%d Skill%d 缺少 TargetType，使用旧推断逻辑。" % [card.ID, skill_index])
		effect_type = _infer_legacy_effect_type(card, target_name, target_id)
		if effect_type == ScoreEffectType.MULTI_STORIES:
			var card_id3 = card.BaseID if card.Special else card.ID
			var stories_ids3 = StoryManager.get_instance().get_relent_stories_id_by_cards_id([card_id3])
			target_id = stories_ids3
			target_name = "包含卡牌 '%s' 的故事" % card.Name
		elif effect_type == ScoreEffectType.SPECIFIC_STORY and StoryManager.get_instance().stories.has(target_id):
			var target_story3: Story = StoryManager.get_instance().stories[target_id]
			target_name = target_story3.name

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

	var event_payload = {
		"player": player,
		"source_card_id": card.ID,
		"source_card_name": card.Name,
		"skill_code": "ADD_SCORE",
		"skill_name": "增加分数",
		"stage": "REGISTER",
		"target_name": target_name,
		"target_type": explicit_target_type if explicit_target_type != "" else convert_effect_type_to_string(effect_type),
		"value": int(value),
		"result_text": "已登记加分效果（满足条件时发动）",
	}
	score_skill_event.emit(event_payload)

func _infer_legacy_effect_type(_card: Card, target_name, target_id) -> ScoreEffectType:
	if target_name == "包含自身":
		return ScoreEffectType.MULTI_STORIES
	if StoryManager.get_instance().stories.has(target_id):
		return ScoreEffectType.SPECIFIC_STORY
	return ScoreEffectType.SPECIFIC_CARD

func _parse_target_ids(raw_value: String) -> Array[int]:
	var raw = raw_value.strip_edges()
	if raw == "":
		return []
	raw = raw.replace("(", "")
	raw = raw.replace(")", "")
	raw = raw.replace(";", ",")
	var ids: Array[int] = []
	for token in raw.split(","):
		var t = token.strip_edges()
		if t.is_valid_int():
			ids.append(t.to_int())
	return ids

static func convert_effect_type_to_string(effect_type: ScoreEffectType) -> String:
	match effect_type:
		ScoreEffectType.SPECIFIC_CARD:
			return "SPECIFIC_CARD"
		ScoreEffectType.SPECIFIC_STORY:
			return "SPECIFIC_STORY"
		ScoreEffectType.MULTI_STORIES:
			return "MULTI_STORIES"
	
	return "UNKNOWN_EFFECT_TYPE"

# 应用所有分数效果
func apply_score_effects(player: Player) -> void:
	if not player_score_effect.has(player):
		return
	
	var effects = player_score_effect[player]
	for effect in effects:
		if effect.is_applied:
			continue
		print(player.name, "已准备的应用分数效果：", convert_effect_type_to_string(effect.effect_type), " ", effect.target_ids)
		if effect.effect_type == ScoreEffectType.SPECIFIC_CARD:
			# 对玩家的特定卡牌加分，需要检查玩家当前牌堆中是否有该卡牌
			for target_id in effect.target_ids:
				if effect.applied_targets[target_id]:
					continue
					
				if player.chenk_card_in_deal(target_id):
					# 记录此目标已应用
					effect.applied_targets[target_id] = true
					_apply_single_effect(player, effect, target_id)
			
			# 检查是否所有目标都已应用
			var all_applied = true
			for target_id in effect.target_ids:
				if not effect.applied_targets[target_id]:
					all_applied = false
					break
			
			effect.is_applied = all_applied

		elif effect.effect_type == ScoreEffectType.SPECIFIC_STORY:
			# 特定故事加分,需要检查玩家是否完成了该故事
			for target_id in effect.target_ids:
				if effect.applied_targets[target_id]:
					continue
					
				if player.check_story_in_finished_stories(target_id):
					# 记录此目标已应用
					effect.applied_targets[target_id] = true
					_apply_single_effect(player, effect, target_id)
			
			# 检查是否所有目标都已应用
			var all_applied = true
			for target_id in effect.target_ids:
				if not effect.applied_targets[target_id]:
					all_applied = false
					break
			
			effect.is_applied = all_applied
		elif effect.effect_type == ScoreEffectType.MULTI_STORIES:
			# 多个故事加分，需要检查每个故事是否完成
			var all_applied = true
			
			for target_id in effect.target_ids:
				if effect.applied_targets[target_id]:
					continue
					
				if player.check_story_in_finished_stories(target_id):
					# 记录此目标已应用
					effect.applied_targets[target_id] = true
					_apply_single_effect(player, effect, target_id)
				else:
					all_applied = false
			
			effect.is_applied = all_applied

# 应用单个分数效果
func _apply_single_effect(player: Player, effect: ScoreEffect, target_id = null) -> void:
	var score_value = int(effect.value) # 转换为整数
	var description = ""
	
	# 确定用于记录的target_id
	var record_target_id = target_id
	if record_target_id == null and effect.target_ids.size() > 0:
		record_target_id = effect.target_ids[0]
	
	match effect.effect_type:
		ScoreEffectType.SPECIFIC_CARD:
			description = "卡牌 '%s' 对 '%s' 的加成分数" % [effect.source_card.Name, effect.target_name]
			_add_score_record(player, ScoreSource.SKILL_BONUS, score_value, description)
			# 记录已应用的分数
			if record_target_id != null:
				effect.applied_scores[record_target_id] = score_value
			score_skill_event.emit({
				"player": player,
				"source_card_id": effect.source_card.ID,
				"source_card_name": effect.source_card.Name,
				"skill_code": "ADD_SCORE",
				"skill_name": "增加分数",
				"stage": "TRIGGER",
				"target_name": effect.target_name,
				"value": score_value,
				"result_text": "对目标卡牌加分生效: +%d" % score_value,
			})
		
		ScoreEffectType.SPECIFIC_STORY:
			description = "卡牌 '%s' 对故事 '%s' 的加成分数" % [effect.source_card.Name, effect.target_name]
			_add_score_record(player, ScoreSource.SKILL_BONUS, score_value, description)
			# 记录已应用的分数
			if record_target_id != null:
				effect.applied_scores[record_target_id] = score_value
			score_skill_event.emit({
				"player": player,
				"source_card_id": effect.source_card.ID,
				"source_card_name": effect.source_card.Name,
				"skill_code": "ADD_SCORE",
				"skill_name": "增加分数",
				"stage": "TRIGGER",
				"target_name": effect.target_name,
				"value": score_value,
				"result_text": "对目标故事加分生效: +%d" % score_value,
			})
		
		ScoreEffectType.MULTI_STORIES:
			# 对指定的单个故事加分
			if target_id != null and StoryManager.get_instance().stories.has(target_id):
				var story = StoryManager.get_instance().stories[target_id]
				var story_name = story.name
				description = "卡牌 '%s' 对故事 '%s' 的加成分数" % [effect.source_card.Name, story_name]
				_add_score_record(player, ScoreSource.SKILL_BONUS, score_value, description)
				# 记录已应用的分数
				effect.applied_scores[target_id] = score_value
				score_skill_event.emit({
					"player": player,
					"source_card_id": effect.source_card.ID,
					"source_card_name": effect.source_card.Name,
					"skill_code": "ADD_SCORE",
					"skill_name": "增加分数",
					"stage": "TRIGGER",
					"target_name": story_name,
					"value": score_value,
					"result_text": "对目标故事加分生效: +%d" % score_value,
				})

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
	exchange_operation_logs.clear()

# ============== 交换卡牌相关的分数撤销和转移功能 ==============

## 开始记录交换操作日志
func begin_exchange_logging(player_a: Player, player_b: Player) -> void:
	exchange_operation_logs[player_a] = []
	exchange_operation_logs[player_b] = []

## 结束交换操作日志记录，返回日志数据
func end_exchange_logging() -> Dictionary:
	var logs = exchange_operation_logs.duplicate()
	exchange_operation_logs.clear()
	return logs

## 添加交换操作日志
func _add_exchange_log(player: Player, op_type: ScoreOperationType, source: ScoreSource, score: int, desc: String, card_id: int = -1, story_id: int = -1) -> void:
	if not exchange_operation_logs.has(player):
		return
	var op_log = ScoreOperationLog.new(op_type, source, score, desc)
	op_log.related_card_id = card_id
	op_log.related_story_id = story_id
	exchange_operation_logs[player].append(op_log)

## 撤销卡牌基础分数
func revoke_card_score(player: Player, card: Card) -> int:
	if card == null or not player_scores.has(player):
		return 0
	
	var base_score = card.Score
	if base_score <= 0:
		return 0
	
	var desc = "交换失去卡牌 '%s' 撤销基础分数" % card.Name
	var old_score = player_scores[player]
	player_scores[player] -= base_score
	
	var record = ScoreRecord.new(ScoreSource.CARD_SCORE, -base_score, desc)
	score_history[player].append(record)
	score_changed.emit(player, old_score, player_scores[player], -base_score, desc)
	
	_add_exchange_log(player, ScoreOperationType.REVOKE, ScoreSource.CARD_SCORE, base_score, desc, card.ID)
	
	return base_score

## 撤销故事分数
func revoke_story_score(player: Player, story: Story) -> int:
	if story == null or not player_scores.has(player):
		return 0
	
	var story_score = story.score
	if story_score <= 0:
		return 0
	
	var desc = "交换导致故事 '%s' 失效，撤销故事分数" % story.name
	var old_score = player_scores[player]
	player_scores[player] -= story_score
	
	var record = ScoreRecord.new(ScoreSource.STORY_SCORE, -story_score, desc)
	score_history[player].append(record)
	score_changed.emit(player, old_score, player_scores[player], -story_score, desc)
	
	_add_exchange_log(player, ScoreOperationType.REVOKE, ScoreSource.STORY_SCORE, story_score, desc, -1, story.id)
	
	return story_score

## 撤销技能加分效果（当来源卡或目标卡被换走时）
## 返回撤销的总分数
func revoke_score_effects_for_card(player: Player, card: Card) -> int:
	if card == null or not player_score_effect.has(player):
		return 0
	
	var total_revoked := 0
	var card_id = card.BaseID if card.Special else card.ID
	var effects_to_remove: Array = []
	
	for effect in player_score_effect[player]:
		var should_revoke = false
		var revoke_reason = ""
		
		# 检查是否是来源卡被换走
		if effect.source_card != null and effect.source_card == card:
			should_revoke = true
			revoke_reason = "来源卡 '%s' 被换走" % card.Name
		# 检查是否是目标卡被换走（针对SPECIFIC_CARD类型）
		elif effect.effect_type == ScoreEffectType.SPECIFIC_CARD:
			if effect.target_ids.has(card_id):
				should_revoke = true
				revoke_reason = "目标卡 '%s' 被换走" % card.Name
		
		if should_revoke:
			# 撤销已应用的分数
			for target_id in effect.applied_targets.keys():
				if effect.applied_targets[target_id] and effect.applied_scores.has(target_id):
					var revoked_score = effect.applied_scores[target_id]
					if revoked_score > 0:
						var desc = "技能效果撤销（%s）: -%d" % [revoke_reason, revoked_score]
						var old_score = player_scores[player]
						player_scores[player] -= revoked_score
						
						var record = ScoreRecord.new(ScoreSource.SKILL_BONUS, -revoked_score, desc)
						score_history[player].append(record)
						score_changed.emit(player, old_score, player_scores[player], -revoked_score, desc)
						
						_add_exchange_log(player, ScoreOperationType.REVOKE, ScoreSource.SKILL_BONUS, revoked_score, desc, card.ID)
						
						total_revoked += revoked_score
			
			effects_to_remove.append(effect)
	
	# 移除被撤销的效果
	for effect in effects_to_remove:
		var idx = player_score_effect[player].find(effect)
		if idx != -1:
			player_score_effect[player].remove_at(idx)
	
	return total_revoked

## 检查并撤销因故事失效而失效的技能加分
func revoke_score_effects_for_story(player: Player, story: Story) -> int:
	if story == null or not player_score_effect.has(player):
		return 0
	
	var total_revoked := 0
	var story_id = story.id
	
	for effect in player_score_effect[player]:
		if effect.effect_type == ScoreEffectType.SPECIFIC_STORY or effect.effect_type == ScoreEffectType.MULTI_STORIES:
			if effect.target_ids.has(story_id) and effect.applied_targets.get(story_id, false):
				var revoked_score = effect.applied_scores.get(story_id, 0)
				if revoked_score > 0:
					var desc = "故事 '%s' 失效，技能加分撤销: -%d" % [story.name, revoked_score]
					var old_score = player_scores[player]
					player_scores[player] -= revoked_score
					
					var record = ScoreRecord.new(ScoreSource.SKILL_BONUS, -revoked_score, desc)
					score_history[player].append(record)
					score_changed.emit(player, old_score, player_scores[player], -revoked_score, desc)
					
					_add_exchange_log(player, ScoreOperationType.REVOKE, ScoreSource.SKILL_BONUS, revoked_score, desc, -1, story_id)
					
					# 重置该目标的应用状态
					effect.applied_targets[story_id] = false
					effect.applied_scores[story_id] = 0
					effect.is_applied = false
					
					total_revoked += revoked_score
	
	return total_revoked

## 转移技能效果到新玩家（当卡牌被交换时）
## 将来源卡的效果从旧玩家转移到新玩家
func transfer_score_effects(from_player: Player, to_player: Player, card: Card) -> void:
	if card == null:
		return
	if not player_score_effect.has(from_player):
		return
	if not player_score_effect.has(to_player):
		init_player_score(to_player)
	
	var effects_to_transfer: Array = []
	
	for effect in player_score_effect[from_player]:
		if effect.source_card != null and effect.source_card == card:
			effects_to_transfer.append(effect)
	
	# 移除并转移效果
	for effect in effects_to_transfer:
		var idx = player_score_effect[from_player].find(effect)
		if idx != -1:
			player_score_effect[from_player].remove_at(idx)
		
		# 重置效果状态
		effect.is_applied = false
		for target_id in effect.applied_targets.keys():
			effect.applied_targets[target_id] = false
			effect.applied_scores[target_id] = 0
		
		# 添加到新玩家
		player_score_effect[to_player].append(effect)
		
		print("技能效果转移: %s 的效果从 %s 转移到 %s" % [card.Name, from_player.name, to_player.name])

## 为新获得的卡牌重新应用技能效果
func reapply_score_effects_for_new_card(player: Player, card: Card) -> void:
	if card == null or not card.Special:
		return
	
	# 为新卡牌注册加分效果
	for i in range(1, card.card_skill_num + 1):
		var skill_type = CardSkill.get_skill_type_by_index(card, i)
		if skill_type == CardSkill.SKILL_TYPE.ADD_SCORE:
			register_add_score_effect_for_skill(player, card, i)
	
	# 立即尝试应用效果
	apply_score_effects(player)
