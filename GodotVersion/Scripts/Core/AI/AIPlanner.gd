extends RefCounted

class_name AIPlanner

func choose_action(
	state: MatchState,
	actor: Player,
	opponent: Player,
	public_deal: PublicCardDeal,
	ai_level: int,
	opponent_hand_visible: bool
) -> Dictionary:
	var known_opponent_cards: Array[Card] = []
	var knows_all_opponent_cards := false

	# 简单/普通AI默认不知道对手手牌；只有通过“翻开对手手牌”记录到的卡才可见。
	if actor != null and actor.is_ai_player():
		known_opponent_cards = _get_ai_known_opponent_cards(state, actor, opponent)
		knows_all_opponent_cards = false
	else:
		# 非AI视角（保留现有兼容逻辑）
		knows_all_opponent_cards = opponent_hand_visible
		if knows_all_opponent_cards and opponent != null:
			known_opponent_cards = opponent.get_all_hand_cards()

	var perspective = AIPerspective.build(
		actor,
		opponent,
		public_deal,
		knows_all_opponent_cards,
		known_opponent_cards
	)

	match ai_level:
		MatchConfig.AIDifficulty.NORMAL:
			return _choose_normal_action(state, perspective)
		MatchConfig.AIDifficulty.HARD:
			return _choose_normal_action(state, perspective)
		_:
			return _choose_simple_action(perspective)

func _choose_simple_action(perspective: AIPerspective) -> Dictionary:
	for hand_card in perspective.self_hand_cards:
		for public_card in perspective.public_cards:
			if hand_card.Season == public_card.Season:
				return {
					"hand_card": hand_card,
					"public_card": public_card,
				}
	return {}

func _choose_normal_action(state: MatchState, perspective: AIPerspective) -> Dictionary:
	var best_score := -999999.0
	var best_hand: Card = null
	var best_public: Card = null
	var self_owned_ids = _collect_owned_card_id_set(perspective.self_player)

	for hand_card in perspective.self_hand_cards:
		for public_card in perspective.public_cards:
			if hand_card.Season != public_card.Season:
				continue

			var score = _evaluate_normal_story_progress(
				state,
				perspective.self_player,
				self_owned_ids,
				hand_card,
				public_card
			)
			if score > best_score:
				best_score = score
				best_hand = hand_card
				best_public = public_card

	if best_hand == null or best_public == null:
		return {}

	return {
		"hand_card": best_hand,
		"public_card": best_public,
	}

func _get_ai_known_opponent_cards(state: MatchState, actor: Player, opponent: Player) -> Array[Card]:
	var result: Array[Card] = []
	if state == null or actor == null or opponent == null:
		return result
	if not state.revealed_opponent_hand_cards.has(actor):
		return result

	var revealed_ids_raw = state.revealed_opponent_hand_cards.get(actor, [])
	if not (revealed_ids_raw is Array):
		return result

	var revealed_ids: Dictionary = {}
	for raw_id in revealed_ids_raw:
		revealed_ids[int(raw_id)] = true

	for card in opponent.get_all_hand_cards():
		if card == null:
			continue
		if revealed_ids.has(card.ID):
			result.append(card)
	return result

func _evaluate_normal_story_progress(
	state: MatchState,
	self_player: Player,
	owned_ids: Dictionary,
	hand_card: Card,
	public_card: Card
) -> float:
	var score := float(hand_card.Score + public_card.Score) * 0.2
	var after_ids: Dictionary = owned_ids.duplicate(true)
	after_ids[_card_effective_id(hand_card)] = true
	after_ids[_card_effective_id(public_card)] = true

	if state == null or state.story_manager == null:
		return score

	for story_id in state.story_manager.stories.keys():
		var story: Story = state.story_manager.stories[story_id]
		if _player_has_finished_story(self_player, int(story_id)):
			continue

		var before_missing = _count_story_missing_cards(story.cards_id, owned_ids)
		var after_missing = _count_story_missing_cards(story.cards_id, after_ids)
		if after_missing > before_missing:
			continue

		if after_missing == 0:
			score += 10000.0 + float(story.score) * 20.0
		elif after_missing < before_missing:
			var reduced = before_missing - after_missing
			score += float(reduced) * 1200.0
			score += float(story.cards_id.size() - after_missing) * 60.0
			score += 200.0 / float(after_missing)

	return score

func _collect_owned_card_id_set(player: Player) -> Dictionary:
	var owned: Dictionary = {}
	if player == null:
		return owned

	for card in player.deal_cards.values():
		if not (card is Card):
			continue
		owned[_card_effective_id(card)] = true
	return owned

func _card_effective_id(card: Card) -> int:
	if card == null:
		return -1
	return card.BaseID if card.Special else card.ID

func _count_story_missing_cards(story_card_ids: Array, owned_ids: Dictionary) -> int:
	var missing := 0
	for raw_id in story_card_ids:
		var cid := int(raw_id)
		if not owned_ids.has(cid):
			missing += 1
	return missing

func _player_has_finished_story(player: Player, story_id: int) -> bool:
	if player == null:
		return false
	for item in player.finished_stories:
		if item is Story and int(item.id) == story_id:
			return true
		if item is int and int(item) == story_id:
			return true
	return false
