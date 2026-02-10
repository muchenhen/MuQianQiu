extends RefCounted

class_name SkillResolver
const SkillCastEventScript = preload("res://Scripts/Core/Skill/SkillCastEvent.gd")
const STAGE_REGISTER = SkillCastEventScript.Stage.REGISTER
const STAGE_CHECK = SkillCastEventScript.Stage.CHECK
const STAGE_TRIGGER = SkillCastEventScript.Stage.TRIGGER
const STAGE_FAILED = SkillCastEventScript.Stage.FAILED
const STAGE_WAIVED = SkillCastEventScript.Stage.WAIVED
const STAGE_INVALID = SkillCastEventScript.Stage.INVALID

const DISABLE_MODE_FIXED_SINGLE := "FIXED_SINGLE"
const DISABLE_MODE_FIXED_GROUP := "FIXED_GROUP"
const DISABLE_MODE_PICK_OPPONENT_SPECIAL := "PICK_OPPONENT_SPECIAL"
const DISABLE_SCOPE_ALL_SKILLS := "ALL_SKILLS"

enum SkillUseState {
	READY,
	USED,
	WAIVED,
	DISABLED
}

var match_state: MatchState = null
var table_manager: TableManager = TableManager.get_instance()
var skill_queue: SkillQueue = SkillQueue.new()
var skill_states: Dictionary = {}
var disable_watchers: Array[Dictionary] = []
var disable_scope_registry: Dictionary = {}
var rng := RandomNumberGenerator.new()
var prompt_callback: Callable = Callable()

func initialize(state: MatchState) -> void:
	match_state = state
	_register_default_disable_scope_handlers()
	reset_for_match()

func reset_for_match() -> void:
	skill_states.clear()
	disable_watchers.clear()
	skill_queue.clear()
	_register_default_disable_scope_handlers()
	rng.randomize()

func set_prompt_callback(cb: Callable) -> void:
	prompt_callback = cb

func register_card(card: Card) -> void:
	if card == null or not card.Special:
		return

	var count = CardSkill.get_skill_num_for_card(card)
	for i in range(1, count + 1):
		var key = _state_key(card.ID, i)
		if not skill_states.has(key):
			skill_states[key] = SkillUseState.READY

	if card.has_meta("copied_skill_type"):
		var copied_key = _copied_state_key(card.ID)
		if not skill_states.has(copied_key):
			skill_states[copied_key] = SkillUseState.READY

func has_pending_guarantee() -> bool:
	return skill_queue.has_guarantee()

func has_pending_increase() -> bool:
	return skill_queue.has_increase()

func resolve_supply_slot(card_manager: CardManager) -> Dictionary:
	var events: Array = []
	var selected_card: Card = null

	var guarantee_entry = _normalize_queue_entry(skill_queue.pop_next_guarantee())
	if not guarantee_entry.is_empty():
		var guarantee_owner: Player = null
		var guarantee_source_card_id := -1
		var guarantee_source_card_name := "未知卡牌"
		var guarantee_target_ids: Array[int] = []
		guarantee_owner = guarantee_entry.get("owner", null) as Player
		guarantee_source_card_id = int(guarantee_entry.get("source_card_id", -1))
		guarantee_source_card_name = str(guarantee_entry.get("source_card_name", "未知卡牌"))
		guarantee_target_ids = _array_to_int_array(guarantee_entry.get("target_ids", []))
		selected_card = _pick_target_card_from_storage(card_manager, guarantee_target_ids)
		if selected_card != null:
			events.append(_make_event_by_source(
				guarantee_owner,
				guarantee_source_card_id,
				guarantee_source_card_name,
				"GUARANTEE_APPEAR",
				"保证出现",
				STAGE_TRIGGER,
				"发动成功，补入目标牌: %s" % selected_card.Name,
				{
					"picked_card_id": selected_card.ID,
					"target_ids": guarantee_target_ids,
				}
			))
		else:
			events.append(_make_event_by_source(
				guarantee_owner,
				guarantee_source_card_id,
				guarantee_source_card_name,
				"GUARANTEE_APPEAR",
				"保证出现",
				STAGE_FAILED,
				"发动失败：目标牌不在牌库中",
				{"target_ids": guarantee_target_ids}
			))
		return {
			"card": selected_card,
			"events": events,
		}

	var increase_entry = _normalize_queue_entry(skill_queue.pop_next_increase())
	if not increase_entry.is_empty():
		var increase_owner: Player = null
		var increase_source_card_id := -1
		var increase_source_card_name := "未知卡牌"
		var increase_target_ids: Array[int] = []
		var probability := 0.0
		increase_owner = increase_entry.get("owner", null) as Player
		increase_source_card_id = int(increase_entry.get("source_card_id", -1))
		increase_source_card_name = str(increase_entry.get("source_card_name", "未知卡牌"))
		increase_target_ids = _array_to_int_array(increase_entry.get("target_ids", []))
		probability = float(increase_entry.get("probability", 0.0))
		probability = clampf(probability, 0.0, 1.0)
		var roll = rng.randf()
		if roll <= probability:
			selected_card = _pick_target_card_from_storage(card_manager, increase_target_ids)
			if selected_card != null:
				events.append(_make_event_by_source(
					increase_owner,
					increase_source_card_id,
					increase_source_card_name,
					"INCREASE_APPEAR",
					"增加出现概率",
					STAGE_TRIGGER,
					"概率命中(%.0f%%)，补入目标牌: %s" % [probability * 100.0, selected_card.Name],
					{
						"picked_card_id": selected_card.ID,
						"target_ids": increase_target_ids,
						"probability": probability,
						"roll": roll,
					}
				))
			else:
				events.append(_make_event_by_source(
					increase_owner,
					increase_source_card_id,
					increase_source_card_name,
					"INCREASE_APPEAR",
					"增加出现概率",
					STAGE_FAILED,
					"概率命中但目标牌不在牌库中",
					{
						"target_ids": increase_target_ids,
						"probability": probability,
						"roll": roll,
					}
				))
		else:
			events.append(_make_event_by_source(
				increase_owner,
				increase_source_card_id,
				increase_source_card_name,
				"INCREASE_APPEAR",
				"增加出现概率",
				STAGE_FAILED,
				"概率未命中(%.0f%%)，本次未补入目标牌" % [probability * 100.0],
				{
					"target_ids": increase_target_ids,
					"probability": probability,
					"roll": roll,
				}
			))

		return {
			"card": selected_card,
			"events": events,
		}

	return {
		"card": null,
		"events": events,
	}

func check_disable_on_opponent_acquire(
	acquiring_player: Player,
	opponent_player: Player,
	acquired_cards: Array[Card] = []
) -> Array:
	var events: Array = []
	for watcher_raw in disable_watchers:
		if not (watcher_raw is Dictionary):
			continue
		var watcher: Dictionary = watcher_raw
		if not bool(watcher.get("active", false)):
			continue
		var owner: Player = watcher.get("owner", null) as Player
		if owner != opponent_player:
			continue

		var mode := str(watcher.get("mode", DISABLE_MODE_FIXED_SINGLE))
		var scope := str(watcher.get("scope", DISABLE_SCOPE_ALL_SKILLS))
		var target_ids: Array[int] = _array_to_int_array(watcher.get("target_ids", []))
		var check_desc := _build_disable_check_desc(mode, target_ids, watcher)
		events.append(_make_event_by_source(
			owner,
			int(watcher.get("source_card_id", -1)),
			str(watcher.get("source_card_name", "未知卡牌")),
			"DISABLE_SKILL",
			"禁用技能",
			STAGE_CHECK,
			check_desc,
			{
				"mode": mode,
				"scope": scope,
				"target_ids": target_ids,
			}
		))

		if mode == DISABLE_MODE_FIXED_SINGLE or mode == DISABLE_MODE_FIXED_GROUP:
			var own_hit_cards: Array[Card] = _find_target_cards_in_deal(owner, target_ids)
			if not own_hit_cards.is_empty():
				watcher["active"] = false
				events.append(_make_event_by_source(
					owner,
					int(watcher.get("source_card_id", -1)),
					str(watcher.get("source_card_name", "未知卡牌")),
					"DISABLE_SKILL",
					"禁用技能",
					STAGE_FAILED,
					"发动失败（目标卡在自己手里）: %s" % _cards_to_name_text(own_hit_cards),
					{
						"mode": mode,
						"scope": scope,
						"target_ids": target_ids,
					}
				))
				continue

			var opponent_hit_cards: Array[Card] = _find_target_cards_in_deal(acquiring_player, target_ids)
			if opponent_hit_cards.is_empty():
				events.append(_make_event_by_source(
					owner,
					int(watcher.get("source_card_id", -1)),
					str(watcher.get("source_card_name", "未知卡牌")),
					"DISABLE_SKILL",
					"禁用技能",
					STAGE_CHECK,
					"未命中目标，继续监视",
					{
						"mode": mode,
						"scope": scope,
						"target_ids": target_ids,
					}
				))
				continue

			var special_hit_cards: Array[Card] = []
			for card in opponent_hit_cards:
				if card != null and card.Special:
					special_hit_cards.append(card)

			if special_hit_cards.is_empty():
				watcher["active"] = false
				events.append(_make_event_by_source(
					owner,
					int(watcher.get("source_card_id", -1)),
					str(watcher.get("source_card_name", "未知卡牌")),
					"DISABLE_SKILL",
					"禁用技能",
					STAGE_FAILED,
					"发动失败（目标卡在对手手里，但只有基础卡）: %s" % _cards_to_name_text(opponent_hit_cards),
					{
						"mode": mode,
						"scope": scope,
						"target_ids": target_ids,
					}
				))
				continue

			var disabled_names: Array[String] = []
			for target_card in special_hit_cards:
				if _apply_disable_scope_to_card(scope, target_card):
					disabled_names.append(target_card.Name)

			watcher["active"] = false
			if disabled_names.is_empty():
				events.append(_make_event_by_source(
					owner,
					int(watcher.get("source_card_id", -1)),
					str(watcher.get("source_card_name", "未知卡牌")),
					"DISABLE_SKILL",
					"禁用技能",
					STAGE_FAILED,
					"命中目标但禁用处理器无效",
					{
						"mode": mode,
						"scope": scope,
					}
				))
				continue

			events.append(_make_event_by_source(
				owner,
				int(watcher.get("source_card_id", -1)),
				str(watcher.get("source_card_name", "未知卡牌")),
				"DISABLE_SKILL",
				"禁用技能",
				STAGE_TRIGGER,
				"命中目标并已禁用: %s" % "、".join(disabled_names),
				{
					"mode": mode,
					"scope": scope,
					"target_ids": target_ids,
				}
			))
			continue

		if mode == DISABLE_MODE_PICK_OPPONENT_SPECIAL and int(watcher.get("selected_instance_id", 0)) <= 0:
			var pick_result = await _resolve_disable_pick_target(owner, acquiring_player, watcher)
			events.append_array(pick_result.get("events", []))
			if not bool(pick_result.get("ok", false)):
				watcher["active"] = false
				continue

		var hit_cards: Array[Card] = _find_disable_hit_cards(watcher, acquiring_player, acquired_cards)
		if hit_cards.is_empty():
			events.append(_make_event_by_source(
				owner,
				int(watcher.get("source_card_id", -1)),
				str(watcher.get("source_card_name", "未知卡牌")),
				"DISABLE_SKILL",
				"禁用技能",
				STAGE_CHECK,
				"未命中目标，继续监视",
				{
					"mode": mode,
					"scope": scope,
					"target_ids": target_ids,
				}
			))
			continue

		var disabled_names_pick: Array[String] = []
		for target_card in hit_cards:
			if _apply_disable_scope_to_card(scope, target_card):
				disabled_names_pick.append(target_card.Name)

		watcher["active"] = false
		if disabled_names_pick.is_empty():
			events.append(_make_event_by_source(
				owner,
				int(watcher.get("source_card_id", -1)),
				str(watcher.get("source_card_name", "未知卡牌")),
				"DISABLE_SKILL",
				"禁用技能",
				STAGE_FAILED,
				"命中目标但禁用处理器无效",
				{
					"mode": mode,
					"scope": scope,
				}
			))
			continue

		events.append(_make_event_by_source(
			owner,
			int(watcher.get("source_card_id", -1)),
			str(watcher.get("source_card_name", "未知卡牌")),
			"DISABLE_SKILL",
			"禁用技能",
			STAGE_TRIGGER,
			"命中目标并已禁用: %s" % "、".join(disabled_names_pick),
			{
				"mode": mode,
				"scope": scope,
				"target_ids": target_ids,
			}
		))

	return events

func resolve_turn_skills(
	current_player: Player,
	opponent_player: Player,
	action_cards: Array[Card],
	max_chain_steps: int = 16
) -> Dictionary:
	var result: Dictionary = {
		"events": [],
		"revealed_card_ids": [],
	}
	var result_events: Array = result["events"]
	var result_revealed_card_ids: Array = result["revealed_card_ids"]

	if action_cards.is_empty():
		return result

	var processing_queue: Array[Card] = action_cards.duplicate()
	var chain_steps := 0

	while not processing_queue.is_empty() and chain_steps < max_chain_steps:
		chain_steps += 1
		var card = processing_queue.pop_front()
		if card == null or not card.Special:
			continue

		register_card(card)
		var ready_entries = _get_ready_entries(card)
		if ready_entries.is_empty():
			continue

		var copy_entries: Array = []
		var exchange_entries: Array = []

		for entry in ready_entries:
			var entry_skill_type := _entry_skill_type(entry)
			match entry_skill_type:
				CardSkill.SKILL_TYPE.COPY_SKILL:
					copy_entries.append(entry)
				CardSkill.SKILL_TYPE.EXCHANGE_CARD:
					exchange_entries.append(entry)
				CardSkill.SKILL_TYPE.DISABLE_SKILL:
					await _register_disable_watch(current_player, entry, result_events)
				CardSkill.SKILL_TYPE.OPEN_OPPONENT_HAND:
					_apply_open_hand_skill(current_player, opponent_player, entry, result_events, result_revealed_card_ids)
				CardSkill.SKILL_TYPE.GUARANTEE_APPEAR:
					_register_deferred_supply_skill(current_player, entry, true, result_events)
				CardSkill.SKILL_TYPE.INCREASE_APPEAR:
					_register_deferred_supply_skill(current_player, entry, false, result_events)
				CardSkill.SKILL_TYPE.ADD_SCORE:
					_register_add_score_skill(current_player, entry)

		if not copy_entries.is_empty() and not exchange_entries.is_empty():
			var order_choice = await _decide_copy_exchange_order(current_player, card)
			if order_choice == "waive_all":
				for entry in copy_entries:
					_set_entry_state(entry, SkillUseState.WAIVED)
					result_events.append(_make_event_from_entry(current_player, entry, STAGE_WAIVED, "玩家放弃发动"))
				for entry in exchange_entries:
					_set_entry_state(entry, SkillUseState.WAIVED)
					result_events.append(_make_event_from_entry(current_player, entry, STAGE_WAIVED, "玩家放弃发动"))
			elif order_choice == "exchange_first":
				await _resolve_exchange_entries(current_player, opponent_player, exchange_entries, processing_queue, result_events)
				await _resolve_copy_entries(current_player, opponent_player, copy_entries, result_events)
			else:
				await _resolve_copy_entries(current_player, opponent_player, copy_entries, result_events)
				await _resolve_exchange_entries(current_player, opponent_player, exchange_entries, processing_queue, result_events)
		else:
			await _resolve_copy_entries(current_player, opponent_player, copy_entries, result_events)
			await _resolve_exchange_entries(current_player, opponent_player, exchange_entries, processing_queue, result_events)

	if chain_steps >= max_chain_steps:
		push_warning("SkillResolver: chain depth exceeded, force stop to avoid infinite loop.")

	return result

func _resolve_copy_entries(current_player: Player, opponent_player: Player, copy_entries: Array, result_events: Array) -> void:
	for entry in copy_entries:
		var should_trigger = await _ask_trigger_or_waive(current_player, entry)
		if not should_trigger:
			_set_entry_state(entry, SkillUseState.WAIVED)
			result_events.append(_make_event_from_entry(current_player, entry, STAGE_WAIVED, "玩家放弃发动"))
			continue
		_apply_copy_skill(current_player, opponent_player, entry, result_events)

func _resolve_exchange_entries(
	current_player: Player,
	opponent_player: Player,
	exchange_entries: Array,
	processing_queue: Array[Card],
	result_events: Array
) -> void:
	for entry in exchange_entries:
		var should_trigger = await _ask_trigger_or_waive(current_player, entry)
		if not should_trigger:
			_set_entry_state(entry, SkillUseState.WAIVED)
			result_events.append(_make_event_from_entry(current_player, entry, STAGE_WAIVED, "玩家放弃发动"))
			continue

		var swapped_in_card = await _apply_exchange_skill(current_player, opponent_player, entry, result_events)
		if swapped_in_card != null and swapped_in_card.Special:
			if _has_exchange_skill(swapped_in_card):
				_mark_exchange_skills_used(swapped_in_card)
			processing_queue.append(swapped_in_card)

func _ask_trigger_or_waive(current_player: Player, entry: Dictionary) -> bool:
	if current_player == null or current_player.is_ai_player():
		return true
	if not prompt_callback.is_valid():
		return true

	var choice = await prompt_callback.call({
		"type": "TRIGGER_OR_WAIVE",
		"title": "技能选择",
		"description": "是否发动【%s】？" % _skill_type_to_cn_name(_entry_skill_type(entry)),
		"options": [
			{"id": "trigger", "label": "发动"},
			{"id": "waive", "label": "放弃"},
		],
	})
	return str(choice) != "waive"

func _decide_copy_exchange_order(current_player: Player, source_card: Card) -> String:
	if current_player == null or current_player.is_ai_player():
		return "copy_first"
	if not prompt_callback.is_valid():
		return "copy_first"

	var choice = await prompt_callback.call({
		"type": "COPY_EXCHANGE_ORDER",
		"title": "技能顺序选择",
		"description": "卡牌【%s】同时拥有复制技能和交换卡牌。" % source_card.Name,
		"options": [
			{"id": "copy_first", "label": "先复制后交换"},
			{"id": "exchange_first", "label": "先交换后复制"},
			{"id": "waive_all", "label": "全部放弃"},
		],
	})

	var c = str(choice)
	if c != "copy_first" and c != "exchange_first" and c != "waive_all":
		return "copy_first"
	return c

func _apply_copy_skill(current_player: Player, opponent_player: Player, entry: Dictionary, result_events: Array) -> void:
	var candidate_cards = opponent_player.get_all_hand_cards()
	var target_special_cards: Array[Card] = []
	for card in candidate_cards:
		if card.Special:
			target_special_cards.append(card)

	if target_special_cards.is_empty():
		_set_entry_state(entry, SkillUseState.WAIVED)
		result_events.append(_make_event_from_entry(current_player, entry, STAGE_FAILED, "对手没有可复制技能的特殊卡"))
		return

	var copied_from: Card = target_special_cards[0]
	var copied_entry = _get_first_non_copy_entry(copied_from)
	if copied_entry.is_empty():
		_set_entry_state(entry, SkillUseState.WAIVED)
		result_events.append(_make_event_from_entry(current_player, entry, STAGE_FAILED, "目标卡没有可复制技能"))
		return

	var source_card: Card = _entry_card(entry)
	if source_card == null:
		_set_entry_state(entry, SkillUseState.WAIVED)
		result_events.append(_make_event_from_entry(current_player, entry, STAGE_FAILED, "复制失败：来源卡无效"))
		return
	source_card.set_meta("copied_skill_type", int(copied_entry.get("skill_type", CardSkill.SKILL_TYPE.NULL)))
	source_card.set_meta("copied_skill_target_ids", copied_entry.get("skill_target_ids", []))
	source_card.set_meta("copied_skill_value", float(copied_entry.get("skill_value", 0.0)))
	_set_entry_state(entry, SkillUseState.USED)

	result_events.append(_make_event_from_entry(
		current_player,
		entry,
		STAGE_TRIGGER,
		"复制了【%s】的技能" % copied_from.Name,
		{"from_card_id": copied_from.ID}
	))

func _apply_exchange_skill(current_player: Player, opponent_player: Player, entry: Dictionary, result_events: Array) -> Card:
	var source_card: Card = _entry_card(entry)
	if source_card == null:
		_set_entry_state(entry, SkillUseState.WAIVED)
		result_events.append(_make_event_from_entry(current_player, entry, STAGE_FAILED, "交换失败：来源卡无效"))
		return null

	# 获取可见的对手卡牌
	var visible_cards = _get_visible_opponent_cards(current_player, opponent_player)
	if visible_cards.is_empty():
		_set_entry_state(entry, SkillUseState.WAIVED)
		result_events.append(_make_event_from_entry(current_player, entry, STAGE_FAILED, "交换失败：无可见的对手卡牌"))
		return null

	# 根据玩家类型决定选择方式
	var target_card: Card = null
	if current_player.is_ai_player():
		target_card = _decide_ai_exchange_target(current_player, opponent_player, source_card, visible_cards)
	else:
		target_card = await _ask_exchange_target(current_player, visible_cards, source_card)

	# 如果选择放弃
	if target_card == null:
		_set_entry_state(entry, SkillUseState.USED)
		result_events.append(_make_event_from_entry(current_player, entry, STAGE_TRIGGER, "发动成功（玩家放弃）"))
		return null

	# 执行交换
	var swapped_in = await _execute_card_exchange(current_player, opponent_player, source_card, target_card, result_events)
	_set_entry_state(entry, SkillUseState.USED)
	_mark_exchange_disable_skill_used(source_card)

	return swapped_in

## 获取发动者可见的对手卡牌列表
## 包括：对手的deal区所有卡牌 + 对手手牌中被己方翻开的卡牌
func _get_visible_opponent_cards(current_player: Player, opponent_player: Player) -> Array[Card]:
	var visible_cards: Array[Card] = []
	if opponent_player == null:
		return visible_cards

	# 1. 添加对手deal区的所有卡牌
	for card in opponent_player.deal_cards.values():
		if card != null:
			visible_cards.append(card)

	# 2. 添加对手手牌中被己方翻开的卡牌
	if match_state != null and match_state.revealed_opponent_hand_cards.has(current_player):
		var revealed_ids_raw = match_state.revealed_opponent_hand_cards.get(current_player, [])
		var revealed_ids: Dictionary = {}
		if revealed_ids_raw is Array:
			for raw_id in revealed_ids_raw:
				revealed_ids[int(raw_id)] = true

		for card in opponent_player.get_all_hand_cards():
			if card != null and revealed_ids.has(card.ID):
				visible_cards.append(card)

	return visible_cards

## 判断卡牌是否在玩家的deal区
func _is_card_in_deal(player: Player, card: Card) -> bool:
	if player == null or card == null:
		return false
	return player.deal_cards.has(card.ID)

## 判断卡牌是否在玩家的手牌中
func _is_card_in_hand(player: Player, card: Card) -> bool:
	if player == null or card == null:
		return false
	return player.is_card_in_hand(card)

## 玩家选择交换目标卡牌的UI提示
func _ask_exchange_target(current_player: Player, visible_cards: Array[Card], source_card: Card) -> Card:
	if not prompt_callback.is_valid():
		return null

	# 构建选项列表
	var options: Array = []
	for card in visible_cards:
		var location = "deal区" if _is_card_in_deal(_get_opponent_of(current_player), card) else "手牌"
		options.append({
			"id": str(card.get_instance_id()),
			"label": "%s (%s)" % [card.Name, location],
			"card_id": card.ID,
		})
	options.append({"id": "waive", "label": "放弃交换"})

	var choice = await prompt_callback.call({
		"type": "EXCHANGE_CARD_TARGET",
		"title": "选择交换目标",
		"description": "使用【%s】交换一张对手的可见卡牌" % source_card.Name,
		"options": options,
	})

	if str(choice) == "waive":
		return null

	# 根据选择的instance_id找到对应的卡牌
	var selected_instance_id = int(choice)
	for card in visible_cards:
		if card.get_instance_id() == selected_instance_id:
			return card

	return null

## 获取当前玩家的对手
func _get_opponent_of(player: Player) -> Player:
	if player == null or match_state == null:
		return null
	if player == match_state.player_a:
		return match_state.player_b
	return match_state.player_a

## AI决定是否交换以及交换哪张卡
func _decide_ai_exchange_target(ai_player: Player, _opponent_player: Player, exchange_card: Card, visible_cards: Array[Card]) -> Card:
	if visible_cards.is_empty():
		return null

	# 收集AI当前拥有的卡牌ID集合（用于故事评估）
	var current_owned_ids: Dictionary = {}
	for card in ai_player.deal_cards.values():
		if card != null:
			current_owned_ids[_card_effective_id_for_exchange(card)] = true

	# 计算当前故事价值
	var current_story_value = _evaluate_story_value_for_cards(ai_player, current_owned_ids)

	# 评估每张可见卡牌的交换价值
	var best_target: Card = null
	var best_value_gain := 0.0

	for target_card in visible_cards:
		# 模拟交换后的卡牌集合（移除exchange_card，加入target_card）
		var simulated_ids: Dictionary = current_owned_ids.duplicate()
		simulated_ids.erase(_card_effective_id_for_exchange(exchange_card))
		simulated_ids[_card_effective_id_for_exchange(target_card)] = true

		var simulated_value = _evaluate_story_value_for_cards(ai_player, simulated_ids)
		var value_gain = simulated_value - current_story_value

		# 额外考虑卡牌本身的分值差异
		value_gain += float(target_card.Score - exchange_card.Score) * 0.1

		if value_gain > best_value_gain:
			best_value_gain = value_gain
			best_target = target_card

	# 如果没有价值提升，则放弃交换
	return best_target

## 获取卡牌的有效ID（用于故事评估）
func _card_effective_id_for_exchange(card: Card) -> int:
	if card == null:
		return -1
	return card.BaseID if card.Special else card.ID

## 评估给定卡牌集合的故事价值
func _evaluate_story_value_for_cards(player: Player, owned_ids: Dictionary) -> float:
	var value := 0.0
	if match_state == null or match_state.story_manager == null:
		return value

	for story_id in match_state.story_manager.stories.keys():
		var story: Story = match_state.story_manager.stories[story_id]
		if _player_has_finished_story_check(player, int(story_id)):
			continue

		var missing = _count_story_missing_for_exchange(story.cards_id, owned_ids)
		if missing == 0:
			# 故事完成
			value += 10000.0 + float(story.score) * 20.0
		elif missing <= 2:
			# 接近完成
			value += float(story.cards_id.size() - missing) * 100.0
			value += 200.0 / float(missing)

	return value

## 检查玩家是否已完成指定故事
func _player_has_finished_story_check(player: Player, story_id: int) -> bool:
	if player == null:
		return false
	for item in player.finished_stories:
		if item is Story and int(item.id) == story_id:
			return true
		if item is int and int(item) == story_id:
			return true
	return false

## 计算故事缺少的卡牌数量
func _count_story_missing_for_exchange(story_card_ids: Array, owned_ids: Dictionary) -> int:
	var missing := 0
	for raw_id in story_card_ids:
		var cid := int(raw_id)
		if not owned_ids.has(cid):
			missing += 1
	return missing

## 执行卡牌交换
func _execute_card_exchange(current_player: Player, opponent_player: Player, source_card: Card, target_card: Card, result_events: Array) -> Card:
	if source_card == null or target_card == null:
		return null

	var target_in_deal = _is_card_in_deal(opponent_player, target_card)
	var target_in_hand = _is_card_in_hand(opponent_player, target_card)

	if not target_in_deal and not target_in_hand:
		result_events.append(_make_event_from_entry(current_player, {}, STAGE_FAILED, "交换失败：目标卡不在对手的deal或手牌中"))
		return null

	# 获取ScoreManager实例
	var score_manager = ScoreManager.get_instance()
	
	# 记录交换前的分数
	var current_player_old_score = score_manager.get_player_score(current_player)
	var opponent_old_score = score_manager.get_player_score(opponent_player)
	
	# 开始记录交换操作日志
	score_manager.begin_exchange_logging(current_player, opponent_player)

	# ============ 阶段1: 撤销分数 ============
	
	# 1.1 撤销发动者失去的卡牌分数
	score_manager.revoke_card_score(current_player, source_card)
	# 撤销与该卡相关的技能效果
	score_manager.revoke_score_effects_for_card(current_player, source_card)
	
	# 1.2 如果目标卡在对手deal中，撤销对手的卡牌分数
	if target_in_deal:
		score_manager.revoke_card_score(opponent_player, target_card)
		score_manager.revoke_score_effects_for_card(opponent_player, target_card)

	# ============ 阶段2: 执行卡牌交换 ============
	
	# 从发动者deal中移除source_card
	if current_player.deal_cards.has(source_card.ID):
		current_player.deal_cards.erase(source_card.ID)

	# 将target_card加入发动者deal
	current_player.deal_cards[target_card.ID] = target_card
	target_card.set_player_owner(current_player)

	if target_in_deal:
		# 从对手deal中移除target_card
		opponent_player.deal_cards.erase(target_card.ID)
		# 将source_card加入对手deal
		opponent_player.deal_cards[source_card.ID] = source_card
		source_card.set_player_owner(opponent_player)
	else:
		# target_card在对手手牌中
		var target_slot = opponent_player.get_hand_slot_index(target_card)
		if target_slot != -1:
			# 清空该槽位
			opponent_player.hand_cards[target_slot].card = null
			opponent_player.hand_cards[target_slot].is_empty = true
			# 将source_card放入该槽位
			opponent_player._attach_card_to_slot(target_slot, source_card)

	# ============ 阶段3: 添加新卡牌分数 ============
	
	# 3.1 为发动者添加获得卡牌的分数
	score_manager.add_card_score(current_player, target_card)
	
	# 3.2 如果目标卡原本在deal中，为对手添加获得卡牌的分数
	if target_in_deal:
		score_manager.add_card_score(opponent_player, source_card)

	# ============ 阶段4: 技能效果转移 ============
	
	# 4.1 来源卡的技能效果从发动者转移到对手（如果来源卡进入对手deal）
	if target_in_deal and source_card.Special:
		score_manager.transfer_score_effects(current_player, opponent_player, source_card)
		# 尝试应用转移后的效果
		score_manager.apply_score_effects(opponent_player)
	
	# 4.2 目标卡的技能效果从对手转移到发动者（如果目标卡原本在deal中）
	if target_in_deal and target_card.Special:
		score_manager.transfer_score_effects(opponent_player, current_player, target_card)
		score_manager.apply_score_effects(current_player)

	var location_text = "deal区" if target_in_deal else "手牌"
	result_events.append(_make_event_from_entry(
		current_player,
		{},
		STAGE_TRIGGER,
		"交换了己方[%s]与对方%s中的[%s]" % [source_card.Name, location_text, target_card.Name],
		{
			"self_card_id": source_card.ID,
			"opponent_card_id": target_card.ID,
			"target_location": location_text,
		}
	))

	# 交换后重新计算故事和分数
	_recalculate_stories_after_exchange(current_player, opponent_player, result_events, score_manager)
	
	# 结束交换日志记录并获取日志数据
	var exchange_logs = score_manager.end_exchange_logging()
	
	# 记录交换后的分数
	var current_player_new_score = score_manager.get_player_score(current_player)
	var opponent_new_score = score_manager.get_player_score(opponent_player)
	
	# ============ 展示交换结果UI ============
	var ui_manager = UIManager.get_instance()
	var exchange_ui = ui_manager.ensure_get_ui_instance("UI_ExchangeResult")
	if exchange_ui != null:
		if exchange_ui.get_parent() == null:
			ui_manager.open_ui_instance(exchange_ui)
		ui_manager.move_ui_instance_to_top(exchange_ui)
		
		# 构建展示数据
		var display_data = {
			"player_a": current_player,
			"player_b": opponent_player,
			"player_a_lost_card": source_card,
			"player_a_gained_card": target_card,
			"player_b_lost_card": target_card if target_in_deal else null,
			"player_b_gained_card": source_card if target_in_deal else null,
			"player_a_old_score": current_player_old_score,
			"player_a_new_score": current_player_new_score,
			"player_b_old_score": opponent_old_score,
			"player_b_new_score": opponent_new_score,
			"player_a_logs": exchange_logs.get(current_player, []),
			"player_b_logs": exchange_logs.get(opponent_player, []),
		}
		exchange_ui.show_exchange_result(display_data)
		
		# 等待用户确认
		await exchange_ui.wait_for_confirmation()

	return target_card

## 交换后重新计算双方的故事完成情况
func _recalculate_stories_after_exchange(current_player: Player, opponent_player: Player, result_events: Array, score_manager: ScoreManager) -> void:
	if match_state == null or match_state.story_manager == null:
		return

	var story_manager = match_state.story_manager

	# 1. 收集交换前双方已完成的故事（从 Player 的 finished_stories 中获取）
	var current_player_finished_before: Array[int] = []
	for story in current_player.finished_stories:
		if story is Story:
			current_player_finished_before.append(story.id)
		elif story is int:
			current_player_finished_before.append(story)

	var opponent_finished_before: Array[int] = []
	for story in opponent_player.finished_stories:
		if story is Story:
			opponent_finished_before.append(story.id)
		elif story is int:
			opponent_finished_before.append(story)

	# 2. 检查每个故事是否因为交换而失效
	var current_player_invalidated: Array[Story] = []
	var opponent_invalidated: Array[Story] = []

	for story_id in current_player_finished_before:
		var story: Story = story_manager.stories.get(story_id, null)
		if story == null:
			continue
		if not _player_still_has_story_cards(current_player, story):
			story.mark_as_unfinished()
			current_player_invalidated.append(story)
			# 撤销故事分数
			score_manager.revoke_story_score(current_player, story)
			# 撤销与故事相关的技能加分
			score_manager.revoke_score_effects_for_story(current_player, story)
			# 从玩家的完成故事列表中移除
			_remove_story_from_player(current_player, story)
			# 从 story_manager 的 completed_stories 中移除
			var idx = story_manager.completed_stories.find(story)
			if idx != -1:
				story_manager.completed_stories.remove_at(idx)

	for story_id in opponent_finished_before:
		var story: Story = story_manager.stories.get(story_id, null)
		if story == null:
			continue
		if not _player_still_has_story_cards(opponent_player, story):
			story.mark_as_unfinished()
			opponent_invalidated.append(story)
			# 撤销故事分数
			score_manager.revoke_story_score(opponent_player, story)
			# 撤销与故事相关的技能加分
			score_manager.revoke_score_effects_for_story(opponent_player, story)
			_remove_story_from_player(opponent_player, story)
			var idx = story_manager.completed_stories.find(story)
			if idx != -1:
				story_manager.completed_stories.remove_at(idx)

	# 3. 检查是否有新完成的故事
	var current_player_new = story_manager.check_story_finish_for_player(current_player)
	var opponent_new = story_manager.check_story_finish_for_player(opponent_player)
	
	# 为新完成的故事添加分数
	for story in current_player_new:
		score_manager.add_single_story_score(current_player, story)
	for story in opponent_new:
		score_manager.add_single_story_score(opponent_player, story)
	
	# 应用可能因新故事完成而触发的技能效果
	score_manager.apply_score_effects(current_player)
	score_manager.apply_score_effects(opponent_player)

	# 4. 生成事件记录
	for story in current_player_invalidated:
		result_events.append(_make_event_by_source(
			current_player,
			-1,
			"交换卡牌",
			"STORY_CHANGE",
			"故事变化",
			STAGE_TRIGGER,
			"因交换导致故事失效: %s" % story.name,
			{"story_id": story.id, "story_name": story.name, "change_type": "invalidated"}
		))

	for story in opponent_invalidated:
		result_events.append(_make_event_by_source(
			opponent_player,
			-1,
			"交换卡牌",
			"STORY_CHANGE",
			"故事变化",
			STAGE_TRIGGER,
			"因交换导致故事失效: %s" % story.name,
			{"story_id": story.id, "story_name": story.name, "change_type": "invalidated"}
		))

	for story in current_player_new:
		result_events.append(_make_event_by_source(
			current_player,
			-1,
			"交换卡牌",
			"STORY_CHANGE",
			"故事变化",
			STAGE_TRIGGER,
			"因交换完成新故事: %s" % story.name,
			{"story_id": story.id, "story_name": story.name, "change_type": "completed"}
		))

	for story in opponent_new:
		result_events.append(_make_event_by_source(
			opponent_player,
			-1,
			"交换卡牌",
			"STORY_CHANGE",
			"故事变化",
			STAGE_TRIGGER,
			"因交换完成新故事: %s" % story.name,
			{"story_id": story.id, "story_name": story.name, "change_type": "completed"}
		))

	# 5. 将新完成的故事添加到玩家的finished_stories
	current_player.finished_stories.append_array(current_player_new)
	opponent_player.finished_stories.append_array(opponent_new)

## 检查玩家是否仍然拥有完成故事所需的所有卡牌
func _player_still_has_story_cards(player: Player, story: Story) -> bool:
	var owned_ids: Dictionary = {}
	for card in player.deal_cards.values():
		if card != null:
			var effective_id = card.BaseID if card.Special else card.ID
			owned_ids[effective_id] = true

	for card_id in story.cards_id:
		if not owned_ids.has(int(card_id)):
			return false
	return true

## 从玩家的完成故事列表中移除指定故事
func _remove_story_from_player(player: Player, story: Story) -> void:
	for i in range(player.finished_stories.size() - 1, -1, -1):
		var item = player.finished_stories[i]
		if item is Story and item.id == story.id:
			player.finished_stories.remove_at(i)
		elif item is int and item == story.id:
			player.finished_stories.remove_at(i)

func _register_disable_watch(current_player: Player, entry: Dictionary, events: Array) -> void:
	var source_card: Card = _entry_card(entry)
	var target_ids: Array[int] = _array_to_int_array(entry.get("skill_target_ids", []))
	var disable_mode := str(entry.get("disable_mode", "")).strip_edges().to_upper()
	var disable_scope := str(entry.get("disable_scope", DISABLE_SCOPE_ALL_SKILLS)).strip_edges().to_upper()
	if disable_mode == "":
		disable_mode = _infer_disable_mode(entry)
	if disable_scope == "":
		disable_scope = DISABLE_SCOPE_ALL_SKILLS

	if not _is_valid_disable_mode(disable_mode):
		_set_entry_state(entry, SkillUseState.USED)
		events.append(_make_event_from_entry(current_player, entry, STAGE_INVALID, "禁用技能模式配置非法，未生效"))
		return

	if disable_mode != DISABLE_MODE_PICK_OPPONENT_SPECIAL and target_ids.is_empty():
		_set_entry_state(entry, SkillUseState.USED)
		events.append(_make_event_from_entry(current_player, entry, STAGE_INVALID, "禁用技能配置无目标，未生效"))
		return

	_set_entry_state(entry, SkillUseState.USED)
	var opponent_player: Player = _get_opponent_player(current_player)
	if opponent_player == null:
		events.append(_make_event_from_entry(current_player, entry, STAGE_FAILED, "无法获取对手，禁用技能未生效"))
		return

	var watcher_dict = {
		"active": true,
		"owner": current_player,
		"source_card_id": source_card.ID if source_card != null else -1,
		"source_card_name": source_card.Name if source_card != null else "未知卡牌",
		"mode": disable_mode,
		"scope": disable_scope,
		"target_ids": target_ids,
		"selected_instance_id": 0,
		"selected_card_id": - 1,
		"selected_card_name": "",
	}

	if disable_mode == DISABLE_MODE_PICK_OPPONENT_SPECIAL:
		var pick_result = await _resolve_disable_pick_target(current_player, opponent_player, watcher_dict, true)
		events.append_array(pick_result.get("events", []))
		if bool(pick_result.get("waived", false)):
			return
		if not bool(pick_result.get("ok", false)):
			return

		var selected_instance_id := int(watcher_dict.get("selected_instance_id", 0))
		var selected_card: Card = null
		for card in _collect_special_cards_from_player_deal(opponent_player):
			if card != null and card.get_instance_id() == selected_instance_id:
				selected_card = card
				break

		if selected_card == null:
			events.append(_make_event_by_source(
				current_player,
				source_card.ID if source_card != null else -1,
				source_card.Name if source_card != null else "未知卡牌",
				"DISABLE_SKILL",
				"禁用技能",
				STAGE_FAILED,
				"发动失败（目标不在对手牌堆）",
				{
					"mode": disable_mode,
					"scope": disable_scope,
				}
			))
			return

		if _apply_disable_scope_to_card(disable_scope, selected_card):
			events.append(_make_event_by_source(
				current_player,
				source_card.ID if source_card != null else -1,
				source_card.Name if source_card != null else "未知卡牌",
				"DISABLE_SKILL",
				"禁用技能",
				STAGE_TRIGGER,
				"立即禁用目标: %s" % selected_card.Name,
				{
					"mode": disable_mode,
					"scope": disable_scope,
					"target_ids": [selected_card.ID, selected_card.BaseID],
				}
			))
		else:
			events.append(_make_event_by_source(
				current_player,
				source_card.ID if source_card != null else -1,
				source_card.Name if source_card != null else "未知卡牌",
				"DISABLE_SKILL",
				"禁用技能",
				STAGE_FAILED,
				"命中目标但禁用处理器无效",
				{
					"mode": disable_mode,
					"scope": disable_scope,
				}
			))
		return

	var own_hit_cards: Array[Card] = _find_target_cards_in_deal(current_player, target_ids)
	if not own_hit_cards.is_empty():
		events.append(_make_event_by_source(
			current_player,
			source_card.ID if source_card != null else -1,
			source_card.Name if source_card != null else "未知卡牌",
			"DISABLE_SKILL",
			"禁用技能",
			STAGE_FAILED,
			"发动失败（目标卡在自己手里）: %s" % _cards_to_name_text(own_hit_cards),
			{
				"mode": disable_mode,
				"scope": disable_scope,
				"target_ids": target_ids,
			}
		))
		return

	var opponent_hit_cards: Array[Card] = _find_target_cards_in_deal(opponent_player, target_ids)
	if opponent_hit_cards.is_empty():
		disable_watchers.append(watcher_dict)
		var register_text := ""
		match disable_mode:
			DISABLE_MODE_FIXED_SINGLE:
				register_text = "已登记监视（单目标）: %s" % _target_ids_to_card_names_text(target_ids)
			DISABLE_MODE_FIXED_GROUP:
				register_text = "已登记监视（组目标）: %s" % _target_ids_to_card_names_text(target_ids)
			_:
				register_text = "已登记监视"

		events.append(_make_event_from_entry(
			current_player,
			entry,
			STAGE_REGISTER,
			register_text,
			{
				"target_ids": target_ids,
				"mode": disable_mode,
				"scope": disable_scope,
			}
		))
		events.append(_make_event_by_source(
			current_player,
			source_card.ID if source_card != null else -1,
			source_card.Name if source_card != null else "未知卡牌",
			"DISABLE_SKILL",
			"禁用技能",
			STAGE_CHECK,
			"未找到目标，已登记监视",
			{
				"mode": disable_mode,
				"scope": disable_scope,
				"target_ids": target_ids,
			}
		))
		return

	var special_hit_cards: Array[Card] = []
	for card in opponent_hit_cards:
		if card != null and card.Special:
			special_hit_cards.append(card)

	if special_hit_cards.is_empty():
		events.append(_make_event_by_source(
			current_player,
			source_card.ID if source_card != null else -1,
			source_card.Name if source_card != null else "未知卡牌",
			"DISABLE_SKILL",
			"禁用技能",
			STAGE_FAILED,
			"发动失败（目标卡在对手手里，但只有基础卡）: %s" % _cards_to_name_text(opponent_hit_cards),
			{
				"mode": disable_mode,
				"scope": disable_scope,
				"target_ids": target_ids,
			}
		))
		return

	var disabled_names: Array[String] = []
	for target_card in special_hit_cards:
		if _apply_disable_scope_to_card(disable_scope, target_card):
			disabled_names.append(target_card.Name)

	if disabled_names.is_empty():
		events.append(_make_event_by_source(
			current_player,
			source_card.ID if source_card != null else -1,
			source_card.Name if source_card != null else "未知卡牌",
			"DISABLE_SKILL",
			"禁用技能",
			STAGE_FAILED,
			"命中目标但禁用处理器无效",
			{
				"mode": disable_mode,
				"scope": disable_scope,
			}
		))
		return

	events.append(_make_event_by_source(
		current_player,
		source_card.ID if source_card != null else -1,
		source_card.Name if source_card != null else "未知卡牌",
		"DISABLE_SKILL",
		"禁用技能",
		STAGE_TRIGGER,
		"立即禁用目标: %s" % "、".join(disabled_names),
		{
			"mode": disable_mode,
			"scope": disable_scope,
			"target_ids": target_ids,
		}
	))

func _apply_open_hand_skill(current_player: Player, opponent_player: Player, entry: Dictionary, result_events: Array, result_revealed_card_ids: Array) -> void:
	var raw_skill_value := int(entry.get("skill_value", 0))
	var open_count = raw_skill_value if raw_skill_value > 0 else 1
	var opponent_cards = opponent_player.get_all_hand_cards()
	if opponent_cards.is_empty():
		_set_entry_state(entry, SkillUseState.USED)
		result_events.append(_make_event_from_entry(current_player, entry, STAGE_TRIGGER, "无可翻开目标"))
		return

	var already_revealed: Array[int] = []
	if match_state.revealed_opponent_hand_cards.has(current_player):
		already_revealed = _array_to_int_array(match_state.revealed_opponent_hand_cards[current_player])

	var unrevealed_cards: Array[Card] = []
	for card in opponent_cards:
		if not already_revealed.has(card.ID):
			unrevealed_cards.append(card)

	if unrevealed_cards.is_empty():
		_set_entry_state(entry, SkillUseState.USED)
		result_events.append(_make_event_from_entry(current_player, entry, STAGE_TRIGGER, "无可翻开目标"))
		return

	open_count = mini(open_count, unrevealed_cards.size())
	unrevealed_cards.shuffle()
	var opened_ids: Array[int] = []
	var opened_names: Array[String] = []
	for i in range(open_count):
		opened_ids.append(unrevealed_cards[i].ID)
		opened_names.append(unrevealed_cards[i].Name)

	var merged_revealed: Array[int] = already_revealed.duplicate()
	for cid in opened_ids:
		if not merged_revealed.has(cid):
			merged_revealed.append(cid)
	match_state.revealed_opponent_hand_cards[current_player] = merged_revealed
	_set_entry_state(entry, SkillUseState.USED)

	for card_id in opened_ids:
		result_revealed_card_ids.append(card_id)

	result_events.append(_make_event_from_entry(
		current_player,
		entry,
		STAGE_TRIGGER,
		"翻开了对手手牌: %s" % "、".join(opened_names),
		{"opened_ids": opened_ids}
	))
	
	# 技能生效后刷新卡牌可见性
	# 这里不需要直接修改卡牌的可见性，而是通过match_state中的信息来控制
	# GameInstance中的_refresh_card_visibility会根据规则正确处理卡牌显示

func _register_deferred_supply_skill(current_player: Player, entry: Dictionary, is_guarantee: bool, events: Array) -> void:
	var source_card: Card = _entry_card(entry)
	var target_ids: Array[int] = _array_to_int_array(entry.get("skill_target_ids", []))
	if target_ids.is_empty():
		_set_entry_state(entry, SkillUseState.WAIVED)
		events.append(_make_event_from_entry(current_player, entry, STAGE_INVALID, "无目标配置，未登记"))
		return

	if is_guarantee:
		skill_queue.enqueue_guarantee(
			current_player,
			source_card.ID if source_card != null else -1,
			source_card.Name if source_card != null else "未知卡牌",
			int(entry.get("skill_index", -1)),
			str(entry.get("skill_target_name", "")),
			target_ids
		)
		events.append(_make_event_from_entry(
			current_player,
			entry,
			STAGE_REGISTER,
			"已登记，下回合补牌时尝试保证出现",
			{"target_ids": target_ids}
		))
	else:
		var probability = float(entry.get("skill_value", 0.0))
		if probability <= 0.0:
			probability = 0.5
		if probability > 1.0:
			probability = probability / 100.0
		skill_queue.enqueue_increase(
			current_player,
			source_card.ID if source_card != null else -1,
			source_card.Name if source_card != null else "未知卡牌",
			int(entry.get("skill_index", -1)),
			str(entry.get("skill_target_name", "")),
			target_ids,
			probability
		)
		events.append(_make_event_from_entry(
			current_player,
			entry,
			STAGE_REGISTER,
			"已登记，下回合补牌时进行概率判定(%.0f%%)" % [probability * 100.0],
			{
				"target_ids": target_ids,
				"probability": probability,
			}
		))

	_set_entry_state(entry, SkillUseState.USED)

func _register_add_score_skill(current_player: Player, entry: Dictionary) -> void:
	var source_card: Card = _entry_card(entry)
	if source_card == null:
		return
	ScoreManager.get_instance().register_add_score_effect_for_skill(current_player, source_card, int(entry.get("skill_index", -1)))
	_set_entry_state(entry, SkillUseState.USED)

func _get_ready_entries(card: Card) -> Array:
	var entries: Array = []
	var count = CardSkill.get_skill_num_for_card(card)

	for i in range(1, count + 1):
		var entry = _build_entry_from_skill_row(card, i)
		if entry.is_empty():
			continue
		if _get_entry_state(entry) == SkillUseState.READY:
			entries.append(entry)

	if card.has_meta("copied_skill_type"):
		var copied_entry: Dictionary = {
			"card": card,
			"skill_index": - 1,
			"skill_type": int(card.get_meta("copied_skill_type")),
			"skill_target_ids": card.get_meta("copied_skill_target_ids") if card.has_meta("copied_skill_target_ids") else [],
			"skill_value": float(card.get_meta("copied_skill_value")) if card.has_meta("copied_skill_value") else 0.0,
			"skill_target_name": "",
			"skill_target_type": "",
			"is_copied": true,
		}
		if _get_entry_state(copied_entry) == SkillUseState.READY:
			entries.append(copied_entry)

	return entries

func _build_entry_from_skill_row(card: Card, skill_index: int) -> Dictionary:
	var row = table_manager.get_row("Skills", card.ID)
	if row == null:
		return {}
	if row.is_empty():
		return {}

	var type_key = "Skill%dType" % skill_index
	if not row.has(type_key):
		return {}

	var type_str = str(row[type_key]).strip_edges()
	if type_str == "":
		return {}

	var target_id_key = "Skill%dTargetID" % skill_index
	var value_key = "Skill%dValue" % skill_index
	var target_key = "Skill%dTarget" % skill_index
	var target_type_key = "Skill%dTargetType" % skill_index
	var disable_mode_key = "Skill%dDisableMode" % skill_index
	var disable_scope_key = "Skill%dDisableScope" % skill_index

	var target_ids: Array[int] = []
	var target_raw := ""
	if row.has(target_id_key):
		target_raw = str(row[target_id_key]).strip_edges()
		target_ids = _parse_target_ids(row[target_id_key])

	var skill_value := 0.0
	if row.has(value_key):
		var value_raw = str(row[value_key]).strip_edges()
		if value_raw != "":
			skill_value = float(value_raw)

	var target_name := ""
	if row.has(target_key):
		target_name = str(row[target_key]).strip_edges()

	var target_type := ""
	if row.has(target_type_key):
		target_type = str(row[target_type_key]).strip_edges().to_upper()

	var disable_mode := ""
	if row.has(disable_mode_key):
		disable_mode = str(row[disable_mode_key]).strip_edges().to_upper()

	var disable_scope := ""
	if row.has(disable_scope_key):
		disable_scope = str(row[disable_scope_key]).strip_edges().to_upper()

	return {
		"card": card,
		"skill_index": skill_index,
		"skill_type": CardSkill.string_to_skill_type(type_str),
		"skill_target_ids": target_ids,
		"skill_target_raw": target_raw,
		"skill_target_name": target_name,
		"skill_target_type": target_type,
		"disable_mode": disable_mode,
		"disable_scope": disable_scope,
		"skill_value": skill_value,
		"is_copied": false,
	}

func _pick_target_card_from_storage(card_manager: CardManager, target_ids: Array[int]) -> Card:
	for target_id in target_ids:
		var picked = card_manager.pop_card_by_id(target_id)
		if picked != null:
			return picked
	return null

func _target_ids_to_card_names_text(target_ids: Array[int]) -> String:
	var names: Array[String] = []
	for tid in target_ids:
		var row = table_manager.get_row("Cards", int(tid))
		if row != null and not row.is_empty() and row.has("Name"):
			names.append(str(row["Name"]))
		else:
			names.append(str(tid))
	return "、".join(names)

func _make_event_from_entry(
	actor: Player,
	entry: Dictionary,
	stage: int,
	result_text: String,
	payload: Dictionary = {}
):
	var card: Card = entry.get("card", null) as Card
	var skill_type = int(entry.get("skill_type", CardSkill.SKILL_TYPE.NULL))
	var stage_actor = actor.player_name if actor != null else ""
	return SkillCastEventScript.new(
		match_state.round_index if match_state != null else 0,
		stage_actor,
		card.ID if card != null else -1,
		card.Name if card != null else "未知卡牌",
		_skill_type_to_code(skill_type),
		_skill_type_to_cn_name(skill_type),
		stage,
		result_text,
		payload
	)

func _make_event_by_source(
	actor: Player,
	source_card_id: int,
	source_card_name: String,
	skill_code: String,
	skill_name: String,
	stage: int,
	result_text: String,
	payload: Dictionary = {}
):
	return SkillCastEventScript.new(
		match_state.round_index if match_state != null else 0,
		actor.player_name if actor != null else "",
		source_card_id,
		source_card_name,
		skill_code,
		skill_name,
		stage,
		result_text,
		payload
	)

func _disable_all_skills_for_card(card: Card) -> void:
	register_card(card)
	var count = CardSkill.get_skill_num_for_card(card)
	for i in range(1, count + 1):
		skill_states[_state_key(card.ID, i)] = SkillUseState.DISABLED
	if card.has_meta("copied_skill_type"):
		skill_states[_copied_state_key(card.ID)] = SkillUseState.DISABLED

func _parse_target_ids(raw_value) -> Array[int]:
	if raw_value == null:
		return []
	var raw = str(raw_value).strip_edges()
	if raw == "":
		return []
	raw = raw.replace("(", "")
	raw = raw.replace(")", "")
	raw = raw.replace(";", ",")
	var result: Array[int] = []
	for token in raw.split(","):
		var t = token.strip_edges()
		if t.is_valid_int():
			result.append(t.to_int())
	return result

func _get_first_non_copy_entry(card: Card) -> Dictionary:
	var count = CardSkill.get_skill_num_for_card(card)
	for i in range(1, count + 1):
		var entry = _build_entry_from_skill_row(card, i)
		if entry.is_empty():
			continue
		var entry_skill_type := _entry_skill_type(entry)
		if entry_skill_type != CardSkill.SKILL_TYPE.COPY_SKILL and entry_skill_type != CardSkill.SKILL_TYPE.EXCHANGE_DISABLE_SKILL:
			return entry
	return {}

func _has_exchange_skill(card: Card) -> bool:
	var count = CardSkill.get_skill_num_for_card(card)
	for i in range(1, count + 1):
		if CardSkill.get_skill_type_by_index(card, i) == CardSkill.SKILL_TYPE.EXCHANGE_CARD:
			return true
	return false

func _mark_exchange_skills_used(card: Card) -> void:
	var count = CardSkill.get_skill_num_for_card(card)
	for i in range(1, count + 1):
		if CardSkill.get_skill_type_by_index(card, i) == CardSkill.SKILL_TYPE.EXCHANGE_CARD:
			skill_states[_state_key(card.ID, i)] = SkillUseState.USED

func _mark_exchange_disable_skill_used(card: Card) -> void:
	if card == null:
		return
	var count = CardSkill.get_skill_num_for_card(card)
	for i in range(1, count + 1):
		if CardSkill.get_skill_type_by_index(card, i) == CardSkill.SKILL_TYPE.EXCHANGE_DISABLE_SKILL:
			skill_states[_state_key(card.ID, i)] = SkillUseState.USED

func _skill_type_to_code(skill_type: int) -> String:
	match skill_type:
		CardSkill.SKILL_TYPE.DISABLE_SKILL:
			return "DISABLE_SKILL"
		CardSkill.SKILL_TYPE.GUARANTEE_APPEAR:
			return "GUARANTEE_APPEAR"
		CardSkill.SKILL_TYPE.INCREASE_APPEAR:
			return "INCREASE_APPEAR"
		CardSkill.SKILL_TYPE.ADD_SCORE:
			return "ADD_SCORE"
		CardSkill.SKILL_TYPE.COPY_SKILL:
			return "COPY_SKILL"
		CardSkill.SKILL_TYPE.EXCHANGE_CARD:
			return "EXCHANGE_CARD"
		CardSkill.SKILL_TYPE.OPEN_OPPONENT_HAND:
			return "OPEN_OPPONENT_HAND"
		CardSkill.SKILL_TYPE.EXCHANGE_DISABLE_SKILL:
			return "EXCHANGE_DISABLE_SKILL"
		_:
			return "UNKNOWN"

func _skill_type_to_cn_name(skill_type: int) -> String:
	match skill_type:
		CardSkill.SKILL_TYPE.DISABLE_SKILL:
			return "禁用技能"
		CardSkill.SKILL_TYPE.GUARANTEE_APPEAR:
			return "保证出现"
		CardSkill.SKILL_TYPE.INCREASE_APPEAR:
			return "增加出现概率"
		CardSkill.SKILL_TYPE.ADD_SCORE:
			return "增加分数"
		CardSkill.SKILL_TYPE.COPY_SKILL:
			return "复制技能"
		CardSkill.SKILL_TYPE.EXCHANGE_CARD:
			return "交换卡牌"
		CardSkill.SKILL_TYPE.OPEN_OPPONENT_HAND:
			return "翻开对手手牌"
		CardSkill.SKILL_TYPE.EXCHANGE_DISABLE_SKILL:
			return "交换后无效"
		_:
			return "未知技能"

func _state_key(card_id: int, skill_index: int) -> String:
	return "%s_%s" % [str(card_id), str(skill_index)]

func _copied_state_key(card_id: int) -> String:
	return "%s_copied" % str(card_id)

func _get_entry_state(entry: Dictionary) -> SkillUseState:
	var card: Card = _entry_card(entry)
	if card == null:
		return SkillUseState.WAIVED
	if bool(entry.get("is_copied", false)):
		return skill_states.get(_copied_state_key(card.ID), SkillUseState.READY)
	return skill_states.get(_state_key(card.ID, int(entry.get("skill_index", -1))), SkillUseState.READY)

func _set_entry_state(entry: Dictionary, state: SkillUseState) -> void:
	var card: Card = _entry_card(entry)
	if card == null:
		return
	if bool(entry.get("is_copied", false)):
		skill_states[_copied_state_key(card.ID)] = state
	else:
		skill_states[_state_key(card.ID, int(entry.get("skill_index", -1)))] = state

func _entry_card(entry: Dictionary) -> Card:
	return entry.get("card", null) as Card

func _entry_skill_type(entry: Dictionary) -> int:
	return int(entry.get("skill_type", CardSkill.SKILL_TYPE.NULL))

func _array_to_int_array(raw_value) -> Array[int]:
	var result: Array[int] = []
	if raw_value is Array:
		for item in raw_value:
			result.append(int(item))
	return result

func _register_default_disable_scope_handlers() -> void:
	disable_scope_registry.clear()
	disable_scope_registry[DISABLE_SCOPE_ALL_SKILLS] = Callable(self, "_disable_scope_all_skills")

func _is_valid_disable_mode(mode: String) -> bool:
	match mode:
		DISABLE_MODE_FIXED_SINGLE, DISABLE_MODE_FIXED_GROUP, DISABLE_MODE_PICK_OPPONENT_SPECIAL:
			return true
		_:
			return false

func _infer_disable_mode(entry: Dictionary) -> String:
	var explicit_mode := str(entry.get("disable_mode", "")).strip_edges().to_upper()
	if explicit_mode != "":
		return explicit_mode

	var target_ids: Array[int] = _array_to_int_array(entry.get("skill_target_ids", []))
	var target_raw := str(entry.get("skill_target_raw", "")).strip_edges()
	if target_ids.is_empty():
		return DISABLE_MODE_PICK_OPPONENT_SPECIAL
	if target_raw.contains("(") or target_raw.contains(",") or target_raw.contains(";") or target_ids.size() > 1:
		return DISABLE_MODE_FIXED_GROUP
	return DISABLE_MODE_FIXED_SINGLE

func _build_disable_check_desc(mode: String, target_ids: Array[int], watcher: Dictionary) -> String:
	match mode:
		DISABLE_MODE_FIXED_SINGLE:
			return "检查单目标: %s" % _target_ids_to_card_names_text(target_ids)
		DISABLE_MODE_FIXED_GROUP:
			return "检查组目标: %s" % _target_ids_to_card_names_text(target_ids)
		DISABLE_MODE_PICK_OPPONENT_SPECIAL:
			var selected_name := str(watcher.get("selected_card_name", "")).strip_edges()
			if selected_name == "":
				return "检查待选目标（牌堆）"
			return "检查已选目标: %s" % selected_name
		_:
			return "检查禁用目标"

func _resolve_disable_pick_target(
	owner: Player,
	target_player: Player,
	watcher: Dictionary,
	waive_as_success: bool = false
) -> Dictionary:
	var events: Array = []
	var candidates = _collect_disable_pick_candidates(target_player)
	if candidates.is_empty():
		events.append(_make_event_by_source(
			owner,
			int(watcher.get("source_card_id", -1)),
			str(watcher.get("source_card_name", "未知卡牌")),
			"DISABLE_SKILL",
			"禁用技能",
			STAGE_FAILED,
			"无可选目标，禁用监视结束",
			{"mode": DISABLE_MODE_PICK_OPPONENT_SPECIAL}
		))
		return {"ok": false, "waived": false, "events": events}

	var selected_card: Card = null
	if owner != null and owner.is_ai_player():
		selected_card = _choose_disable_target_for_ai(candidates)
	else:
		if not prompt_callback.is_valid():
			selected_card = candidates[0].get("card", null) as Card
		else:
			var options: Array = []
			var token_to_card: Dictionary = {}
			for candidate in candidates:
				var card: Card = candidate.get("card", null) as Card
				if card == null:
					continue
				var token := str(card.get_instance_id())
				var zone_text := str(candidate.get("zone", "未知区域"))
				options.append({
						"id": token,
						"label": "%s（%s）" % [card.Name, zone_text],
						"description": "卡牌ID: %d / BaseID: %d" % [card.ID, card.BaseID],
						"card_id": card.ID,
						"base_id": card.BaseID,
						"pinyin_name": card.PinyinName,
					})
				token_to_card[token] = card

			var choice = await prompt_callback.call({
				"type": "DISABLE_TARGET_PICK",
				"title": "禁用技能目标选择",
				"description": "请选择一张对手牌堆中的特殊卡作为禁用目标",
				"allow_cancel": true,
				"options": options,
			})
			var choice_token := str(choice)
			if choice_token == "" or choice_token == "cancel":
				if waive_as_success:
					events.append(_make_event_by_source(
						owner,
						int(watcher.get("source_card_id", -1)),
						str(watcher.get("source_card_name", "未知卡牌")),
						"DISABLE_SKILL",
						"禁用技能",
						STAGE_TRIGGER,
						"发动成功（玩家放弃）",
						{"mode": DISABLE_MODE_PICK_OPPONENT_SPECIAL}
					))
					return {"ok": false, "waived": true, "events": events}
				events.append(_make_event_by_source(
					owner,
					int(watcher.get("source_card_id", -1)),
					str(watcher.get("source_card_name", "未知卡牌")),
					"DISABLE_SKILL",
					"禁用技能",
					STAGE_FAILED,
					"未选择目标，禁用监视结束",
					{"mode": DISABLE_MODE_PICK_OPPONENT_SPECIAL}
				))
				return {"ok": false, "waived": false, "events": events}
			selected_card = token_to_card.get(choice_token, null) as Card

	if selected_card == null:
		events.append(_make_event_by_source(
			owner,
			int(watcher.get("source_card_id", -1)),
			str(watcher.get("source_card_name", "未知卡牌")),
			"DISABLE_SKILL",
			"禁用技能",
			STAGE_FAILED,
			"选择目标无效，禁用监视结束",
			{"mode": DISABLE_MODE_PICK_OPPONENT_SPECIAL}
		))
		return {"ok": false, "waived": false, "events": events}

	watcher["selected_instance_id"] = selected_card.get_instance_id()
	watcher["selected_card_id"] = selected_card.ID
	watcher["selected_card_name"] = selected_card.Name
	events.append(_make_event_by_source(
		owner,
		int(watcher.get("source_card_id", -1)),
		str(watcher.get("source_card_name", "未知卡牌")),
		"DISABLE_SKILL",
		"禁用技能",
		STAGE_CHECK,
		"已选定目标: %s" % selected_card.Name,
		{
			"mode": DISABLE_MODE_PICK_OPPONENT_SPECIAL,
			"target_ids": [selected_card.ID, selected_card.BaseID],
		}
	))

	return {"ok": true, "waived": false, "events": events}

func _collect_disable_pick_candidates(target_player: Player) -> Array:
	var candidates: Array = []
	if target_player == null:
		return candidates

	var seen: Dictionary = {}
	var all_cards: Array[Card] = _collect_special_cards_from_player_deal(target_player)
	for card in all_cards:
		if card == null:
			continue
		var instance_id := card.get_instance_id()
		if seen.has(instance_id):
			continue
		if not card.Special:
			continue
		if _is_card_already_disabled(card):
			continue
		seen[instance_id] = true
		candidates.append({
			"card": card,
			"zone": "牌堆",
		})
	return candidates

func _collect_cards_from_player_deal(player: Player) -> Array[Card]:
	var result: Array[Card] = []
	if player == null:
		return result

	for card in player.deal_cards.values():
		if card is Card:
			result.append(card)
	return result

func _collect_special_cards_from_player_deal(player: Player) -> Array[Card]:
	var result: Array[Card] = []
	if player == null:
		return result

	for card in player.deal_cards.values():
		if card is Card and card.Special:
			result.append(card)
	return result

func _find_target_cards_in_deal(player: Player, target_ids: Array[int]) -> Array[Card]:
	var result: Array[Card] = []
	if player == null:
		return result

	var seen: Dictionary = {}
	for card in _collect_cards_from_player_deal(player):
		if card == null:
			continue
		if not _card_matches_target_ids(card, target_ids):
			continue
		var instance_id := card.get_instance_id()
		if seen.has(instance_id):
			continue
		seen[instance_id] = true
		result.append(card)
	return result

func _cards_to_name_text(cards: Array[Card]) -> String:
	var names: Array[String] = []
	var seen: Dictionary = {}
	for card in cards:
		if card == null:
			continue
		var instance_id := card.get_instance_id()
		if seen.has(instance_id):
			continue
		seen[instance_id] = true
		names.append(card.Name)
	if names.is_empty():
		return "无"
	return "、".join(names)

func _get_opponent_player(player: Player) -> Player:
	if match_state == null or player == null:
		return null
	return match_state.get_opponent(player)

func _find_disable_hit_cards(watcher: Dictionary, target_player: Player, check_pool: Array[Card]) -> Array[Card]:
	var mode := str(watcher.get("mode", DISABLE_MODE_FIXED_SINGLE))
	var hits: Array[Card] = []
	var seen: Dictionary = {}

	if mode == DISABLE_MODE_PICK_OPPONENT_SPECIAL:
		var selected_instance_id := int(watcher.get("selected_instance_id", 0))
		if selected_instance_id <= 0:
			return hits
		var cards_to_check: Array[Card] = _collect_special_cards_from_player_deal(target_player)
		for card in cards_to_check:
			if card == null:
				continue
			if card.get_instance_id() == selected_instance_id:
				hits.append(card)
				break
		return hits

	var target_ids: Array[int] = _array_to_int_array(watcher.get("target_ids", []))
	var cards_to_check: Array[Card] = check_pool
	if cards_to_check.is_empty():
		cards_to_check = _collect_cards_from_player_deal(target_player)
	for card in cards_to_check:
		if card == null:
			continue
		if not _card_matches_target_ids(card, target_ids):
			continue
		var instance_id := card.get_instance_id()
		if seen.has(instance_id):
			continue
		seen[instance_id] = true
		hits.append(card)

	return hits

func _card_matches_target_ids(card: Card, target_ids: Array[int]) -> bool:
	if card == null:
		return false
	return target_ids.has(card.ID) or target_ids.has(card.BaseID)

func _apply_disable_scope_to_card(scope: String, card: Card) -> bool:
	var normalized_scope := scope.strip_edges().to_upper()
	if normalized_scope == "":
		normalized_scope = DISABLE_SCOPE_ALL_SKILLS
	var handler: Callable = disable_scope_registry.get(normalized_scope, Callable())
	if not handler.is_valid():
		return false
	return bool(handler.call(card))

func _disable_scope_all_skills(card: Card) -> bool:
	if card == null:
		return false
	_disable_all_skills_for_card(card)
	return true

func _is_card_already_disabled(card: Card) -> bool:
	if card == null:
		return true
	register_card(card)
	var count = CardSkill.get_skill_num_for_card(card)
	if count <= 0:
		return true
	for i in range(1, count + 1):
		if int(skill_states.get(_state_key(card.ID, i), SkillUseState.READY)) != SkillUseState.DISABLED:
			return false
	if card.has_meta("copied_skill_type"):
		if int(skill_states.get(_copied_state_key(card.ID), SkillUseState.READY)) != SkillUseState.DISABLED:
			return false
	return true

func _choose_disable_target_for_ai(candidates: Array) -> Card:
	var best_card: Card = null
	var best_score := -999999
	for candidate in candidates:
		var card: Card = candidate.get("card", null) as Card
		if card == null:
			continue
		var threat = _estimate_card_threat(card)
		if best_card == null or threat > best_score or (threat == best_score and card.ID < best_card.ID):
			best_card = card
			best_score = threat
	return best_card

func _estimate_card_threat(card: Card) -> int:
	if card == null:
		return -999999
	var score := int(card.Score)
	var skill_count = CardSkill.get_skill_num_for_card(card)
	for i in range(1, skill_count + 1):
		match CardSkill.get_skill_type_by_index(card, i):
			CardSkill.SKILL_TYPE.COPY_SKILL:
				score += 50
			CardSkill.SKILL_TYPE.EXCHANGE_CARD:
				score += 45
			CardSkill.SKILL_TYPE.DISABLE_SKILL:
				score += 40
			CardSkill.SKILL_TYPE.ADD_SCORE:
				score += 35
			CardSkill.SKILL_TYPE.GUARANTEE_APPEAR:
				score += 25
			CardSkill.SKILL_TYPE.INCREASE_APPEAR:
				score += 20
			CardSkill.SKILL_TYPE.OPEN_OPPONENT_HAND:
				score += 15
			_:
				score += 1
	return score

func _normalize_queue_entry(raw_entry) -> Dictionary:
	if raw_entry == null:
		return {}
	if raw_entry is Dictionary:
		return raw_entry
	if raw_entry is Object:
		return {
			"owner": raw_entry.get("owner"),
			"source_card_id": int(raw_entry.get("source_card_id")),
			"source_card_name": str(raw_entry.get("source_card_name")),
			"target_ids": _array_to_int_array(raw_entry.get("target_ids")),
			"probability": float(raw_entry.get("probability")),
		}
	return {}
