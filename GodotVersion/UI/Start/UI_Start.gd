extends Control

class_name UI_Start

# 开始游戏 按钮
@onready var start_button = $StartButton

# 古一 Checkbox
@onready var checkbox_1 = $CheckBox_1
# 古二 Checkbox
@onready var checkbox_2 = $CheckBox_2
# 古三 Checkbox
@onready var checkbox_3 = $CheckBox_3

var is_open_first:bool = false
var is_open_second:bool = false
var is_open_third:bool = false

func _ready() -> void:
	start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))
	checkbox_1.connect("toggled", Callable(self, "_on_checkbox_1_toggled"))
	checkbox_2.connect("toggled", Callable(self, "_on_checkbox_2_toggled"))
	checkbox_3.connect("toggled", Callable(self, "_on_checkbox_3_toggled"))

func _on_start_button_pressed():
	print("Start button pressed")

	# 检查勾选数量 必须是 2 个
	var count = 0
	if is_open_first:
		count += 1
	if is_open_second:
		count += 1
	if is_open_third:
		count += 1

	if count != 2:
		print("目前只支持选择两个")
		return

	# 开始新游戏
	GameManager.instance.start_new_game()

func _on_checkbox_1_toggled(button_pressed:bool):
	is_open_first = button_pressed
	print("Checkbox 1 toggled: ", button_pressed)

func _on_checkbox_2_toggled(button_pressed:bool):
	is_open_second = button_pressed
	print("Checkbox 2 toggled: ", button_pressed)

func _on_checkbox_3_toggled(button_pressed:bool):
	is_open_third = button_pressed
	print("Checkbox 3 toggled: ", button_pressed)
