extends RefCounted

class_name SkillResolver
const SkillCastEventScript = preload("res://Scripts/Core/Skill/SkillCastEvent.gd")
const STAGE_REGISTER = SkillCastEventScript.Stage.REGISTER
const STAGE_CHECK = SkillCastEventScript.Stage.CHECK
const STAGE_TRIGGER = SkillCastEventScript.Stage.TRIGGER
const STAGE_FAILED = SkillCastEventScript.Stage.FAILED
const STAGE_WAIVED = SkillCastEventScript.Stage.WAIVED
const STAGE_INVALID = SkillCastEventScript.Stage.INVALID

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
var rng := RandomNumberGenerator.new()
var prompt_callback: Callable = Callable()

func initialize(state: MatchState) -> void:
	match_state = state
	reset_for_match()

func reset_for_match() -> void:
	skill_states.clear()
	disable_watchers.clear()
	skill_queue.clear()
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

func check_disable_on_opponent_acquire(acquiring_player: Player, opponent_player: Player) -> Array:
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

		var target_ids: Array[int] = _array_to_int_array(watcher.get("target_ids", []))
		var target_names_text = _target_ids_to_card_names_text(target_ids)
		events.append(_make_event_by_source(
			owner,
			int(watcher.get("source_card_id", -1)),
			str(watcher.get("source_card_name", "未知卡牌")),
			"DISABLE_SKILL",
			"禁用技能",
			STAGE_CHECK,
			"检查禁用目标: %s" % target_names_text,
			{"target_ids": target_ids}
		))

		var hit_cards: Array[Card] = []
		for deal_card in acquiring_player.deal_cards.values():
			if not (deal_card is Card):
				continue
			if not deal_card.Special:
				continue
			if target_ids.has(deal_card.ID) or target_ids.has(deal_card.BaseID):
				hit_cards.append(deal_card)

		if hit_cards.is_empty():
			events.append(_make_event_by_source(
				owner,
				int(watcher.get("source_card_id", -1)),
				str(watcher.get("source_card_name", "未知卡牌")),
				"DISABLE_SKILL",
				"禁用技能",
				STAGE_CHECK,
				"未命中目标，继续监视",
				{"target_ids": target_ids}
			))
			continue

		for target_card in hit_cards:
			_disable_all_skills_for_card(target_card)

		watcher["active"] = false
		var hit_names: Array[String] = []
		for c in hit_cards:
			hit_names.append(c.Name)

		events.append(_make_event_by_source(
			owner,
			int(watcher.get("source_card_id", -1)),
			str(watcher.get("source_card_name", "未知卡牌")),
			"DISABLE_SKILL",
			"禁用技能",
			STAGE_TRIGGER,
			"命中目标并已禁用: %s" % "、".join(hit_names),
			{"target_ids": target_ids}
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
					_register_disable_watch(current_player, entry, result_events)
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

		var swapped_in_card = _apply_exchange_skill(current_player, opponent_player, entry, result_events)
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
	var self_card = current_player.get_first_hand_card()
	var opp_card = opponent_player.get_first_hand_card()

	if self_card == null or opp_card == null:
		_set_entry_state(entry, SkillUseState.WAIVED)
		result_events.append(_make_event_from_entry(current_player, entry, STAGE_FAILED, "交换失败：任一方无可交换手牌"))
		return null

	var swapped_in = current_player.swap_one_hand_card_with_player(opponent_player, self_card, opp_card)
	_set_entry_state(entry, SkillUseState.USED)
	_mark_exchange_disable_skill_used(_entry_card(entry))

	result_events.append(_make_event_from_entry(
		current_player,
		entry,
		STAGE_TRIGGER,
		"交换了己方[%s]与对方[%s]" % [self_card.Name, opp_card.Name],
		{
			"self_card_id": self_card.ID,
			"opponent_card_id": opp_card.ID,
		}
	))

	return swapped_in

func _register_disable_watch(current_player: Player, entry: Dictionary, events: Array) -> void:
	var source_card: Card = _entry_card(entry)
	var target_ids: Array[int] = _array_to_int_array(entry.get("skill_target_ids", []))
	if target_ids.is_empty():
		_set_entry_state(entry, SkillUseState.USED)
		events.append(_make_event_from_entry(current_player, entry, STAGE_INVALID, "无目标配置，未生效"))
		return

	_set_entry_state(entry, SkillUseState.USED)
	disable_watchers.append({
		"active": true,
		"owner": current_player,
		"source_card_id": source_card.ID if source_card != null else -1,
		"source_card_name": source_card.Name if source_card != null else "未知卡牌",
		"target_ids": target_ids,
	})

	events.append(_make_event_from_entry(
		current_player,
		entry,
		STAGE_REGISTER,
		"已进入监视，目标: %s" % _target_ids_to_card_names_text(target_ids),
		{"target_ids": target_ids}
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
			"skill_index": -1,
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

	var target_ids: Array[int] = []
	if row.has(target_id_key):
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

	return {
		"card": card,
		"skill_index": skill_index,
		"skill_type": CardSkill.string_to_skill_type(type_str),
		"skill_target_ids": target_ids,
		"skill_target_name": target_name,
		"skill_target_type": target_type,
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
) :
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
) :
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
