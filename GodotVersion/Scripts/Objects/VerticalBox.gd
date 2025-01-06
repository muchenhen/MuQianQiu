@tool
extends ColorRect
class_name VerticalBox

@export var item_padding: float = 10.0
@export var auto_layout: bool = true

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
    
    # 计算所有项目的总高度
    var total_height = 0
    for item in items:
        if item is Control:
            total_height += item.size.y
    
    # 添加间距到总高度
    total_height += item_padding * (item_count - 1)
    
    # 计算起始 y 位置 (居中)
    var start_y = (size.y - total_height) / 2
    
    # 布局项目
    for item in items:
        if item is Control:
            # 设置位置，水平居中，垂直依次排列
            item.set_position(Vector2((size.x - item.size.x) / 2, start_y))
            
            # 更新下一个项目的起始 y 位置
            start_y += item.size.y + item_padding

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