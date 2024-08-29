extends Control


@onready var start_button = $StartButton

func _ready() -> void:
	start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))

func _on_start_button_pressed():
	print("Start button pressed")
	GameManager.instance.start_new_game()
