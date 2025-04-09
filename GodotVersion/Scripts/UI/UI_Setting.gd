extends Control


@onready var hslider_bgm_volume:HSlider = $ColorRect/HSlider_BGMVolume
@onready var check_button_story_audio:CheckButton = $ColorRect/CheckButton_StoryAudio
@onready var check_button_bgm_switch:CheckButton = $ColorRect/CheckButton_BGMSwitch
@onready var button_close:Button = $Button_Close

func _ready() -> void:
	hslider_bgm_volume.connect("value_changed", Callable(self, "update_bgm_volume"))
	check_button_bgm_switch.connect("toggled", Callable(self, "toggle_bgm"))
	button_close.connect("pressed", Callable(self, "close_setting_ui"))
	
	# 初始化各控件状态
	var current_bgm_volume = AudioManager.get_instance().bgm_volume * 100
	hslider_bgm_volume.value = current_bgm_volume
	
	# 设置BGM开关初始状态
	var bgm_enabled = AudioManager.get_instance().get_bgm_enabled()
	check_button_bgm_switch.button_pressed = bgm_enabled


func _process(_delta: float) -> void:
	pass


func update_bgm_volume(volume:float) -> void:
	# mappiong to 0.0 ~ 1.0
	volume = volume / 100.0
	AudioManager.get_instance().set_bgm_volume(volume)


func toggle_bgm(enabled:bool) -> void:
	AudioManager.get_instance().set_bgm_enabled(enabled)


func close_setting_ui() -> void:
	UIManager.get_instance().destroy_ui("UI_Setting")
