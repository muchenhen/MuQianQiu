extends Node2D

@onready var player_a_score: Label = $Player_A_Score
@onready var player_b_score: Label = $Player_B_Score
@onready var result: Label = $Result
@onready var button_back_to_main = $Button_BackToMain

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_back_to_main.connect("pressed", Callable(self, "on_button_back_to_main_pressed"))

func set_result(p_player_a_score:int, p_player_b_score:int) -> void:
	if p_player_a_score == p_player_b_score:
		result.text = "平局！"
		result.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	else:
		var is_player_a_win = p_player_a_score > p_player_b_score
		if is_player_a_win:
			result.text = "你赢了！"
			result.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		else:
				result.text = "你输了！"
				result.add_theme_color_override("font_color", Color(1, 1, 1, 1))

	player_a_score.text = str(p_player_a_score)
	player_b_score.text = str(p_player_b_score)

func on_button_back_to_main_pressed():
	GameManager.instance.back_to_main()
