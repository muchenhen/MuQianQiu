@tool
extends TextureButton

class_name Card

var ID: int = 201
var Name: String = "阿阮"
var PinyinName: String = "ARuan"
var Type: String = "2"
var Score: int = 2
var Season: String = "春"
var Describe: String = "楚梦沉醉朝复暮，\n清歌远上巫山低。"
var BaseID: int = 201
var Special: bool = false
var player_owner: Player = null

signal card_clicked(card)

var choosed = false

var is_enable_click = true

var Image_ChooesdBG : TextureRect = null

const BACK_TEXTURE_PATH: String = "res://Textures/Cards/Tex_Back.png"

var back_texture: Texture = null

var input_priority: int = 0 : set = set_input_priority

func set_input_priority(value: int) -> void:
	input_priority = value
	set_process_priority(input_priority)  # 更新处理优先级

func _ready() -> void:
	back_texture = load(BACK_TEXTURE_PATH)
	Image_ChooesdBG = get_node("Image_ChooesdBG")
	# 绑定点击事件
	connect("pressed", Callable(self, "_on_card_clicked"))
	# connect("mouse_entered", Callable(self, "on_card_hovered"))
	update_card()
	set_process_priority(input_priority)  # 设置处理优先级

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

func update_card_info(card_id, card_info) -> void:
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
	print("Card clicked: ", Name, " ID: ", ID, " Type: ", Type, " Score: ", Score, " Season: ", Season, " Describe: ", debug_describe, " BaseID: ", BaseID, " Special: ", Special, " IsEnableClick: ", is_enable_click)
	if not is_enable_click:
		print_debug("Card is not enable to click.")
		return

	if player_owner:
		if player_owner.player_state != Player.PlayerState.SELF_ROUND_CHANGE_CARD:
			change_card_chooesd()

	# 发送信号
	card_clicked.emit(self)

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

func set_card_chooesd() -> void:
	Image_ChooesdBG.visible = true
	choosed = true

func set_card_unchooesd() -> void:
	Image_ChooesdBG.visible = false
	choosed = false

func get_card_chooesd() -> bool:
	return choosed

func change_card_chooesd() -> void:
	if choosed:
		set_card_unchooesd()
	else:
		set_card_chooesd()

func disable_click() -> void:
	is_enable_click = false

func enable_click() -> void:
	is_enable_click = true

func set_card_pivot_offset_to_center() -> void:
	self.pivot_offset = Vector2(size.x/2, size.y/2)

# func on_card_hovered() -> void:
# 	print("Card hovered: ", Name, " ID: ", ID, " Z-index ", z_index, " input_priority: ", input_priority)

# func reconnect_on_card_hovered() -> void:
# 	disconnect("mouse_entered", Callable(self, "on_card_hovered"))
# 	connect("mouse_entered", Callable(self, "on_card_hovered"))

func move_to_top() -> void:
	var parent = get_parent()
	if parent:
		parent.move_child(self, -1)  # -1 moves to the last position

func move_to_bottom() -> void:
	var parent = get_parent()
	if parent:
		parent.move_child(self, 0)  # 0 moves to the first position

func get_season() -> String:
	return Season

func set_player_owner(player: Player) -> void:
	player_owner = player