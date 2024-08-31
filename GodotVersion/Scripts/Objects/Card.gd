@tool
extends TextureButton

var ID: int = 201
var Name: String = "阿阮"
var PinyinName: String = "ARuan"
var Type: String = "2"
var Score: int = 2
var Season: String = "春"
var Describe: String = "楚梦沉醉朝复暮，\n清歌远上巫山低。"
var BaseID: int = 201
var Special: bool = false

const BACK_TEXTURE_PATH: String = "res://Textures/Cards/Tex_Back.png"

var back_texture: Texture = null

func _ready() -> void:
	back_texture = load(BACK_TEXTURE_PATH)
	update_card()

func initialize(p_id: int, p_name: String, p_pinyin_name: String, p_score: int, p_season: String, p_base_id: int, p_special: bool) -> void:
	ID = p_id
	Name = p_name
	PinyinName = p_pinyin_name
	# Type 是 ID三位数字的第一个数字
	Type = str(int(str(ID)[0]))
	Score = p_score
	Season = p_season
	BaseID = p_base_id
	Special = p_special
	update_card()

func update_card() -> void:
	_load_image()

func _load_image() -> void:
	var path = "res://Textures/Cards/" + Type + "/Tex_" + PinyinName + ".png"
	var loaded_texture = load(path)
	if loaded_texture:
		self.texture_normal  = loaded_texture
	else:
		print("Failed to load texture: " + path + ". Will use default texture instead.")
		self.texture_normal  = load("res://Textures/Cards/2/Tex_ARuan.png")

func set_pinyin_name(value: String) -> void:
	PinyinName = value
	update_card()

func set_card_back() -> void:
	self.texture_normal  = back_texture
