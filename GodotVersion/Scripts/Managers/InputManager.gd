extends Node

class_name InputManager

signal input_state_changed(is_blocked: bool)

var input_blocker: Button
var is_input_blocked: bool = false

func _ready():
	# 创建一个高层级的 CanvasLayer
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 128  # 设置一个很高的层级
	add_child(canvas_layer)
	
	# 创建一个覆盖整个屏幕的 Button
	input_blocker = Button.new()
	input_blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input_blocker.flat = true  # 使按钮完全透明
	input_blocker.focus_mode = Control.FOCUS_NONE  # 防止按钮获得焦点
	input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP  # 确保它能捕获所有鼠标事件
	input_blocker.visible = false
	
	# 连接按钮的pressed信号到一个空函数，以防止点击穿透
	input_blocker.pressed.connect(_on_blocker_pressed)
	
	# 将 Button 添加到 CanvasLayer
	canvas_layer.add_child(input_blocker)

func block_input() -> void:
	if not is_input_blocked:
		input_blocker.visible = true
		is_input_blocked = true
		print("Input blocked")
		input_state_changed.emit(true)
		var parent = get_parent()
		if parent:
			parent.move_child(self, -1)

func allow_input() -> void:
	if is_input_blocked:
		input_blocker.visible = false
		is_input_blocked = false
		print("Input allowed")
		input_state_changed.emit(false)
		var parent = get_parent()
		if parent:
			parent.move_child(self, 0)

func toggle_input() -> void:
	if is_input_blocked:
		allow_input()
	else:
		block_input()

func is_input_allowed() -> bool:
	return not is_input_blocked

# 空函数，用于防止点击穿透
func _on_blocker_pressed() -> void:
	pass
