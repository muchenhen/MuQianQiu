extends RefCounted

class_name MatchState

var config: MatchConfig

var round_index: int = 0
var active_player: Player = null

var player_a: Player = null
var player_b: Player = null
var public_deal: PublicCardDeal = null
var card_manager: CardManager = null
var story_manager: StoryManager = null

var last_selected_hand_card: Card = null
var last_selected_public_card: Card = null
var last_action_cards: Array[Card] = []

# key: Player -> Array[card_id] that are temporarily visible
var revealed_opponent_hand_cards: Dictionary = {}

func initialize(
	p_config: MatchConfig,
	p_player_a: Player,
	p_player_b: Player,
	p_public_deal: PublicCardDeal,
	p_card_manager: CardManager,
	p_story_manager: StoryManager
) -> void:
	config = p_config
	player_a = p_player_a
	player_b = p_player_b
	public_deal = p_public_deal
	card_manager = p_card_manager
	story_manager = p_story_manager
	round_index = 0
	active_player = null
	last_selected_hand_card = null
	last_selected_public_card = null
	last_action_cards.clear()
	revealed_opponent_hand_cards.clear()

func get_active_player_by_round() -> Player:
	if round_index % 2 == 1:
		return player_a
	return player_b

func get_opponent(player: Player) -> Player:
	if player == player_a:
		return player_b
	return player_a
