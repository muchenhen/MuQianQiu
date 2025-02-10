@tool
extends ColorRect
class_name HorizontalBox

@export var item_padding: float = 10.0
@export var auto_layout: bool = true
@export var y_offset: float = 0.0

func _ready():
	if not Engine.is_editor_hint():
		layout_items()


func _process(_delta: float) -> void:
	# 只在编辑器中运行
	if not Engine.is_editor_hint():
		return
		
	# 这里是编辑器中的tick逻辑
	if auto_layout:
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
		if item is Control:
			total_width += item.size.x
	
	# 添加间距到总宽度
	total_width += item_padding * (item_count - 1)
	
	# 计算起始 x 位置 (居中)
	var start_x = (size.x - total_width) / 2
	
	# 布局项目
	for item in items:
		if item is Control:
			# 设置位置，加入y_offset偏移量
			var center_y = (size.y - item.size.y) / 2
			item.set_position(Vector2(start_x, center_y - y_offset))
			
			# 更新下一个项目的起始 x 位置
			start_x += item.size.x + item_padding

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	var valid_children = false
	for child in get_children():
		if child is Control:
			valid_children = true
			break
	if not valid_children:
		warnings.append("This node has no Control children to arrange.")
	return warnings
