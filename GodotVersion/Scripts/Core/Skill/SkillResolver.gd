extends RefCounted

class_name SkillResolver

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
var rng := RandomNumberGenerator.new()

func initialize(state: MatchState) -> void:
	match_state = state
	reset_for_match()

func reset_for_match() -> void:
	skill_states.clear()
	skill_queue.clear()
	rng.randomize()

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

func pick_card_for_supply(card_manager: CardManager) -> Card:
	var guarantee_entry = skill_queue.pop_next_guarantee()
	if guarantee_entry != null:
		for target_id in guarantee_entry.skill_target_ids:
			var guaranteed_card = card_manager.pop_card_by_id(target_id)
			if guaranteed_card != null:
				return guaranteed_card

	var increase_entry = skill_queue.pop_next_increase()
	if increase_entry != null:
		var probability = clampf(increase_entry.probability, 0.0, 1.0)
		if rng.randf() <= probability:
			for target_id in increase_entry.skill_target_ids:
				var increased_card = card_manager.pop_card_by_id(target_id)
				if increased_card != null:
					return increased_card

	return null

func resolve_turn_skills(
	current_player: Player,
	opponent_player: Player,
	action_cards: Array[Card],
	max_chain_steps: int = 16
) -> Dictionary:
	var result := {
		"triggered": [],
		"revealed_card_ids": [],
	}

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
			match entry.skill_type:
				CardSkill.SKILL_TYPE.COPY_SKILL:
					copy_entries.append(entry)
				CardSkill.SKILL_TYPE.EXCHANGE_CARD:
					exchange_entries.append(entry)
				CardSkill.SKILL_TYPE.DISABLE_SKILL:
					_apply_disable_skill(current_player, opponent_player, entry, result)
				CardSkill.SKILL_TYPE.OPEN_OPPONENT_HAND:
					_apply_open_hand_skill(current_player, opponent_player, entry, result)
				CardSkill.SKILL_TYPE.GUARANTEE_APPEAR:
					_enqueue_deferred_supply_skill(current_player, entry, true, result)
				CardSkill.SKILL_TYPE.INCREASE_APPEAR:
					_enqueue_deferred_supply_skill(current_player, entry, false, result)
				CardSkill.SKILL_TYPE.ADD_SCORE:
					# 由 ScoreManager 在 add_card_score 时处理
					pass

		# 按规则优先处理复制技能与交换卡牌
		for entry in copy_entries:
			_apply_copy_skill(current_player, opponent_player, entry, result)

		for entry in exchange_entries:
			var swapped_in_card = _apply_exchange_skill(current_player, opponent_player, entry, result)
			if swapped_in_card != null and swapped_in_card.Special:
				if _has_exchange_skill(swapped_in_card):
					_mark_exchange_skills_used(swapped_in_card)
				processing_queue.append(swapped_in_card)

	if chain_steps >= max_chain_steps:
		push_warning("SkillResolver: chain depth exceeded, force stop to avoid infinite loop.")

	return result

func _apply_copy_skill(current_player: Player, opponent_player: Player, entry: Dictionary, result: Dictionary) -> void:
	var candidate_cards = opponent_player.get_all_hand_cards()
	var target_special_cards: Array[Card] = []
	for card in candidate_cards:
		if card.Special:
			target_special_cards.append(card)

	if target_special_cards.is_empty():
		_set_entry_state(entry, SkillUseState.WAIVED)
		return

	var copied_from: Card = target_special_cards[0]
	var copied_entry = _get_first_non_copy_entry(copied_from)
	if copied_entry.is_empty():
		_set_entry_state(entry, SkillUseState.WAIVED)
		return

	var source_card: Card = entry.card
	source_card.set_meta("copied_skill_type", int(copied_entry.skill_type))
	source_card.set_meta("copied_skill_target_ids", copied_entry.skill_target_ids)
	source_card.set_meta("copied_skill_value", copied_entry.skill_value)
	_set_entry_state(entry, SkillUseState.USED)

	result.triggered.append({
		"skill": "COPY_SKILL",
		"card_id": source_card.ID,
		"from_card_id": copied_from.ID,
	})

func _apply_exchange_skill(current_player: Player, opponent_player: Player, entry: Dictionary, result: Dictionary) -> Card:
	var self_card = current_player.get_first_hand_card()
	var opp_card = opponent_player.get_first_hand_card()

	if self_card == null or opp_card == null:
		_set_entry_state(entry, SkillUseState.WAIVED)
		return null

	var swapped_in = current_player.swap_one_hand_card_with_player(opponent_player, self_card, opp_card)
	_set_entry_state(entry, SkillUseState.USED)

	# 交换后无效技能自动标记为已生效
	_mark_exchange_disable_skill_used(entry.card)

	result.triggered.append({
		"skill": "EXCHANGE_CARD",
		"card_id": entry.card.ID,
		"self_card_id": self_card.ID,
		"opponent_card_id": opp_card.ID,
	})

	return swapped_in

func _apply_disable_skill(current_player: Player, opponent_player: Player, entry: Dictionary, result: Dictionary) -> void:
	var target = _find_first_special_card_with_ready_skill(opponent_player)
	if target == null:
		_set_entry_state(entry, SkillUseState.WAIVED)
		return

	var skill_count = CardSkill.get_skill_num_for_card(target)
	for i in range(1, skill_count + 1):
		var key = _state_key(target.ID, i)
		if skill_states.get(key, SkillUseState.READY) == SkillUseState.READY:
			skill_states[key] = SkillUseState.DISABLED

	_set_entry_state(entry, SkillUseState.USED)
	result.triggered.append({
		"skill": "DISABLE_SKILL",
		"card_id": entry.card.ID,
		"target_card_id": target.ID,
	})

func _apply_open_hand_skill(current_player: Player, opponent_player: Player, entry: Dictionary, result: Dictionary) -> void:
	var open_count = int(entry.skill_value) if int(entry.skill_value) > 0 else 1
	var opponent_cards = opponent_player.get_all_hand_cards()
	if opponent_cards.is_empty():
		_set_entry_state(entry, SkillUseState.USED)
		return

	open_count = mini(open_count, opponent_cards.size())
	var shuffled = opponent_cards.duplicate()
	shuffled.shuffle()
	var opened_ids: Array[int] = []
	for i in range(open_count):
		opened_ids.append(shuffled[i].ID)

	match_state.revealed_opponent_hand_cards[current_player] = opened_ids
	_set_entry_state(entry, SkillUseState.USED)

	for card_id in opened_ids:
		result.revealed_card_ids.append(card_id)

	result.triggered.append({
		"skill": "OPEN_OPPONENT_HAND",
		"card_id": entry.card.ID,
		"opened_ids": opened_ids,
	})

func _enqueue_deferred_supply_skill(current_player: Player, entry: Dictionary, is_guarantee: bool, result: Dictionary) -> void:
	var target_ids: Array[int] = entry.skill_target_ids
	if target_ids.is_empty():
		_set_entry_state(entry, SkillUseState.WAIVED)
		return

	if is_guarantee:
		skill_queue.enqueue_guarantee(current_player, entry.card.ID, target_ids)
		result.triggered.append({
			"skill": "GUARANTEE_APPEAR",
			"card_id": entry.card.ID,
			"targets": target_ids,
		})
	else:
		var probability = entry.skill_value
		if probability <= 0.0:
			probability = 0.5
		if probability > 1.0:
			probability = probability / 100.0
		skill_queue.enqueue_increase(current_player, entry.card.ID, target_ids, probability)
		result.triggered.append({
			"skill": "INCREASE_APPEAR",
			"card_id": entry.card.ID,
			"targets": target_ids,
			"probability": probability,
		})

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

	# 复制技能会把目标技能缓存到当前卡上，作为附加技能处理
	if card.has_meta("copied_skill_type"):
		var copied_entry = {
			"card": card,
			"skill_index": -1,
			"skill_type": int(card.get_meta("copied_skill_type")),
			"skill_target_ids": card.get_meta("copied_skill_target_ids") if card.has_meta("copied_skill_target_ids") else [],
			"skill_value": float(card.get_meta("copied_skill_value")) if card.has_meta("copied_skill_value") else 0.0,
			"is_copied": true,
		}
		if _get_entry_state(copied_entry) == SkillUseState.READY:
			entries.append(copied_entry)

	return entries

func _build_entry_from_skill_row(card: Card, skill_index: int) -> Dictionary:
	var row = table_manager.get_row("Skills", card.ID)
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

	var target_ids: Array[int] = []
	if row.has(target_id_key):
		target_ids = _parse_target_ids(row[target_id_key])

	var skill_value := 0.0
	if row.has(value_key):
		var value_raw = str(row[value_key]).strip_edges()
		if value_raw != "":
			skill_value = float(value_raw)

	return {
		"card": card,
		"skill_index": skill_index,
		"skill_type": CardSkill.string_to_skill_type(type_str),
		"skill_target_ids": target_ids,
		"skill_value": skill_value,
		"is_copied": false,
	}

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
		if entry.skill_type != CardSkill.SKILL_TYPE.COPY_SKILL and entry.skill_type != CardSkill.SKILL_TYPE.EXCHANGE_DISABLE_SKILL:
			return entry
	return {}

func _find_first_special_card_with_ready_skill(player: Player) -> Card:
	for card in player.get_all_hand_cards():
		if not card.Special:
			continue
		register_card(card)
		var count = CardSkill.get_skill_num_for_card(card)
		for i in range(1, count + 1):
			if skill_states.get(_state_key(card.ID, i), SkillUseState.READY) == SkillUseState.READY:
				return card
	return null

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
	var count = CardSkill.get_skill_num_for_card(card)
	for i in range(1, count + 1):
		if CardSkill.get_skill_type_by_index(card, i) == CardSkill.SKILL_TYPE.EXCHANGE_DISABLE_SKILL:
			skill_states[_state_key(card.ID, i)] = SkillUseState.USED

func _state_key(card_id: int, skill_index: int) -> String:
	return "%s_%s" % [str(card_id), str(skill_index)]

func _copied_state_key(card_id: int) -> String:
	return "%s_copied" % str(card_id)

func _get_entry_state(entry: Dictionary) -> SkillUseState:
	if bool(entry.get("is_copied", false)):
		return skill_states.get(_copied_state_key(entry.card.ID), SkillUseState.READY)
	return skill_states.get(_state_key(entry.card.ID, int(entry.skill_index)), SkillUseState.READY)

func _set_entry_state(entry: Dictionary, state: SkillUseState) -> void:
	if bool(entry.get("is_copied", false)):
		skill_states[_copied_state_key(entry.card.ID)] = state
	else:
		skill_states[_state_key(entry.card.ID, int(entry.skill_index))] = state

