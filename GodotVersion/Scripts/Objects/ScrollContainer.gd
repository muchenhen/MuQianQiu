extends ScrollContainer

var dragging = false
var drag_start_pos = Vector2()

func _ready() -> void:
	# 确保 ScrollContainer 可以接收输入
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 设置所有子节点不处理鼠标事件
	#for child in $VBoxContainer.get_children():
		#child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	gui_input.connect(_on_ScrollContainer_gui_input)

func _on_ScrollContainer_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			#print("Drag State: ", dragging)
				
	elif event is InputEventMouseMotion and dragging:
		# 直接使用relative获取鼠标移动的相对量
		var relative_motion = event.relative
		#print("Relative Motion: ", relative_motion)
		
		# 更新垂直和水平滚动
		scroll_vertical -= relative_motion.y
		scroll_horizontal -= relative_motion.x
		#print("New Scroll Position - V: ", scroll_vertical, " H: ", scroll_horizontal)
