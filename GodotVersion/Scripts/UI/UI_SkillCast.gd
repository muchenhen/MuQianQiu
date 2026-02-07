extends CanvasLayer

class_name UI_SkillCast

signal finished
signal choice_completed(choice_id: String)

@export var auto_play_duration: float = 2

@onready var title_label: Label = $Overlay/Panel/VBox/Title
@onready var round_label: Label = $Overlay/Panel/VBox/Round
@onready var actor_label: Label = $Overlay/Panel/VBox/Actor
@onready var card_label: Label = $Overlay/Panel/VBox/Card
@onready var skill_label: Label = $Overlay/Panel/VBox/Skill
@onready var stage_label: Label = $Overlay/Panel/VBox/Stage
@onready var result_label: RichTextLabel = $Overlay/Panel/VBox/Result
@onready var skip_button: Button = $Overlay/Panel/VBox/Buttons/SkipButton

@onready var prompt_panel: PanelContainer = $Overlay/PromptPanel
@onready var prompt_title: Label = $Overlay/PromptPanel/VBox/PromptTitle
@onready var prompt_desc: RichTextLabel = $Overlay/PromptPanel/VBox/PromptDesc
@onready var option_a: Button = $Overlay/PromptPanel/VBox/Options/OptionA
@onready var option_b: Button = $Overlay/PromptPanel/VBox/Options/OptionB
@onready var option_c: Button = $Overlay/PromptPanel/VBox/Options/OptionC

var _skip_requested: bool = false

func _ready() -> void:
	$Overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	prompt_panel.visible = false
	skip_button.pressed.connect(func(): _skip_requested = true)

func play_events(events: Array) -> void:
	if events.is_empty():
		finished.emit()
		return

	_skip_requested = false
	visible = true
	prompt_panel.visible = false
	title_label.text = "技能发动"
	skip_button.visible = true

	for event in events:
		if event is Dictionary:
			_apply_event(event)
		if _skip_requested:
			continue
		await get_tree().create_timer(auto_play_duration).timeout

	visible = false
	finished.emit()

func ask_choice(prompt: Dictionary) -> String:
	visible = true
	prompt_panel.visible = true
	_skip_requested = false
	title_label.text = "技能选择"
	skip_button.visible = false

	prompt_title.text = str(prompt.get("title", "请选择"))
	prompt_desc.text = str(prompt.get("description", ""))

	var options = prompt.get("options", [])
	_bind_option_button(option_a, options, 0)
	_bind_option_button(option_b, options, 1)
	_bind_option_button(option_c, options, 2)

	var choice_id: String = await choice_completed
	prompt_panel.visible = false
	skip_button.visible = true
	visible = false
	return choice_id

func _bind_option_button(btn: Button, options, index: int) -> void:
	_clear_button_connections(btn)

	if not (options is Array) or index >= options.size():
		btn.visible = false
		return

	var item = options[index]
	if not (item is Dictionary):
		btn.visible = false
		return

	btn.visible = true
	btn.text = str(item.get("label", "选项"))
	btn.pressed.connect(Callable(self, "_emit_choice").bind(str(item.get("id", ""))), CONNECT_ONE_SHOT)

func _emit_choice(choice_id: String) -> void:
	choice_completed.emit(choice_id)

func _clear_button_connections(btn: Button) -> void:
	for conn in btn.pressed.get_connections():
		var cb: Callable = conn.get("callable", Callable())
		if cb.is_valid():
			btn.pressed.disconnect(cb)

func _apply_event(event: Dictionary) -> void:
	round_label.text = "回合: %s" % str(event.get("round_index", "-"))
	actor_label.text = "玩家: %s" % str(event.get("actor_name", "未知"))
	card_label.text = "发动卡: %s" % str(event.get("source_card_name", "未知卡牌"))
	skill_label.text = "技能: %s" % str(event.get("skill_name", "未知技能"))
	stage_label.text = "阶段: %s" % str(event.get("stage_cn", "发动"))
	result_label.text = str(event.get("result_text", ""))
