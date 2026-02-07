extends CanvasLayer

class_name UI_DisableTargetPicker

signal pick_completed(choice_id: String)

@onready var background: ColorRect = $Background
@onready var panel: PanelContainer = $CenterPanel
@onready var title_label: Label = $CenterPanel/Content/Title
@onready var desc_label: RichTextLabel = $CenterPanel/Content/Desc
@onready var candidate_list: ItemList = $CenterPanel/Content/CandidateList
@onready var confirm_button: Button = $CenterPanel/Content/ButtonRow/ConfirmButton
@onready var cancel_button: Button = $CenterPanel/Content/ButtonRow/CancelButton

var _option_ids: Array[String] = []

func _ready() -> void:
	visible = false
	background.mouse_filter = Control.MOUSE_FILTER_STOP
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	candidate_list.item_selected.connect(_on_item_selected)
	candidate_list.item_activated.connect(_on_item_activated)

func ask_pick(prompt: Dictionary) -> String:
	visible = true
	_option_ids.clear()
	candidate_list.clear()

	title_label.text = str(prompt.get("title", "禁用目标选择"))
	desc_label.text = str(prompt.get("description", "请选择一张对手特殊卡"))

	var options = prompt.get("options", [])
	if options is Array:
		for option in options:
			if not (option is Dictionary):
				continue
			var label := str(option.get("label", "未知目标"))
			var desc := str(option.get("description", "")).strip_edges()
			var line := label
			if desc != "":
				line += "  |  " + desc
			candidate_list.add_item(line)
			candidate_list.set_item_tooltip(candidate_list.get_item_count() - 1, desc)
			_option_ids.append(str(option.get("id", "")))

	if candidate_list.get_item_count() > 0:
		candidate_list.select(0)

	var allow_cancel := bool(prompt.get("allow_cancel", true))
	cancel_button.visible = allow_cancel
	confirm_button.disabled = candidate_list.get_item_count() <= 0

	var choice: String = await pick_completed
	visible = false
	return choice

func _on_item_selected(_index: int) -> void:
	confirm_button.disabled = false

func _on_item_activated(index: int) -> void:
	if index < 0 or index >= _option_ids.size():
		return
	pick_completed.emit(_option_ids[index])

func _on_confirm_pressed() -> void:
	var selected: PackedInt32Array = candidate_list.get_selected_items()
	if selected.is_empty():
		return
	var index := int(selected[0])
	if index < 0 or index >= _option_ids.size():
		return
	pick_completed.emit(_option_ids[index])

func _on_cancel_pressed() -> void:
	pick_completed.emit("cancel")
