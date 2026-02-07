extends RefCounted

class_name AIPerspective

var self_player: Player = null
var opponent_player: Player = null

var self_hand_cards: Array[Card] = []
var opponent_visible_hand_cards: Array[Card] = []
var public_cards: Array[Card] = []

var opponent_hand_count: int = 0
var opponent_hand_visible: bool = false

static func build(
	self_p: Player,
	opponent_p: Player,
	public_deal: PublicCardDeal,
	enable_opponent_visibility: bool,
	explicit_visible_cards: Array[Card] = []
) -> AIPerspective:
	var p = AIPerspective.new()
	p.self_player = self_p
	p.opponent_player = opponent_p
	p.self_hand_cards = self_p.get_all_hand_cards()
	p.public_cards = public_deal.get_all_public_cards()
	p.opponent_hand_count = opponent_p.get_all_hand_cards().size()
	p.opponent_hand_visible = enable_opponent_visibility

	if not explicit_visible_cards.is_empty():
		p.opponent_visible_hand_cards = explicit_visible_cards
	elif enable_opponent_visibility:
		p.opponent_visible_hand_cards = opponent_p.get_all_hand_cards()

	return p
