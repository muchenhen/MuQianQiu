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
	var perspective = AIPerspective.build(actor, opponent, public_deal, opponent_hand_visible)

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

	for hand_card in perspective.self_hand_cards:
		for public_card in perspective.public_cards:
			if hand_card.Season != public_card.Season:
				continue

			var score = _evaluate_pair_score(state, perspective, hand_card, public_card)
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

func _evaluate_pair_score(
	state: MatchState,
	perspective: AIPerspective,
	hand_card: Card,
	public_card: Card
) -> float:
	var score := float(hand_card.Score + public_card.Score)

	# 特殊卡倾向
	if hand_card.Special:
		score += 6.0
	if public_card.Special:
		score += 8.0

	# 潜在故事相关性倾向
	if state != null and state.story_manager != null:
		var candidate_ids: Array = [hand_card.BaseID if hand_card.Special else hand_card.ID, public_card.BaseID if public_card.Special else public_card.ID]
		var related_story_ids = state.story_manager.get_relent_stories_id_by_cards_id(candidate_ids)
		score += float(related_story_ids.size()) * 1.5

	# 若可见对手手牌，尽量抢季节和高分牌
	if perspective.opponent_hand_visible:
		for card in perspective.opponent_visible_hand_cards:
			if card.Season == public_card.Season:
				score += 0.8

	return score
