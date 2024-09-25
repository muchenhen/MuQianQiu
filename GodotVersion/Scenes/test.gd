extends Node2D

@onready var texture_button = $TextureButton
@onready var texture_button2 = $TextureButton2
@onready var texture_button3 = $TextureButton3

var texture_button_pos
var texture_button2_pos
var texture_button3_pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture_button.connect("pressed", Callable(self, "on_texture_button_pressed"))
	texture_button2.connect("pressed", Callable(self, "on_texture_button2_pressed"))
	texture_button3.connect("pressed", Callable(self, "on_texture_button3_pressed"))
	texture_button_pos = texture_button.position
	texture_button2_pos = texture_button2.position
	texture_button3_pos = texture_button3.position

func on_texture_button_pressed():
	print("Texture button pressed")

func on_texture_button2_pressed():
	print("Texture button2 pressed")

func on_texture_button3_pressed():
	texture_button3.global_position = texture_button_pos + Vector2(100, 0)
	print("Texture button3 pressed")
