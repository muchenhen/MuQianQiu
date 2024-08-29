extends Control


@onready var start_button = $StartButton

var sc_main_path = "res://Scenes/sc_main.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))

func _on_start_button_pressed():
	print("Start button pressed")
	#TODO: 切换场景到main场景

