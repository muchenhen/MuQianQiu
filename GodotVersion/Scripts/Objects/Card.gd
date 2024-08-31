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
	# 绑定点击事件
	connect("pressed", Callable(self, "_on_card_clicked"))
	update_card()

func initialize(card_id, card_info) -> void:
	ID = card_id
	Name = card_info["Name"]
	PinyinName = card_info["PinyinName"]
	Type = str(int(str(ID)[0]))
	Score = card_info["Score"]
	Season = card_info["Season"]
	Describe = card_info["Describe"]
	BaseID = card_info["BaseID"]
	Special = card_info["Special"]
	update_card()

func _on_card_clicked() -> void:
	# 打印的时候去掉换行符
	var debug_describe = Describe.replace("\n", "")
	# 打印卡牌所有信息
	print("Card clicked: ", Name, " ID: ", ID, " Type: ", Type, " Score: ", Score, " Season: ", Season, " Describe: ", debug_describe, " BaseID: ", BaseID, " Special: ", Special)

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
