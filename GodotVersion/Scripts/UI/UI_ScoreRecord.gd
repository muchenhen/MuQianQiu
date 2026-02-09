extends Control

class_name UI_ScoreRecord

## 分数记录UI，用于展示玩家分数变化历史

const ROW_MIN_HEIGHT := 38.0
const PANEL_SIZE := Vector2(1120.0, 660.0)
const COLOR_SCORE_POSITIVE := Color(1.0, 0.9, 0.35, 1.0)
const COLOR_SCORE_NEGATIVE := Color(1.0, 0.45, 0.45, 1.0)
const COLOR_SCORE_NEUTRAL := Color(0.9, 0.9, 0.9, 1.0)

@onready var overlay: ColorRect = $Overlay
@onready var main_panel: PanelContainer = $MainPanel
@onready var title_label: Label = $MainPanel/Margin/VBox/Header/TitleLabel
@onready var close_button: Button = $MainPanel/Margin/VBox/Header/CloseButton
@onready var scroll_container: ScrollContainer = $MainPanel/Margin/VBox/ScrollContainer
@onready var records_list: VBoxContainer = $MainPanel/Margin/VBox/ScrollContainer/RecordsList
@onready var empty_label: Label = $MainPanel/Margin/VBox/ScrollContainer/RecordsList/EmptyLabel

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	overlay.gui_input.connect(_on_overlay_gui_input)
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_size_changed):
		viewport.size_changed.connect(_on_viewport_size_changed)
	_refresh_layout()
	hide_ui()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		hide_ui()
		get_viewport().set_input_as_handled()

## 显示指定玩家的分数记录
func show_score_records(player: Player) -> void:
	if player == null:
		push_error("UI_ScoreRecord: 玩家为空，无法显示分数记录")
		return

	title_label.text = "%s 分数变化记录" % _get_player_display_name(player)
	clear_records()

	var score_history: Array = ScoreManager.get_instance().get_player_score_history(player)
	if score_history.is_empty():
		empty_label.visible = true
		show_ui()
		return

	empty_label.visible = false
	for i in range(score_history.size() - 1, -1, -1):
		add_record_to_list(score_history[i], score_history.size() - 1 - i)

	show_ui()
	scroll_container.scroll_vertical = 0

## 添加单条记录到列表
func add_record_to_list(record, row_index: int) -> void:
	var timestamp: float = float(_get_record_field(record, "timestamp", 0.0))
	var source: int = int(_get_record_field(record, "source", ScoreManager.ScoreSource.CARD_SCORE))
	var score: int = int(_get_record_field(record, "score", 0))
	var description: String = str(_get_record_field(record, "description", ""))
	if description.strip_edges().is_empty():
		description = "无描述"

	var row_panel := PanelContainer.new()
	row_panel.custom_minimum_size = Vector2(0.0, ROW_MIN_HEIGHT)
	row_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_panel.add_theme_stylebox_override("panel", _create_row_style(row_index))

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 12)
	row_panel.add_child(row)

	var time_label := _create_cell_label(_format_timestamp(timestamp), 220, HORIZONTAL_ALIGNMENT_LEFT)
	var source_label := _create_cell_label(_source_to_text(source), 110, HORIZONTAL_ALIGNMENT_CENTER)
	var score_label := _create_cell_label(_format_score(score), 90, HORIZONTAL_ALIGNMENT_CENTER)
	score_label.add_theme_color_override("font_color", _score_color(score))
	var desc_label := _create_cell_label(description, 0, HORIZONTAL_ALIGNMENT_LEFT)
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	row.add_child(time_label)
	row.add_child(source_label)
	row.add_child(score_label)
	row.add_child(desc_label)

	records_list.add_child(row_panel)

func _create_cell_label(text: String, min_width: float, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(min_width, 0.0)
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = align
	return label

func _create_row_style(row_index: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.08) if row_index % 2 == 0 else Color(1, 1, 1, 0.04)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	return style

func _get_record_field(record, field_name: String, default_value):
	if record == null:
		return default_value
	if record is Dictionary:
		return record.get(field_name, default_value)
	if record is Object:
		var value = record.get(field_name)
		return value if value != null else default_value
	return default_value

func _get_player_display_name(player: Player) -> String:
	var player_name := player.player_name.strip_edges()
	if player_name.is_empty():
		return "玩家"
	return player_name

func _source_to_text(source: int) -> String:
	match source:
		ScoreManager.ScoreSource.CARD_SCORE:
			return "卡牌"
		ScoreManager.ScoreSource.STORY_SCORE:
			return "故事"
		ScoreManager.ScoreSource.SKILL_BONUS:
			return "技能"
		ScoreManager.ScoreSource.SPECIAL_BONUS:
			return "奖励"
		_:
			return "未知"

func _score_color(score: int) -> Color:
	if score > 0:
		return COLOR_SCORE_POSITIVE
	if score < 0:
		return COLOR_SCORE_NEGATIVE
	return COLOR_SCORE_NEUTRAL

func _format_score(score: int) -> String:
	if score > 0:
		return "+%d" % score
	return "%d" % score

func _format_timestamp(timestamp: float) -> String:
	if timestamp <= 0.0:
		return "-"
	var time_dict = Time.get_datetime_dict_from_unix_time(int(timestamp))
	return "%04d-%02d-%02d %02d:%02d:%02d" % [
		time_dict.year,
		time_dict.month,
		time_dict.day,
		time_dict.hour,
		time_dict.minute,
		time_dict.second,
	]

## 清空记录列表
func clear_records() -> void:
	for child in records_list.get_children():
		if child != empty_label:
			records_list.remove_child(child)
			child.queue_free()

## 关闭按钮按下事件
func _on_close_button_pressed() -> void:
	hide_ui()

func _on_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_ui()

## 显示UI
func show_ui() -> void:
	_refresh_layout()
	show()
	if is_inside_tree():
		move_to_front()
	z_index = 1000

## 隐藏UI
func hide_ui() -> void:
	hide()

func _on_viewport_size_changed() -> void:
	_refresh_layout()

func _refresh_layout() -> void:
	# 兜底处理：不依赖父节点尺寸，直接按视口尺寸布局
	set_anchors_preset(Control.PRESET_FULL_RECT)
	position = Vector2.ZERO
	size = get_viewport_rect().size

	main_panel.anchor_left = 0.5
	main_panel.anchor_top = 0.5
	main_panel.anchor_right = 0.5
	main_panel.anchor_bottom = 0.5
	main_panel.offset_left = -PANEL_SIZE.x * 0.5
	main_panel.offset_top = -PANEL_SIZE.y * 0.5
	main_panel.offset_right = PANEL_SIZE.x * 0.5
	main_panel.offset_bottom = PANEL_SIZE.y * 0.5
