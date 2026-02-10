extends CanvasLayer

class_name NewUI_DisableTargetPicker

signal pick_completed(choice_id: String)

@onready var background: ColorRect = $Background
@onready var panel: PanelContainer = $CenterPanel
@onready var title_label: Label = $CenterPanel/Content/Title
@onready var desc_label: RichTextLabel = $CenterPanel/Content/Desc
@onready var cards_grid: GridContainer = $CenterPanel/Content/ScrollContainer/CardsGrid
@onready var confirm_button: Button = $CenterPanel/Content/ButtonRow/ConfirmButton
@onready var cancel_button: Button = $CenterPanel/Content/ButtonRow/CancelButton

var _option_ids: Array[String] = []
var _selected_index: int = -1
var _card_items: Array[Control] = []
var table_manager: TableManager

func _ready() -> void:
	table_manager = TableManager.get_instance()
	visible = false
	background.mouse_filter = Control.MOUSE_FILTER_STOP
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	confirm_button.disabled = true

func ask_pick(prompt: Dictionary) -> String:
	visible = true
	_option_ids.clear()
	_selected_index = -1
	_card_items.clear()
	confirm_button.disabled = true
	
	# 清除旧的卡牌项
	for child in cards_grid.get_children():
		child.queue_free()

	title_label.text = str(prompt.get("title", "禁用目标选择"))
	desc_label.text = str(prompt.get("description", "请选择一张对手特殊卡"))

	var options = prompt.get("options", [])
	if options is Array:
		for i in range(options.size()):
			var option = options[i]
			if not (option is Dictionary):
				continue
			
			var card_id_str = str(option.get("id", "")) # instance_id 字符串
			var label_text = str(option.get("label", "未知目标"))
			var desc_text = str(option.get("description", ""))
			
			# 优先使用直接传入的 card_id 字段
			var card_db_id = int(option.get("card_id", 0))
			
			# 如果没有直接的 card_id，从描述中解析
			if card_db_id <= 0:
				var id_match = desc_text.split("卡牌ID: ")
				if id_match.size() > 1:
					var id_part = id_match[1].split(" /")[0].strip_edges()
					if id_part.is_valid_int():
						card_db_id = id_part.to_int()
			
			_create_card_item(i, label_text, card_db_id, desc_text)
			_option_ids.append(card_id_str)

	var allow_cancel := bool(prompt.get("allow_cancel", true))
	cancel_button.visible = allow_cancel

	var choice: String = await pick_completed
	visible = false
	return choice

func _create_card_item(index: int, label_text: String, card_id: int, full_desc: String) -> void:
	var item_container = VBoxContainer.new()
	item_container.custom_minimum_size = Vector2(200, 320) # 设置每个卡牌项的大小
	
	# 卡牌容器（用于背景和边框）
	var card_bg = PanelContainer.new()
	card_bg.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_bg.mouse_filter = Control.MOUSE_FILTER_PASS
	
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.3, 0.3, 0.3)
	style_box.set_corner_radius_all(8)
	card_bg.add_theme_stylebox_override("panel", style_box)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 卡牌图片
	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(180, 200) # 图片大小
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	if card_id > 0:
		var card_row = table_manager.get_row("Cards", card_id)
		if card_row and not card_row.is_empty():
			var tex_path = _get_card_texture_path(card_id, card_row)
			if ResourceLoader.exists(tex_path):
				texture_rect.texture = load(tex_path)
			else:
				print("Texture not found: ", tex_path)
	
	# 卡牌名称
	var name_label = Label.new()
	name_label.text = label_text.split("（")[0] # 只显示名字部分
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 16)
	
	# 区域标记
	var zone_label = Label.new()
	var zone_match = label_text.split("（")
	if zone_match.size() > 1:
		zone_label.text = "位置: " + zone_match[1].replace("）", "")
	else:
		zone_label.text = "位置: 未知"
	zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zone_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	zone_label.add_theme_font_size_override("font_size", 12)

	# 技能描述
	var skill_desc = RichTextLabel.new()
	skill_desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	skill_desc.bbcode_enabled = true
	skill_desc.fit_content = false
	skill_desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	skill_desc.add_theme_font_size_override("normal_font_size", 12)
	
	if card_id > 0:
		skill_desc.text = _get_skill_description(card_id)
	else:
		skill_desc.text = "[center]无技能信息[/center]"

	content_vbox.add_child(texture_rect)
	content_vbox.add_child(name_label)
	content_vbox.add_child(zone_label)
	content_vbox.add_child(HSeparator.new())
	content_vbox.add_child(skill_desc)
	
	# 设置边距
	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_top", 10)
	margin_container.add_theme_constant_override("margin_left", 10)
	margin_container.add_theme_constant_override("margin_right", 10)
	margin_container.add_theme_constant_override("margin_bottom", 10)
	margin_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin_container.add_child(content_vbox)
	
	card_bg.add_child(margin_container)
	item_container.add_child(card_bg)
	
	# 添加点击事件处理
	# 注意：在Godot 4中，gui_input需要在Control节点上连接，并且PanelContainer默认mouse_filter是STOP
	# 我们在上面设置了 card_bg.mouse_filter = Control.MOUSE_FILTER_PASS
	card_bg.gui_input.connect(func(event): _on_card_gui_input(event, index))
	
	cards_grid.add_child(item_container)
	_card_items.append(card_bg)

func _get_card_texture_path(card_id: int, card_row: Dictionary) -> String:
	# 根据卡牌ID的首位数字确定文件夹：1xx→1, 2xx→2, 3xx→3
	var version_folder = "1"
	if card_id >= 200 and card_id < 300:
		version_folder = "2"
	elif card_id >= 300:
		version_folder = "3"
		
	# 图片文件名通常是 Tex_{PinyinName}.png
	# PinyinName 在 Cards.txt 中有
	var pinyin = str(card_row.get("PinyinName", ""))
	
	# 尝试多种可能的路径
	var possible_paths = [
		"res://Textures/Cards/" + version_folder + "/Tex_" + pinyin + ".png",
		"res://Textures/Cards/" + version_folder + "/Tex_" + pinyin + ".PNG",
		"res://Textures/Cards/" + version_folder + "/" + pinyin + ".png",
	]
	
	for path in possible_paths:
		if ResourceLoader.exists(path):
			return path
	
	# 如果都找不到，返回第一个尝试的路径（这样至少能在控制台看到错误信息）
	print("Warning: Card texture not found for ", pinyin, " (ID: ", card_id, ")")
	return possible_paths[0]

func _get_skill_description(card_id: int) -> String:
	var skill_row = table_manager.get_row("Skills", card_id)
	if not skill_row or skill_row.is_empty():
		return "[center][color=gray]无技能[/color][/center]"
		
	var text = ""
	for i in range(1, 3):
		var type_key = "Skill%dType" % i
		if not skill_row.has(type_key):
			continue
			
		var type = str(skill_row[type_key]).strip_edges()
		if type == "":
			continue
			
		var target_key = "Skill%dTarget" % i
		var value_key = "Skill%dValue" % i
		
		var target = str(skill_row.get(target_key, "")).strip_edges()
		var value = str(skill_row.get(value_key, "")).strip_edges()
		
		text += "[color=#FFFF00]• " + type + "[/color]" # 使用标准HEX颜色
		if target != "":
			text += "\n  目标: " + target
		if value != "":
			text += "\n  数值: " + value
		text += "\n"
		
	if text == "":
		return "[center][color=gray]无技能[/color][/center]"
		
	return text

func _on_card_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_select_item(index)
		# 如果是双击，直接确认
		if event.double_click:
			_on_confirm_pressed()

func _select_item(index: int) -> void:
	if index < 0 or index >= _card_items.size():
		return
	
	# 还原旧的选中项样式
	if _selected_index >= 0 and _selected_index < _card_items.size():
		var old_panel = _card_items[_selected_index]
		var old_style = old_panel.get_theme_stylebox("panel")
		if old_style is StyleBoxFlat:
			old_style.border_color = Color(0.3, 0.3, 0.3)
			old_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
			old_style.border_width_left = 2
			old_style.border_width_top = 2
			old_style.border_width_right = 2
			old_style.border_width_bottom = 2
		
	_selected_index = index
	
	# 设置新的选中项样式
	var new_panel = _card_items[_selected_index]
	var new_style = new_panel.get_theme_stylebox("panel")
	if new_style is StyleBoxFlat:
		new_style.border_color = Color(1, 0.8, 0) # 金色边框
		new_style.bg_color = Color(0.3, 0.3, 0.1, 0.9)
		new_style.border_width_left = 4
		new_style.border_width_top = 4
		new_style.border_width_right = 4
		new_style.border_width_bottom = 4
	
	confirm_button.disabled = false

func _on_confirm_pressed() -> void:
	if _selected_index < 0 or _selected_index >= _option_ids.size():
		return
	pick_completed.emit(_option_ids[_selected_index])

func _on_cancel_pressed() -> void:
	pick_completed.emit("cancel")
