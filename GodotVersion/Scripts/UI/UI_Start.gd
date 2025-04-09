extends Control

# 设置文件路径
const SETTINGS_FILE_PATH = "user://settings.cfg"

# 开始游戏 按钮
@onready var start_button = $StartButton

# 古一 Checkbox
@onready var checkbox_1 = $Gujian1
# 古二 Checkbox
@onready var checkbox_2 = $Gujian2
# 古三 Checkbox
@onready var checkbox_3 = $Gujian3

@onready var button_setting:Button = $SettingButton

func _ready() -> void:
	print("UI_Start ready")
	
	# 游戏一开始就加载设置
	load_settings()
	
	start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))
	checkbox_1.connect("state_changed", Callable(self, "_on_checkbox_1_toggled"))
	checkbox_2.connect("state_changed", Callable(self, "_on_checkbox_2_toggled"))
	checkbox_3.connect("state_changed", Callable(self, "_on_checkbox_3_toggled"))
	button_setting.connect("pressed", Callable(self, "_on_setting_button_pressed"))
	AudioManager.get_instance().play_bgm("QianQiu")


func _on_start_button_pressed():
	print("Start button pressed")

	# 检查勾选数量 必须是 2 个
	var count = GameManager.instance.get_checked_count()
	if count != 2:
		print("目前只支持选择两个")
		return

	# 开始新游戏
	GameManager.instance.start_new_game()

func _on_checkbox_1_toggled(is_checked:bool):
	GameManager.instance.is_open_first = is_checked
	print("Checkbox 1 toggled: ", is_checked)

func _on_checkbox_2_toggled(is_checked:bool):
	GameManager.instance.is_open_second = is_checked
	print("Checkbox 2 toggled: ", is_checked)

func _on_checkbox_3_toggled(is_checked:bool):
	GameManager.instance.is_open_third = is_checked
	print("Checkbox 3 toggled: ", is_checked)


func _on_setting_button_pressed():
	print("Setting button pressed")
	var ui_setting = UIManager.instance.open_ui("UI_Setting")
	ui_setting.show()


# 从本地加载设置
func load_settings() -> void:
	var config = ConfigFile.new()
	var error = config.load(SETTINGS_FILE_PATH)
	
	# 如果文件不存在或有错误，使用默认设置
	if error != OK:
		print("加载设置时出错或文件不存在: ", error)
		return
	
	# 加载音量设置
	if config.has_section_key("audio", "bgm_volume"):
		var volume = config.get_value("audio", "bgm_volume")
		AudioManager.get_instance().set_bgm_volume(volume)
	
	# 加载BGM开关设置
	if config.has_section_key("audio", "bgm_enabled"):
		var enabled = config.get_value("audio", "bgm_enabled")
		AudioManager.get_instance().set_bgm_enabled(enabled)
	
	# 加载故事音频设置
	if config.has_section_key("audio", "story_audio_enabled") and AudioManager.get_instance().has_method("set_story_audio_enabled"):
		var enabled = config.get_value("audio", "story_audio_enabled")
		AudioManager.get_instance().set_story_audio_enabled(enabled)
	
	print("已成功加载游戏设置")
