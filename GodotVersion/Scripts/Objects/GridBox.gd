@tool
extends ColorRect
class_name GridBox

enum CustomLayoutDirection {
    TOP_LEFT,    # 从左上开始
    TOP_RIGHT,   # 从右上开始
    BOTTOM_LEFT, # 从左下开始
    BOTTOM_RIGHT # 从右下开始
}

@export var rows: int = 4
@export var columns: int = 5
@export var cell_padding: Vector2 = Vector2(10.0, 10.0)
@export var auto_layout: bool = true
@export var custom_layout_direction: CustomLayoutDirection = CustomLayoutDirection.TOP_LEFT
@export var auto_scale: bool = false
@export var min_scale: float = 0.1

func layout_items():
    if not auto_layout and Engine.is_editor_hint():
        return

    var items = get_children()
    var item_count = items.size()
    
    if item_count == 0:
        return
    
    # 计算最大的单元格尺寸
    var cell_size = Vector2.ZERO
    for item in items:
        if item is Control:
            cell_size.x = max(cell_size.x, item.size.x)
            cell_size.y = max(cell_size.y, item.size.y)
    
    # 计算总的网格尺寸 (使用原始cell_size)
    var grid_width = cell_size.x * columns + cell_padding.x * (columns - 1)
    var grid_height = cell_size.y * rows + cell_padding.y * (rows - 1)
    
    # 如果启用自动缩放，只缩放元素尺寸，保持间距不变
    var scale_factor = 1.0
    if auto_scale and (grid_width > size.x or grid_height > size.y):
        # 计算可用空间（减去所有padding后的空间）
        var available_width = size.x - (cell_padding.x * (columns - 1))
        var available_height = size.y - (cell_padding.y * (rows - 1))
        
        # 计算单个元素需要的缩放比例
        var scale_x = available_width / (cell_size.x * columns)
        var scale_y = available_height / (cell_size.y * rows)
        scale_factor = min(scale_x, scale_y)
        scale_factor = max(scale_factor, min_scale)
        
        # 只缩放元素尺寸，不缩放间距
        cell_size *= scale_factor
        
        # 使用原始padding重新计算网格尺寸
        grid_width = cell_size.x * columns + cell_padding.x * (columns - 1)
        grid_height = cell_size.y * rows + cell_padding.y * (rows - 1)
    
    # 计算起始位置 (网格居中)
    var start_pos = Vector2(
        (size.x - grid_width) / 2,
        (size.y - grid_height) / 2
    )
    
    # 创建位置数组
    var positions = []
    for row in range(rows):
        for col in range(columns):
            var pos = Vector2(
                start_pos.x + col * (cell_size.x + cell_padding.x),
                start_pos.y + row * (cell_size.y + cell_padding.y)
            )
            positions.append(pos)
    
    # 根据布局方向调整位置数组
    match layout_direction:
        CustomLayoutDirection.TOP_RIGHT:
            positions.reverse()
            for i in range(positions.size()):
                positions[i].x = size.x - positions[i].x - cell_size.x
        CustomLayoutDirection.BOTTOM_LEFT:
            positions.reverse()
            for i in range(positions.size()):
                positions[i].y = size.y - positions[i].y - cell_size.y
        CustomLayoutDirection.BOTTOM_RIGHT:
            positions.reverse()
            for i in range(positions.size()):
                positions[i].x = size.x - positions[i].x - cell_size.x
                positions[i].y = size.y - positions[i].y - cell_size.y
    
    # 布局项目
    var current_item = 0
    for pos in positions:
        if current_item >= item_count:
            break
            
        var item = items[current_item]
        if item is Control:
            # 设置缩放
            if auto_scale:
                item.scale = Vector2(scale_factor, scale_factor)
            else:
                item.scale = Vector2.ONE
                
            # 在单元格内居中
            var scaled_size = item.size * scale_factor
            var centered_pos = pos + (cell_size - scaled_size) / 2
            item.set_position(centered_pos)
        
        current_item += 1

func _ready():
    if not Engine.is_editor_hint():
        layout_items()
    resized.connect(_on_resized)

func _process(_delta: float) -> void:
    if not Engine.is_editor_hint():
        return
        
    if auto_layout:
        layout_items()

func _on_resized():
    if auto_layout:
        layout_items()

func _get_configuration_warnings() -> PackedStringArray:
    var warnings = PackedStringArray()
    
    if rows <= 0 or columns <= 0:
        warnings.append("Rows and columns must be greater than 0.")
    
    var valid_children = false
    for child in get_children():
        if child is Control:
            valid_children = true
            break
    if not valid_children:
        warnings.append("This node has no Control children to arrange.")
        
    return warnings