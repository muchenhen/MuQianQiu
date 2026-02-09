extends Control

const SETTINGS_FILE_PATH = "user://settings.cfg"

@onready var start_button = $StartButton
@onready var checkbox_1 = $Gujian1
@onready var checkbox_2 = $Gujian2
@onready var checkbox_3 = $Gujian3
@onready var special_card_checkbox = $SpecialCardContainer/SpecialCardCheckbox
@onready var button_setting: Button = $SettingButton

# 新增AI难度选择按钮引用
@onready var simple_difficulty_btn = $AIDifficultyContainer/SimpleDifficultyBtn
@onready var normal_difficulty_btn = $AIDifficultyContainer/NormalDifficultyBtn
@onready var hard_difficulty_btn = $AIDifficultyContainer/HardDifficultyBtn

# 动画相关变量
var tween: Tween = null

# 延迟初始化的变量
var opponent_visibility_checkbox: CheckBox = null

# 用于防止递归调用的标志
var is_updating_selection: bool = false

func _ready() -> void:
	print("UI_Start ready")
	
	# 获取对手可见性复选框的引用
	opponent_visibility_checkbox = $OpponentHandVisible as CheckBox
	
	load_settings()
	_ensure_match_setting_controls()
	
	# 设置特殊牌复选框的默认状态为true
	special_card_checkbox.button_pressed = true
	GameManager.set_use_special_cards(true)

	start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))
	checkbox_1.connect("state_changed", Callable(self, "_on_checkbox_1_toggled"))
	checkbox_2.connect("state_changed", Callable(self, "_on_checkbox_2_toggled"))
	checkbox_3.connect("state_changed", Callable(self, "_on_checkbox_3_toggled"))
	special_card_checkbox.connect("toggled", Callable(self, "_on_special_card_checkbox_toggled"))
	button_setting.connect("pressed", Callable(self, "_on_setting_button_pressed"))
	
	# 连接新的AI难度选择按钮
	simple_difficulty_btn.connect("toggled", Callable(self, "_on_simple_difficulty_toggled"))
	normal_difficulty_btn.connect("toggled", Callable(self, "_on_normal_difficulty_toggled"))
	hard_difficulty_btn.connect("toggled", Callable(self, "_on_hard_difficulty_toggled"))
	
	# 安全地连接对手可见性复选框信号
	if opponent_visibility_checkbox:
		opponent_visibility_checkbox.connect("toggled", Callable(self, "_on_opponent_visibility_toggled"))

	AudioManager.get_instance().play_bgm("QianQiu")
	
	# 执行淡入动画
	play_fade_in_animation()

func play_fade_in_animation():
	# 初始透明度设为0
	modulate.a = 0.0
	
	# 创建淡入动画
	tween = create_tween()
	tween.set_parallel(false)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1.0, 1.0)

func _ensure_match_setting_controls() -> void:
	# 同步当前全局设置到新的按钮组
	var current_level = GameManager.ai_difficulty
	match current_level:
		MatchConfig.AIDifficulty.SIMPLE:
			# 确保只有简单难度被选中
			is_updating_selection = true
			simple_difficulty_btn.button_pressed = true
			normal_difficulty_btn.button_pressed = false
			hard_difficulty_btn.button_pressed = false
			is_updating_selection = false
		MatchConfig.AIDifficulty.NORMAL:
			# 确保只有普通难度被选中
			is_updating_selection = true
			simple_difficulty_btn.button_pressed = false
			normal_difficulty_btn.button_pressed = true
			hard_difficulty_btn.button_pressed = false
			is_updating_selection = false
		MatchConfig.AIDifficulty.HARD:
			# 确保只有困难难度被选中
			is_updating_selection = true
			simple_difficulty_btn.button_pressed = false
			normal_difficulty_btn.button_pressed = false
			hard_difficulty_btn.button_pressed = true
			is_updating_selection = false

	# 更新按钮高亮状态
	update_button_highlights()
	
	# 安全地设置对手可见性复选框的状态
	if opponent_visibility_checkbox:
		opponent_visibility_checkbox.button_pressed = GameManager.opponent_hand_visible

# 更新按钮高亮状态的函数
func update_button_highlights():
	# 根据按钮是否被按下设置不同的颜色来实现高亮效果
	if simple_difficulty_btn.button_pressed:
		# 选中的按钮使用高亮颜色
		simple_difficulty_btn.add_theme_color_override("font_color", Color.YELLOW)  # 高亮颜色
		simple_difficulty_btn.add_theme_color_override("font_hover_color", Color.YELLOW)
		simple_difficulty_btn.add_theme_color_override("font_pressed_color", Color.YELLOW)
	else:
		# 未选中的按钮使用普通颜色
		simple_difficulty_btn.add_theme_color_override("font_color", Color.LIGHT_GRAY)  # 普通颜色
		simple_difficulty_btn.add_theme_color_override("font_hover_color", Color.WHITE)
		simple_difficulty_btn.add_theme_color_override("font_pressed_color", Color.LIGHT_GRAY)
	
	if normal_difficulty_btn.button_pressed:
		# 选中的按钮使用高亮颜色
		normal_difficulty_btn.add_theme_color_override("font_color", Color.YELLOW)  # 高亮颜色
		normal_difficulty_btn.add_theme_color_override("font_hover_color", Color.YELLOW)
		normal_difficulty_btn.add_theme_color_override("font_pressed_color", Color.YELLOW)
	else:
		# 未选中的按钮使用普通颜色
		normal_difficulty_btn.add_theme_color_override("font_color", Color.LIGHT_GRAY)  # 普通颜色
		normal_difficulty_btn.add_theme_color_override("font_hover_color", Color.WHITE)
		normal_difficulty_btn.add_theme_color_override("font_pressed_color", Color.LIGHT_GRAY)
	
	if hard_difficulty_btn.button_pressed:
		# 选中的按钮使用高亮颜色
		hard_difficulty_btn.add_theme_color_override("font_color", Color.YELLOW)  # 高亮颜色
		hard_difficulty_btn.add_theme_color_override("font_hover_color", Color.YELLOW)
		hard_difficulty_btn.add_theme_color_override("font_pressed_color", Color.YELLOW)
	else:
		# 未选中的按钮使用普通颜色
		hard_difficulty_btn.add_theme_color_override("font_color", Color.LIGHT_GRAY)  # 普通颜色
		hard_difficulty_btn.add_theme_color_override("font_hover_color", Color.WHITE)
		hard_difficulty_btn.add_theme_color_override("font_pressed_color", Color.LIGHT_GRAY)

func _on_start_button_pressed():
	print("Start button pressed")
	var count = GameManager.get_checked_count()
	if count != 2:
		print("目前只支持选择两个")
		return
	GameManager.start_new_game()

func _on_checkbox_1_toggled(is_checked: bool):
	GameManager.is_open_first = is_checked
	GameManager.update_choosed_versions()
	print("Checkbox 1 toggled: ", is_checked)

func _on_checkbox_2_toggled(is_checked: bool):
	GameManager.is_open_second = is_checked
	GameManager.update_choosed_versions()
	print("Checkbox 2 toggled: ", is_checked)

func _on_checkbox_3_toggled(is_checked: bool):
	GameManager.is_open_third = is_checked
	GameManager.update_choosed_versions()
	print("Checkbox 3 toggled: ", is_checked)

func _on_special_card_checkbox_toggled(is_checked: bool):
	GameManager.set_use_special_cards(is_checked)
	print("Special Card Checkbox toggled: ", is_checked)

# 新增的AI难度选择处理函数
func _on_simple_difficulty_toggled(is_pressed: bool):
	if is_updating_selection:
		return  # 防止递归调用
		
	if is_pressed:
		is_updating_selection = true
		# 取消其他按钮的选中状态
		normal_difficulty_btn.button_pressed = false
		hard_difficulty_btn.button_pressed = false
		is_updating_selection = false
		
		GameManager.set_ai_difficulty(MatchConfig.AIDifficulty.SIMPLE)
		update_button_highlights()

func _on_normal_difficulty_toggled(is_pressed: bool):
	if is_updating_selection:
		return  # 防止递归调用
		
	if is_pressed:
		is_updating_selection = true
		# 取消其他按钮的选中状态
		simple_difficulty_btn.button_pressed = false
		hard_difficulty_btn.button_pressed = false
		is_updating_selection = false
		
		GameManager.set_ai_difficulty(MatchConfig.AIDifficulty.NORMAL)
		update_button_highlights()

func _on_hard_difficulty_toggled(is_pressed: bool):
	if is_updating_selection:
		return  # 防止递归调用
		
	if is_pressed:
		is_updating_selection = true
		# 取消其他按钮的选中状态
		simple_difficulty_btn.button_pressed = false
		normal_difficulty_btn.button_pressed = false
		is_updating_selection = false
		
		GameManager.set_ai_difficulty(MatchConfig.AIDifficulty.HARD)
		update_button_highlights()

func _on_opponent_visibility_toggled(is_visible: bool):  # 修复参数名称冲突
	if opponent_visibility_checkbox:
		GameManager.set_opponent_hand_visible(is_visible)

func _on_setting_button_pressed():
	print("Setting button pressed")
	var ui_setting = UIManager.get_instance().open_ui("UI_Setting")
	ui_setting.show()

func load_settings() -> void:
	var config = ConfigFile.new()
	var error = config.load(SETTINGS_FILE_PATH)
	if error != OK:
		print("加载设置时出错或文件不存在: ", error)
		return

	if config.has_section_key("audio", "bgm_volume"):
		var volume = config.get_value("audio", "bgm_volume")
		AudioManager.get_instance().set_bgm_volume(volume)

	if config.has_section_key("audio", "bgm_enabled"):
		var enabled = config.get_value("audio", "bgm_enabled")
		AudioManager.get_instance().set_bgm_enabled(enabled)

	if config.has_section_key("audio", "story_audio_enabled") and AudioManager.get_instance().has_method("set_story_audio_enabled"):
		var enabled = config.get_value("audio", "story_audio_enabled")
		AudioManager.get_instance().set_story_audio_enabled(enabled)

	print("已成功加载游戏设置")
