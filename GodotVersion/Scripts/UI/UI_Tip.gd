extends Control

class_name UI_Tip

## 提示消息显示时间（秒）
@export var display_duration: float = 2.0
## 淡入淡出动画时间（秒） 
@export var fade_duration: float = 0.3
## 是否在顶部显示
@export var show_at_top: bool = false
## 自定义显示位置（如果不使用默认位置）
@export var custom_position: Vector2 = Vector2.ZERO

var _timer: Timer
var _tween: Tween

@onready var panel = %Panel
@onready var label = %Label

func _ready() -> void:
	# 初始化为透明
	self.modulate.a = 0
	
	# 创建计时器
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

## 设置提示文本
func set_text(text: String) -> void:
	label.text = text
	
## 设置提示颜色
func set_color(color: Color) -> void:
	var style = panel.get_theme_stylebox("panel").duplicate()
	style.bg_color = color
	panel.add_theme_stylebox_override("panel", style)

## 显示提示
func show_tip() -> void:
	# 获取窗口大小
	var viewport_size = get_viewport_rect().size
	
	# 重置Control节点的位置和大小
	position = Vector2.ZERO
	size = viewport_size
	
	# 设置Panel的位置
	if show_at_top:
		panel.position = Vector2(
			viewport_size.x * 0.5 - panel.size.x * 0.5,  # 水平居中
			viewport_size.y * 0.15 - panel.size.y * 0.5   # 垂直位置在顶部附近
		)
	elif custom_position != Vector2.ZERO:
		panel.position = custom_position
	else:
		# 默认在屏幕中央
		panel.position = Vector2(
			viewport_size.x * 0.5 - panel.size.x * 0.5,
			viewport_size.y * 0.5 - panel.size.y * 0.5
		)
	
	# 创建动画
	if _tween:
		_tween.kill()
	
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "modulate:a", 1.0, fade_duration)
	_tween.tween_property(panel, "scale", Vector2(1.05, 1.05), 0.1)
	_tween.tween_property(panel, "scale", Vector2(1, 1), 0.1)
	
	# 启动计时器
	_timer.start(display_duration)

## 隐藏提示
func hide_tip() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	_tween.tween_callback(Callable(self, "queue_free"))

func _on_timer_timeout() -> void:
	hide_tip()

## 静态方法：快速显示一个提示
static func create_tip(text: String, duration: float = 2.0, color: Color = Color.TRANSPARENT) -> void:
	var ui_manager = UIManager.get_instance()
	var tip = ui_manager.create_ui_instance_for_multi("UI_Tip")
	
	if tip:
		tip.set_text(text)
		if color != Color.TRANSPARENT:
			tip.set_color(color)
		tip.display_duration = duration
		
		# 添加到UI树并显示
		ui_manager.open_ui_instance(tip)
		ui_manager.move_ui_instance_to_top(tip)
		tip.show_tip()
