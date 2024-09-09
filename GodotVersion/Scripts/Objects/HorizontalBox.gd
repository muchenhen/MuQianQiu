@tool
extends ColorRect
class_name HorizontalBox

@export var item_padding: float = 10.0
@export var auto_layout: bool = true

func _enter_tree():
	if Engine.is_editor_hint():
		# 确保我们只添加一次按钮
		if not has_node("EditorLayoutButton"):
			add_layout_button()

func add_layout_button():
	var button = Button.new()
	button.name = "EditorLayoutButton"
	button.text = "Update Layout"
	button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	button.offset_left = -120
	button.offset_top = 10
	button.offset_right = -10
	button.offset_bottom = 40
	button.connect("pressed", Callable(self, "layout_items"))
	add_child(button)
	button.set_owner(get_tree().edited_scene_root)

func _ready():
	if not Engine.is_editor_hint():
		layout_items()

func layout_items():
	if not auto_layout and Engine.is_editor_hint():
		return

	var items = get_children()
	var item_count = items.size()
	
	if item_count == 0:
		return
	
	# 计算所有项目的总宽度
	var total_width = 0
	for item in items:
		if item is Control and item != $EditorLayoutButton:
			total_width += item.size.x
	
	# 添加间距到总宽度
	total_width += item_padding * (item_count - 1)
	
	# 计算起始 x 位置 (居中)
	var start_x = (size.x - total_width) / 2
	
	# 布局项目
	for item in items:
		if item is Control and item != $EditorLayoutButton:
			# 设置 x 位置
			item.set_position(Vector2(start_x, (size.y - item.size.y) / 2))
			
			# 更新下一个项目的起始 x 位置
			start_x += item.size.x + item_padding

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	var valid_children = false
	for child in get_children():
		if child is Control and child != $EditorLayoutButton:
			valid_children = true
			break
	if not valid_children:
		warnings.append("This node has no Control children to arrange.")
	return warnings
