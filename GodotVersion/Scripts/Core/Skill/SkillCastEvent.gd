extends RefCounted

class_name SkillCastEvent

enum Stage {
	REGISTER,
	CHECK,
	TRIGGER,
	FAILED,
	WAIVED,
	INVALID
}

var round_index: int = 0
var actor_name: String = ""
var source_card_id: int = -1
var source_card_name: String = ""
var skill_code: String = ""
var skill_name: String = ""
var stage: Stage = Stage.TRIGGER
var result_text: String = ""
var payload: Dictionary = {}

func _init(
	p_round_index: int = 0,
	p_actor_name: String = "",
	p_source_card_id: int = -1,
	p_source_card_name: String = "",
	p_skill_code: String = "",
	p_skill_name: String = "",
	p_stage: Stage = Stage.TRIGGER,
	p_result_text: String = "",
	p_payload: Dictionary = {}
):
	round_index = p_round_index
	actor_name = p_actor_name
	source_card_id = p_source_card_id
	source_card_name = p_source_card_name
	skill_code = p_skill_code
	skill_name = p_skill_name
	stage = p_stage
	result_text = p_result_text
	payload = p_payload

static func stage_to_code(p_stage: Stage) -> String:
	match p_stage:
		Stage.REGISTER:
			return "REGISTER"
		Stage.CHECK:
			return "CHECK"
		Stage.TRIGGER:
			return "TRIGGER"
		Stage.FAILED:
			return "FAILED"
		Stage.WAIVED:
			return "WAIVED"
		Stage.INVALID:
			return "INVALID"
		_:
			return "TRIGGER"

static func stage_to_cn(p_stage: Stage) -> String:
	match p_stage:
		Stage.REGISTER:
			return "预备"
		Stage.CHECK:
			return "检查"
		Stage.TRIGGER:
			return "发动"
		Stage.FAILED:
			return "失败"
		Stage.WAIVED:
			return "放弃"
		Stage.INVALID:
			return "无效"
		_:
			return "发动"

func to_dict() -> Dictionary:
	return {
		"round_index": round_index,
		"actor_name": actor_name,
		"source_card_id": source_card_id,
		"source_card_name": source_card_name,
		"skill_code": skill_code,
		"skill_name": skill_name,
		"stage": stage_to_code(stage),
		"stage_cn": stage_to_cn(stage),
		"result_text": result_text,
		"payload": payload,
	}

