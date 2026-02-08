extends Control

class_name UI_ExchangeResult

# ============ 动画时长配置（秒） ============
@export var card_exchange_duration: float = 0.8 # 卡牌交换动画时长
@export var story_change_duration: float = 0.6 # 故事变化动画时长
@export var score_change_duration: float = 0.5 # 分数变化动画时长
@export var delay_between_stages: float = 0.3 # 阶段之间的延迟

# ============ UI尺寸配置 ============
@export var card_display_size: Vector2 = Vector2(120, 180) # 卡牌显示大小

# ============ UI节点引用 ============
@onready var bg: ColorRect = $ColorRect_BG
@onready var title_label: Label = $VBoxContainer/Title
@onready var player_a_panel: Control = $VBoxContainer/HBoxContainer/PlayerA_Panel
@onready var player_b_panel: Control = $VBoxContainer/HBoxContainer/PlayerB_Panel
@onready var confirm_button: Button = $VBoxContainer/ConfirmButton

# 玩家A相关节点
@onready var player_a_name: Label = $VBoxContainer/HBoxContainer/PlayerA_Panel/VBox/PlayerName
@onready var player_a_lost_card: TextureRect = $VBoxContainer/HBoxContainer/PlayerA_Panel/VBox/CardExchange/LostCardBox/LostCard
@onready var player_a_gained_card: TextureRect = $VBoxContainer/HBoxContainer/PlayerA_Panel/VBox/CardExchange/GainedCardBox/GainedCard
@onready var player_a_old_score: Label = $VBoxContainer/HBoxContainer/PlayerA_Panel/VBox/ScoreChange/OldScore
@onready var player_a_new_score: Label = $VBoxContainer/HBoxContainer/PlayerA_Panel/VBox/ScoreChange/NewScore
@onready var player_a_score_diff: Label = $VBoxContainer/HBoxContainer/PlayerA_Panel/VBox/ScoreChange/ScoreDiff
@onready var player_a_details: RichTextLabel = $VBoxContainer/HBoxContainer/PlayerA_Panel/VBox/Details

# 玩家B相关节点
@onready var player_b_name: Label = $VBoxContainer/HBoxContainer/PlayerB_Panel/VBox/PlayerName
@onready var player_b_lost_card: TextureRect = $VBoxContainer/HBoxContainer/PlayerB_Panel/VBox/CardExchange/LostCardBox/LostCard
@onready var player_b_gained_card: TextureRect = $VBoxContainer/HBoxContainer/PlayerB_Panel/VBox/CardExchange/GainedCardBox/GainedCard
@onready var player_b_old_score: Label = $VBoxContainer/HBoxContainer/PlayerB_Panel/VBox/ScoreChange/OldScore
@onready var player_b_new_score: Label = $VBoxContainer/HBoxContainer/PlayerB_Panel/VBox/ScoreChange/NewScore
@onready var player_b_score_diff: Label = $VBoxContainer/HBoxContainer/PlayerB_Panel/VBox/ScoreChange/ScoreDiff
@onready var player_b_details: RichTextLabel = $VBoxContainer/HBoxContainer/PlayerB_Panel/VBox/Details

# ============ 数据存储 ============
var exchange_data: Dictionary = {}
var is_animating: bool = false

# ============ 信号 ============
signal closed

func _ready() -> void:
	visible = false
	confirm_button.pressed.connect(_on_confirm_pressed)

## 展示交换结果
## data格式:
## {
##   "player_a": Player,
##   "player_b": Player,
##   "player_a_lost_card": Card,
##   "player_a_gained_card": Card,
##   "player_b_lost_card": Card,  # 可能为null（如果从手牌交换）
##   "player_b_gained_card": Card,  # 可能为null
##   "player_a_old_score": int,
##   "player_a_new_score": int,
##   "player_b_old_score": int,
##   "player_b_new_score": int,
##   "player_a_logs": Array[ScoreOperationLog],
##   "player_b_logs": Array[ScoreOperationLog],
## }
func show_exchange_result(data: Dictionary) -> void:
	exchange_data = data
	visible = true
	is_animating = true
	
	# 确保UI全屏显示
	var viewport_size = get_viewport_rect().size
	size = viewport_size
	position = Vector2.ZERO
	
	# 初始化UI状态
	_setup_initial_state()
	
	# 开始动画序列
	_play_animation_sequence()

func _setup_initial_state() -> void:
	# 设置玩家名称
	var player_a: Player = exchange_data.get("player_a")
	var player_b: Player = exchange_data.get("player_b")
	
	if player_a:
		if player_a.name != "":
			player_a_name.text = player_a.name
		else:
			player_a_name.text = "玩家A"
	if player_b:
		if player_b.name != "":
			player_b_name.text = player_b.name
		else:
			player_b_name.text = "玩家B"
	
	# 初始时隐藏各元素，动画时逐步显示
	_set_panel_alpha(player_a_panel, 0.0)
	_set_panel_alpha(player_b_panel, 0.0)
	confirm_button.modulate.a = 0.0

func _set_panel_alpha(panel: Control, alpha: float) -> void:
	if panel:
		panel.modulate.a = alpha

func _play_animation_sequence() -> void:
	var tween = create_tween()
	
	# 阶段1: 显示面板
	tween.tween_property(player_a_panel, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(player_b_panel, "modulate:a", 1.0, 0.3)
	
	# 阶段2: 显示卡牌交换
	tween.tween_callback(_show_card_exchange)
	tween.tween_interval(card_exchange_duration)
	
	# 阶段3: 显示分数变化
	tween.tween_callback(_show_score_change)
	tween.tween_interval(score_change_duration)
	
	# 阶段4: 显示详细信息
	tween.tween_callback(_show_details)
	tween.tween_interval(delay_between_stages)
	
	# 阶段5: 显示确认按钮
	tween.tween_property(confirm_button, "modulate:a", 1.0, 0.2)
	
	tween.tween_callback(func(): is_animating = false)

func _show_card_exchange() -> void:
	# 玩家A失去的卡
	var a_lost: Card = exchange_data.get("player_a_lost_card")
	if a_lost and a_lost.texture_normal:
		player_a_lost_card.texture = a_lost.texture_normal
		player_a_lost_card.custom_minimum_size = card_display_size
	
	# 玩家A获得的卡
	var a_gained: Card = exchange_data.get("player_a_gained_card")
	if a_gained and a_gained.texture_normal:
		player_a_gained_card.texture = a_gained.texture_normal
		player_a_gained_card.custom_minimum_size = card_display_size
	
	# 玩家B失去的卡
	var b_lost: Card = exchange_data.get("player_b_lost_card")
	if b_lost and b_lost.texture_normal:
		player_b_lost_card.texture = b_lost.texture_normal
		player_b_lost_card.custom_minimum_size = card_display_size
	
	# 玩家B获得的卡
	var b_gained: Card = exchange_data.get("player_b_gained_card")
	if b_gained and b_gained.texture_normal:
		player_b_gained_card.texture = b_gained.texture_normal
		player_b_gained_card.custom_minimum_size = card_display_size

func _show_score_change() -> void:
	var a_old: int = exchange_data.get("player_a_old_score", 0)
	var a_new: int = exchange_data.get("player_a_new_score", 0)
	var b_old: int = exchange_data.get("player_b_old_score", 0)
	var b_new: int = exchange_data.get("player_b_new_score", 0)
	
	# 玩家A分数
	player_a_old_score.text = "原分数: %d" % a_old
	player_a_new_score.text = "新分数: %d" % a_new
	var a_diff = a_new - a_old
	player_a_score_diff.text = "%+d" % a_diff
	player_a_score_diff.add_theme_color_override("font_color", Color.GREEN if a_diff >= 0 else Color.RED)
	
	# 玩家B分数
	player_b_old_score.text = "原分数: %d" % b_old
	player_b_new_score.text = "新分数: %d" % b_new
	var b_diff = b_new - b_old
	player_b_score_diff.text = "%+d" % b_diff
	player_b_score_diff.add_theme_color_override("font_color", Color.GREEN if b_diff >= 0 else Color.RED)

func _show_details() -> void:
	# 玩家A详细信息
	var a_logs: Array = exchange_data.get("player_a_logs", [])
	player_a_details.text = _format_score_logs(a_logs)
	
	# 玩家B详细信息
	var b_logs: Array = exchange_data.get("player_b_logs", [])
	player_b_details.text = _format_score_logs(b_logs)

func _format_score_logs(logs: Array) -> String:
	if logs.is_empty():
		return "无变化"
	
	var text = ""
	for log_item in logs:
		var op_type = log_item.operation_type
		var score = log_item.score
		var desc = log_item.description
		
		# 根据操作类型添加前缀
		var prefix = "+" if op_type == ScoreManager.ScoreOperationType.ADD else "-"
		var color = "green" if op_type == ScoreManager.ScoreOperationType.ADD else "red"
		
		text += "[color=%s]%s%d[/color] %s\n" % [color, prefix, score, desc]
	
	return text.strip_edges()

func _on_confirm_pressed() -> void:
	# 立即关闭，不管动画是否完成
	visible = false
	closed.emit()

## 等待用户确认（异步）
func wait_for_confirmation() -> void:
	await closed
