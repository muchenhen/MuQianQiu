extends Control

# 设置文件路径
const SETTINGS_FILE_PATH = "user://settings.cfg"

@onready var hslider_bgm_volume:HSlider = $ColorRect/HSlider_BGMVolume
@onready var check_button_story_audio:CheckButton = $ColorRect/CheckButton_StoryAudio
@onready var check_button_bgm_switch:CheckButton = $ColorRect/CheckButton_BGMSwitch
@onready var button_close:Button = $Button_Close

func _ready() -> void:
	hslider_bgm_volume.connect("value_changed", Callable(self, "update_bgm_volume"))
	check_button_bgm_switch.connect("toggled", Callable(self, "toggle_bgm"))
	button_close.connect("pressed", Callable(self, "close_setting_ui"))
	
	# 从本地加载设置
	load_settings()
	
	# 初始化各控件状态
	var current_bgm_volume = AudioManager.get_instance().bgm_volume * 100
	hslider_bgm_volume.value = current_bgm_volume
	
	# 设置BGM开关初始状态
	var bgm_enabled = AudioManager.get_instance().get_bgm_enabled()
	check_button_bgm_switch.button_pressed = bgm_enabled
	
	# 设置故事音频初始状态
	if AudioManager.get_instance().has_method("get_story_audio_enabled"):
		var story_audio_enabled = AudioManager.get_instance().get_story_audio_enabled()
		check_button_story_audio.button_pressed = story_audio_enabled
		check_button_story_audio.connect("toggled", Callable(self, "toggle_story_audio"))


func _process(_delta: float) -> void:
	pass


func update_bgm_volume(volume:float) -> void:
	# mappiong to 0.0 ~ 1.0
	volume = volume / 100.0
	AudioManager.get_instance().set_bgm_volume(volume)
	# 保存设置
	save_settings()


func toggle_bgm(enabled:bool) -> void:
	AudioManager.get_instance().set_bgm_enabled(enabled)
	# 保存设置
	save_settings()


func toggle_story_audio(enabled:bool) -> void:
	if AudioManager.get_instance().has_method("set_story_audio_enabled"):
		AudioManager.get_instance().set_story_audio_enabled(enabled)
		# 保存设置
		save_settings()


func close_setting_ui() -> void:
	# 关闭前保存设置
	save_settings()
	UIManager.get_instance().destroy_ui("UI_Setting")


# 保存设置到本地
func save_settings() -> void:
	var config = ConfigFile.new()
	
	# 保存音量设置
	config.set_value("audio", "bgm_volume", AudioManager.get_instance().bgm_volume)
	config.set_value("audio", "bgm_enabled", AudioManager.get_instance().get_bgm_enabled())
	
	# 如果有故事音频功能，也保存它的设置
	if AudioManager.get_instance().has_method("get_story_audio_enabled"):
		config.set_value("audio", "story_audio_enabled", AudioManager.get_instance().get_story_audio_enabled())
	
	# 保存配置文件
	var error = config.save(SETTINGS_FILE_PATH)
	if error != OK:
		print("保存设置时出错: ", error)


# 从本地加载设置
func load_settings() -> void:
	var config = ConfigFile.new()
	var error = config.load(SETTINGS_FILE_PATH)
	
	# 如果文件不存在或有错误，使用默认设置
	if error != OK:
		print("加载设置时出错或文件不存在: ", error)
		return
	
	# 加载音量设置
	if config.has_section_key("audio", "bgm_volume"):
		var volume = config.get_value("audio", "bgm_volume")
		AudioManager.get_instance().set_bgm_volume(volume)
	
	# 加载BGM开关设置
	if config.has_section_key("audio", "bgm_enabled"):
		var enabled = config.get_value("audio", "bgm_enabled")
		AudioManager.get_instance().set_bgm_enabled(enabled)
	
	# 加载故事音频设置
	if config.has_section_key("audio", "story_audio_enabled") and AudioManager.get_instance().has_method("set_story_audio_enabled"):
		var enabled = config.get_value("audio", "story_audio_enabled")
		AudioManager.get_instance().set_story_audio_enabled(enabled)
