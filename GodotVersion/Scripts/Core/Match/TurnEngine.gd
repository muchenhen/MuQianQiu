extends Node

class_name TurnEngine

enum Phase {
	IDLE,
	ROUND_START,
	SUPPLY_PUBLIC,
	CHECK_PLAYABLE,
	WAIT_ACTION,
	RESOLVE_ACTION,
	ROUND_END,
	GAME_END
}

signal turn_event_emitted(event: TurnEvent)

var match_state: MatchState = null
var current_phase: Phase = Phase.IDLE

var _waiting_for_action_input: bool = false
var _waiting_for_action_resolution: bool = false

func initialize(state: MatchState) -> void:
	match_state = state
	current_phase = Phase.IDLE
	_waiting_for_action_input = false
	_waiting_for_action_resolution = false

func start_match() -> void:
	if match_state == null:
		push_error("TurnEngine: match_state is null.")
		return

	match_state.round_index = 1
	_begin_round()

func submit_public_supply_completed() -> void:
	if current_phase != Phase.SUPPLY_PUBLIC:
		return

	current_phase = Phase.CHECK_PLAYABLE
	_check_playable_state()

func notify_exchange_completed(success: bool) -> void:
	if current_phase != Phase.CHECK_PLAYABLE:
		return

	if not success:
		_game_end("exchange_failed")
		return

	_check_playable_state()

func submit_action_selection(hand_card: Card, public_card: Card) -> void:
	if not _waiting_for_action_input:
		return

	var actor = get_active_player()
	if actor == null:
		return

	if hand_card == null or public_card == null:
		return

	if not actor.is_card_in_hand(hand_card):
		return

	if hand_card.Season != public_card.Season:
		return

	_waiting_for_action_input = false
	_waiting_for_action_resolution = true
	current_phase = Phase.RESOLVE_ACTION

	match_state.last_selected_hand_card = hand_card
	match_state.last_selected_public_card = public_card

	_emit_event(TurnEvent.Type.CARDS_MATCHED, {
		"player": actor,
		"hand_card": hand_card,
		"public_card": public_card,
	})

func notify_action_resolved(action_cards: Array[Card] = []) -> void:
	if not _waiting_for_action_resolution:
		return

	_waiting_for_action_resolution = false
	match_state.last_action_cards = action_cards.duplicate()

	current_phase = Phase.ROUND_END
	_emit_event(TurnEvent.Type.ROUND_ENDED, {
		"round_index": match_state.round_index,
		"player": match_state.active_player,
	})

	match_state.round_index += 1
	_begin_round()

func get_active_player() -> Player:
	return match_state.active_player if match_state else null

func _begin_round() -> void:
	if match_state.round_index > match_state.config.max_round:
		_game_end("max_round_reached")
		return

	current_phase = Phase.ROUND_START
	match_state.active_player = match_state.get_active_player_by_round()

	_emit_event(TurnEvent.Type.ROUND_STARTED, {
		"round_index": match_state.round_index,
		"player": match_state.active_player,
	})

	current_phase = Phase.SUPPLY_PUBLIC
	_emit_event(TurnEvent.Type.PUBLIC_SUPPLY_REQUIRED, {
		"round_index": match_state.round_index,
		"player": match_state.active_player,
	})

func _check_playable_state() -> void:
	var actor = get_active_player()
	if actor == null:
		_game_end("no_active_player")
		return

	if not actor.has_hand_card():
		_game_end("active_player_no_hand_cards")
		return

	if not _player_has_playable_cards(actor):
		_emit_event(TurnEvent.Type.EXCHANGE_REQUIRED, {
			"round_index": match_state.round_index,
			"player": actor,
		})
		return

	current_phase = Phase.WAIT_ACTION
	_waiting_for_action_input = true
	_emit_event(TurnEvent.Type.ACTION_REQUIRED, {
		"round_index": match_state.round_index,
		"player": actor,
	})

func _player_has_playable_cards(player: Player) -> bool:
	if match_state == null or match_state.public_deal == null:
		return false

	var seasons = match_state.public_deal.get_choosable_seasons()
	for hand_card in player.get_all_hand_cards():
		if hand_card.Season in seasons:
			return true

	return false

func _game_end(reason: String) -> void:
	current_phase = Phase.GAME_END
	_waiting_for_action_input = false
	_waiting_for_action_resolution = false
	_emit_event(TurnEvent.Type.GAME_ENDED, {
		"reason": reason,
		"round_index": match_state.round_index if match_state else -1,
	})

func _emit_event(type: TurnEvent.Type, payload: Dictionary = {}) -> void:
	turn_event_emitted.emit(TurnEvent.create(type, payload))
