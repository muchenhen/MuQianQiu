extends Node

class_name SkillManager

static var instance: SkillManager = null

var resolver: SkillResolver = null
var match_state: MatchState = null

# 获取单例实例
static func get_instance() -> SkillManager:
	if instance == null:
		instance = SkillManager.new()
	return instance

func initialize(state: MatchState) -> void:
	match_state = state
	resolver = SkillResolver.new()
	resolver.initialize(state)

func set_prompt_callback(cb: Callable) -> void:
	if resolver:
		resolver.set_prompt_callback(cb)

func reset_for_match() -> void:
	if resolver:
		resolver.reset_for_match()

func register_card(card: Card) -> void:
	if resolver:
		resolver.register_card(card)

func resolve_turn_skills(current_player: Player, opponent_player: Player, action_cards: Array[Card]) -> Dictionary:
	if resolver == null:
		return {}
	return await resolver.resolve_turn_skills(current_player, opponent_player, action_cards)

func resolve_supply_slot(card_manager: CardManager) -> Dictionary:
	if resolver == null:
		return {"card": null, "events": []}
	return resolver.resolve_supply_slot(card_manager)

func check_disable_on_opponent_acquire(
	acquiring_player: Player,
	opponent_player: Player,
	acquired_cards: Array[Card] = []
) -> Array:
	if resolver == null:
		return []
	return await resolver.check_disable_on_opponent_acquire(acquiring_player, opponent_player, acquired_cards)

func check_guarantee_card_skills() -> bool:
	if resolver == null:
		return false
	return resolver.has_pending_guarantee()

func check_increased_probability_skills() -> bool:
	if resolver == null:
		return false
	return resolver.has_pending_increase()
