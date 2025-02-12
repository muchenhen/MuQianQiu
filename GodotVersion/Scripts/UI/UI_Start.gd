extends Control

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
