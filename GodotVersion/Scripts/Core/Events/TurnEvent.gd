extends RefCounted

class_name TurnEvent

enum Type {
	ROUND_STARTED,
	PUBLIC_SUPPLY_REQUIRED,
	PUBLIC_SUPPLIED,
	EXCHANGE_REQUIRED,
	ACTION_REQUIRED,
	CARDS_MATCHED,
	SKILL_TRIGGERED,
	SKILL_PROMPT,
	SCORE_CHANGED,
	STORY_COMPLETED,
	ROUND_ENDED,
	GAME_ENDED
}

var type: Type
var payload: Dictionary

func _init(p_type: Type, p_payload: Dictionary = {}):
	type = p_type
	payload = p_payload

static func create(p_type: Type, p_payload: Dictionary = {}) -> TurnEvent:
	return TurnEvent.new(p_type, p_payload)
