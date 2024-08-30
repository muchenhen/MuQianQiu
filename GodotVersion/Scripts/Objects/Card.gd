@tool
extends Sprite2D

var ID: int = 201
var Name: String = "阿阮"
var PinyinName: String = "ARuan"
var Type: String = "2"
var Score: int = 2
var Season: String = "春"
var BaseID: int = 201
var Special: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	print("Card ready: " + Name)
	update_card()

func initialize(p_id: int, p_name: String, p_pinyin_name: String, p_type: String, p_score: int, p_season: String, p_base_id: int, p_special: bool) -> void:
	ID = p_id
	Name = p_name
	PinyinName = p_pinyin_name
	Type = p_type
	Score = p_score
	Season = p_season
	BaseID = p_base_id
	Special = p_special
	update_card()

func update_card() -> void:
	if Engine.is_editor_hint():
		_load_image()

func _load_image() -> void:
	var path = "res://Textures/Cards/" + Type + "/Tex_" + PinyinName + ".png"
	var loaded_texture = load(path)
	if loaded_texture:
		self.texture = loaded_texture
	else:
		print("Failed to load texture: " + path + ". Will use default texture instead.")
		self.texture = load("res://Textures/Cards/2/Tex_ARuan.png")

func set_pinyin_name(value: String) -> void:
	PinyinName = value
	update_card()