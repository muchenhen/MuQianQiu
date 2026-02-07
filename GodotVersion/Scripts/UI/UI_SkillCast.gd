extends CanvasLayer

class_name UI_SkillCast

signal finished
signal choice_completed(choice_id: String)

@export var auto_play_duration: float = 2.0

# 主要 UI 节点引用
@onready var background: ColorRect = $Background
@onready var main_container: HBoxContainer = $MainContainer

# 左侧列
@onready var card_image: TextureRect = $MainContainer/LeftColumn/CardFrame/CardImage

# 右侧列 - 信息
@onready var round_label: Label = $MainContainer/RightColumn/HeaderInfo/RoundLabel
@onready var actor_label: Label = $MainContainer/RightColumn/HeaderInfo/ActorLabel
@onready var skill_name_label: Label = $MainContainer/RightColumn/SkillNameLabel

# 右侧列 - 阶段指示器
@onready var stage_register: PanelContainer = $MainContainer/RightColumn/StageContainer/StageRegister
@onready var stage_check: PanelContainer = $MainContainer/RightColumn/StageContainer/StageCheck
@onready var stage_trigger: PanelContainer = $MainContainer/RightColumn/StageContainer/StageTrigger
@onready var stage_register_label: Label = $MainContainer/RightColumn/StageContainer/StageRegister/Label
@onready var stage_check_label: Label = $MainContainer/RightColumn/StageContainer/StageCheck/Label
@onready var stage_trigger_label: Label = $MainContainer/RightColumn/StageContainer/StageTrigger/Label

# 右侧列 - 结果文本
@onready var result_scroll: ScrollContainer = $MainContainer/RightColumn/ResultScroll
@onready var result_label: RichTextLabel = $MainContainer/RightColumn/ResultScroll/ResultLabel

# 右侧列 - 交互区
@onready var action_area: HBoxContainer = $MainContainer/RightColumn/ActionArea
@onready var skip_button: Button = $MainContainer/RightColumn/ActionArea/SkipButton

# 右侧列 - 选择面板
@onready var choice_panel: VBoxContainer = $MainContainer/RightColumn/ChoicePanel
@onready var prompt_title: Label = $MainContainer/RightColumn/ChoicePanel/PromptTitle
@onready var prompt_desc: RichTextLabel = $MainContainer/RightColumn/ChoicePanel/PromptDesc
@onready var options_container: HBoxContainer = $MainContainer/RightColumn/ChoicePanel/OptionsContainer
@onready var option_a: Button = $MainContainer/RightColumn/ChoicePanel/OptionsContainer/OptionA
@onready var option_b: Button = $MainContainer/RightColumn/ChoicePanel/OptionsContainer/OptionB
@onready var option_c: Button = $MainContainer/RightColumn/ChoicePanel/OptionsContainer/OptionC

var _skip_requested: bool = false
var _is_playing: bool = false

func _ready() -> void:
	visible = false
	background.mouse_filter = Control.MOUSE_FILTER_STOP
	skip_button.pressed.connect(func(): _skip_requested = true)
	
	# 初始化时隐藏选择面板，显示结果面板
	choice_panel.visible = false
	result_scroll.visible = true

func play_events(events: Array) -> void:
	if events.is_empty():
		finished.emit()
		return

	_skip_requested = false
	_is_playing = true
	visible = true
	
	# 确保处于展示模式
	choice_panel.visible = false
	result_scroll.visible = true
	action_area.visible = true
	
	# 入场动画
	_animate_entry()

	for event in events:
		if event is Dictionary:
			_update_ui_for_event(event)
		
		# 如果是需要展示的事件（不仅仅是后台数据更新），则等待
		if _should_wait_for_event(event):
			var wait_time = auto_play_duration
			if _skip_requested:
				wait_time = 0.1
			await get_tree().create_timer(wait_time).timeout
		
		if _skip_requested:
			# 如果跳过，后续事件快速播放
			pass

	_animate_exit()
	await get_tree().create_timer(0.3).timeout
	visible = false
	_is_playing = false
	finished.emit()

func ask_choice(prompt: Dictionary) -> String:
	visible = true
	_skip_requested = false
	
	# 切换到选择模式
	result_scroll.visible = false
	choice_panel.visible = true
	action_area.visible = false # 隐藏跳过按钮
	
	# 更新基础信息（如果 prompt 中包含卡牌信息）
	# 通常 prompt 结构: { "type": "...", "title": "...", "description": "...", "options": [...] }
	# 为了美观，我们可以尝试获取当前上下文的卡牌信息，或者保持上一张卡牌的显示
	
	prompt_title.text = str(prompt.get("title", "请选择"))
	prompt_desc.text = str(prompt.get("description", ""))
	
	var options = prompt.get("options", [])
	_bind_option_button(option_a, options, 0)
	_bind_option_button(option_b, options, 1)
	_bind_option_button(option_c, options, 2)
	
	_animate_entry()
	
	var choice_id: String = await choice_completed
	
	_animate_exit()
	await get_tree().create_timer(0.3).timeout
	visible = false
	
	# 恢复状态
	choice_panel.visible = false
	result_scroll.visible = true
	action_area.visible = true
	
	return choice_id

func _update_ui_for_event(event: Dictionary) -> void:
	# 1. 更新卡牌图片
	var card_id = int(event.get("source_card_id", -1))
	_load_card_image(card_id)
	
	# 2. 更新头部信息
	var round_idx = event.get("round_index", 0)
	var actor_name = str(event.get("actor_name", "未知"))
	round_label.text = "第 %s 回合" % round_idx
	actor_label.text = actor_name
	
	# 3. 更新技能名
	var skill_name = str(event.get("skill_name", "未知技能"))
	skill_name_label.text = skill_name
	
	# 4. 更新阶段高亮
	var stage_code = str(event.get("stage", "TRIGGER"))
	_update_stage_highlight(stage_code)
	
	# 5. 更新结果文本
	var result_text = str(event.get("result_text", ""))
	result_label.text = result_text

func _load_card_image(card_id: int) -> void:
	if card_id <= 0:
		card_image.texture = null
		return
		
	# 获取 CardManager 实例来查询卡牌信息
	var card_row = TableManager.get_instance().get_row("Cards", card_id)
	if card_row == null:
		return
		
	var type = str(int(str(card_id)[0]))
	var pinyin = card_row.get("PinyinName", "")
	
	if pinyin == "":
		return
		
	var path = "res://Textures/Cards/" + type + "/Tex_" + pinyin + ".png"
	var texture = load(path)
	
	if texture:
		card_image.texture = texture
	else:
		# Fallback texture
		print_debug("Texture not found: " + path)
		card_image.texture = load("res://Textures/Cards/Tex_Back.png")

func _update_stage_highlight(stage_code: String) -> void:
	# 重置所有样式
	_set_panel_style(stage_register, Color(0.2, 0.2, 0.2, 0.5))
	_set_panel_style(stage_check, Color(0.2, 0.2, 0.2, 0.5))
	_set_panel_style(stage_trigger, Color(0.2, 0.2, 0.2, 0.5))
	
	stage_register_label.modulate = Color(0.7, 0.7, 0.7)
	stage_check_label.modulate = Color(0.7, 0.7, 0.7)
	stage_trigger_label.text = "发动"
	stage_trigger_label.modulate = Color(0.7, 0.7, 0.7)
	
	match stage_code:
		"REGISTER":
			_set_panel_style(stage_register, Color(0.0, 0.5, 1.0, 0.8)) # 蓝色
			stage_register_label.modulate = Color.WHITE
		"CHECK":
			_set_panel_style(stage_check, Color(1.0, 0.6, 0.0, 0.8)) # 橙色
			stage_check_label.modulate = Color.WHITE
		"TRIGGER":
			_set_panel_style(stage_trigger, Color(0.0, 0.8, 0.0, 0.8)) # 绿色
			stage_trigger_label.text = "发动成功"
			stage_trigger_label.modulate = Color.WHITE
		"FAILED":
			_set_panel_style(stage_trigger, Color(0.8, 0.0, 0.0, 0.8)) # 红色
			stage_trigger_label.text = "发动失败"
			stage_trigger_label.modulate = Color.WHITE
		"WAIVED":
			_set_panel_style(stage_trigger, Color(0.5, 0.5, 0.5, 0.8)) # 灰色
			stage_trigger_label.text = "放弃发动"
			stage_trigger_label.modulate = Color.WHITE
		"INVALID":
			_set_panel_style(stage_trigger, Color(0.5, 0.5, 0.5, 0.8))
			stage_trigger_label.text = "无效"
			stage_trigger_label.modulate = Color.WHITE

func _set_panel_style(panel: PanelContainer, bg_color: Color) -> void:
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.bg_color = bg_color
	panel.add_theme_stylebox_override("panel", style)

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

func _should_wait_for_event(event: Dictionary) -> bool:
	# 简单的逻辑：所有展示的事件都需要停留观看
	return true

func _animate_entry() -> void:
	background.modulate.a = 0.0
	main_container.modulate.a = 0.0
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(background, "modulate:a", 1.0, 0.3)
	tween.tween_property(main_container, "modulate:a", 1.0, 0.3)

func _animate_exit() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(background, "modulate:a", 0.0, 0.3)
	tween.tween_property(main_container, "modulate:a", 0.0, 0.3)
