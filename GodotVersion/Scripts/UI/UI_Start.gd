extends Control

const SETTINGS_FILE_PATH = "user://settings.cfg"

@onready var start_button = $StartButton
@onready var checkbox_1 = $Gujian1
@onready var checkbox_2 = $Gujian2
@onready var checkbox_3 = $Gujian3
@onready var special_card_checkbox = $SpecialCardCheckbox
@onready var button_setting: Button = $SettingButton

var ai_difficulty_option: OptionButton = null
var opponent_visibility_checkbox: CheckBox = null

func _ready() -> void:
	print("UI_Start ready")
	load_settings()
	_ensure_match_setting_controls()

	start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))
	checkbox_1.connect("state_changed", Callable(self, "_on_checkbox_1_toggled"))
	checkbox_2.connect("state_changed", Callable(self, "_on_checkbox_2_toggled"))
	checkbox_3.connect("state_changed", Callable(self, "_on_checkbox_3_toggled"))
	special_card_checkbox.connect("toggled", Callable(self, "_on_special_card_checkbox_toggled"))
	button_setting.connect("pressed", Callable(self, "_on_setting_button_pressed"))

	AudioManager.get_instance().play_bgm("QianQiu")

func _ensure_match_setting_controls() -> void:
	if ai_difficulty_option == null:
		ai_difficulty_option = OptionButton.new()
		ai_difficulty_option.name = "AIDifficultyOption"
		ai_difficulty_option.position = Vector2(905, 560)
		ai_difficulty_option.size = Vector2(260, 40)
		ai_difficulty_option.add_item("AI: 简单", MatchConfig.AIDifficulty.SIMPLE)
		ai_difficulty_option.add_item("AI: 普通", MatchConfig.AIDifficulty.NORMAL)
		ai_difficulty_option.add_item("AI: 困难", MatchConfig.AIDifficulty.HARD)
		add_child(ai_difficulty_option)
		ai_difficulty_option.item_selected.connect(Callable(self, "_on_ai_difficulty_selected"))

	if opponent_visibility_checkbox == null:
		opponent_visibility_checkbox = CheckBox.new()
		opponent_visibility_checkbox.name = "OpponentHandVisible"
		opponent_visibility_checkbox.position = Vector2(905, 610)
		opponent_visibility_checkbox.size = Vector2(420, 48)
		opponent_visibility_checkbox.text = "对手手牌可见（影响普通AI）"
		add_child(opponent_visibility_checkbox)
		opponent_visibility_checkbox.toggled.connect(Callable(self, "_on_opponent_visibility_toggled"))

	# 同步当前全局设置
	var current_level = GameManager.ai_difficulty
	for i in range(ai_difficulty_option.item_count):
		if ai_difficulty_option.get_item_id(i) == current_level:
			ai_difficulty_option.select(i)
			break

	opponent_visibility_checkbox.button_pressed = GameManager.opponent_hand_visible

func _on_start_button_pressed():
	print("Start button pressed")
	var count = GameManager.get_checked_count()
	if count != 2:
		print("目前只支持选择两个")
		return
	GameManager.start_new_game()

func _on_checkbox_1_toggled(is_checked: bool):
	GameManager.is_open_first = is_checked
	GameManager.update_choosed_versions()
	print("Checkbox 1 toggled: ", is_checked)

func _on_checkbox_2_toggled(is_checked: bool):
	GameManager.is_open_second = is_checked
	GameManager.update_choosed_versions()
	print("Checkbox 2 toggled: ", is_checked)

func _on_checkbox_3_toggled(is_checked: bool):
	GameManager.is_open_third = is_checked
	GameManager.update_choosed_versions()
	print("Checkbox 3 toggled: ", is_checked)

func _on_special_card_checkbox_toggled(is_checked: bool):
	GameManager.set_use_special_cards(is_checked)
	print("Special Card Checkbox toggled: ", is_checked)

func _on_ai_difficulty_selected(index: int):
	if ai_difficulty_option == null:
		return
	var difficulty = ai_difficulty_option.get_item_id(index)
	GameManager.set_ai_difficulty(difficulty)

func _on_opponent_visibility_toggled(visible: bool):
	GameManager.set_opponent_hand_visible(visible)

func _on_setting_button_pressed():
	print("Setting button pressed")
	var ui_setting = UIManager.get_instance().open_ui("UI_Setting")
	ui_setting.show()

func load_settings() -> void:
	var config = ConfigFile.new()
	var error = config.load(SETTINGS_FILE_PATH)
	if error != OK:
		print("加载设置时出错或文件不存在: ", error)
		return

	if config.has_section_key("audio", "bgm_volume"):
		var volume = config.get_value("audio", "bgm_volume")
		AudioManager.get_instance().set_bgm_volume(volume)

	if config.has_section_key("audio", "bgm_enabled"):
		var enabled = config.get_value("audio", "bgm_enabled")
		AudioManager.get_instance().set_bgm_enabled(enabled)

	if config.has_section_key("audio", "story_audio_enabled") and AudioManager.get_instance().has_method("set_story_audio_enabled"):
		var enabled = config.get_value("audio", "story_audio_enabled")
		AudioManager.get_instance().set_story_audio_enabled(enabled)

	print("已成功加载游戏设置")
