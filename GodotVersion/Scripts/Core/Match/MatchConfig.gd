extends RefCounted

class_name MatchConfig

enum AIDifficulty {
	SIMPLE = 1,
	NORMAL = 2,
	HARD = 3
}

var selected_versions: Array[int] = []
var use_special_cards: bool = false
var ai_difficulty: int = AIDifficulty.SIMPLE
var opponent_hand_visible: bool = false
var max_round: int = 20

func duplicate_config() -> MatchConfig:
	var cfg = MatchConfig.new()
	cfg.selected_versions = selected_versions.duplicate()
	cfg.use_special_cards = use_special_cards
	cfg.ai_difficulty = ai_difficulty
	cfg.opponent_hand_visible = opponent_hand_visible
	cfg.max_round = max_round
	return cfg
