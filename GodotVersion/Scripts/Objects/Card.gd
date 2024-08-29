@tool
extends Sprite2D

@export var ID: int = 201
@export var Name: String = "阿阮"
@export var PinyinName: String = "ARuan":
	set(value):
		PinyinName = value
		update_card()
@export var Type: String = "2"
@export var Score: int = 2
@export var Season: String = "春"
@export var BaseID: int = 201
@export var Special: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	print("Card ready: " + Name)
	update_card()

func update_card() -> void:
	if Engine.is_editor_hint():
		_load_image()

func _load_image() -> void:
	var path = "res://Textures/Cards/" + Type + "/Tex_" + PinyinName + ".png"
	var loaded_texture = load(path)
	if texture:
		self.texture = loaded_texture
	else:
		print("Failed to load texture: " + path + ". Will use default texture instead.")
		self.texture = load("res://Textures/Cards/2/Tex_ARuan.png")