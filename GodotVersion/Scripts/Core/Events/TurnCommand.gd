extends RefCounted

class_name TurnCommand

enum Type {
	SELECT_HAND_CARD,
	SELECT_PUBLIC_CARD,
	EXCHANGE_HAND_CARD,
	SKILL_CHOICE,
	SKILL_TARGET,
	WAIVE_SKILL
}

var type: Type
var payload: Dictionary

func _init(p_type: Type = Type.SELECT_HAND_CARD, p_payload: Dictionary = {}):
	type = p_type
	payload = p_payload

static func create(p_type: Type, p_payload: Dictionary = {}) -> TurnCommand:
	return TurnCommand.new(p_type, p_payload)
