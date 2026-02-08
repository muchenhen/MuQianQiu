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

var card_skill_num = 0

signal card_clicked(card)

var choosed = false

var is_enable_click = true

# 拖拽相关常量
const DRAG_THRESHOLD: float = 5.0
const DRAG_TIME_THRESHOLD: float = 0.1

# 拖拽相关变量
var drag_start_position: Vector2
var is_dragging = false
var time_since_mouse_down = 0.0
var mouse_down = false

@onready var Image_ChooesdBG : TextureRect = $Image_ChooesdBG

const BACK_TEXTURE_PATH: String = "res://Textures/Cards/Tex_Back.png"
const CARD_TEXTURE_PATH: String = "res://Textures/Cards/"
const DEFAULT_CARD_TEXTURE_PATH: String = "res://Textures/Cards/2/Tex_ARuan.png"
const GRAY_SHADER_PATH: String = "res://Shaders/gray.gdshader"

var back_texture: Texture = null

var input_priority: int = 0 : set = set_input_priority

var card_skill_slot: CardSkill = null

func set_input_priority(value: int) -> void:
	input_priority = value
	set_process_priority(input_priority)  # 更新处理优先级

func _ready() -> void:
	back_texture = load(BACK_TEXTURE_PATH)
	# 删除默认的点击事件处理（如果存在的话）
	if is_connected("pressed", Callable(self, "_on_card_clicked")):
		disconnect("pressed", Callable(self, "_on_card_clicked"))
	# 使用gui_input代替
	gui_input.connect(_on_card_gui_input)
	update_card()
	set_process_priority(input_priority)  # 设置处理优先级

func _process(delta: float) -> void:
	if mouse_down:
		time_since_mouse_down += delta
		
func _on_card_gui_input(event: InputEvent) -> void:
	if not is_enable_click:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# 鼠标按下，记录起始位置和时间
				mouse_down = true
				time_since_mouse_down = 0.0
				drag_start_position = event.position
				is_dragging = false
			else:
				# 鼠标释放
				mouse_down = false
				# 如果没有被识别为拖拽，且点击时间短，才视为点击
				if not is_dragging and time_since_mouse_down < DRAG_TIME_THRESHOLD:
					_handle_click()
				is_dragging = false
				
		elif event is InputEventMouseMotion and mouse_down:
			# 如果鼠标按下并移动
			var distance = event.position.distance_to(drag_start_position)
			# 如果移动距离超过阈值，视为拖拽
			if distance > DRAG_THRESHOLD:
				is_dragging = true
				# 告诉父容器此为拖拽事件
				var parent = get_parent()
				while parent and not parent.has_method("_notify_child_drag"):
					parent = parent.get_parent()
				if parent and parent.has_method("_notify_child_drag"):
					parent._notify_child_drag(event.relative)

func _handle_click() -> void:
	print_card_info()

	if player_owner:
		if player_owner.player_state != Player.PlayerState.SELF_ROUND_CHANGE_CARD:
			change_card_chooesd()

	# 发送信号
	card_clicked.emit(self)

func initialize(card_id, card_info) -> void:
	_update_card_properties(card_id, card_info)
	update_card()

func update_card_info(card_id, card_info) -> void:
	_update_card_properties(card_id, card_info)
	update_card()

# 内部辅助函数，用于更新卡牌属性
func _update_card_properties(card_id, card_info) -> void:
	ID = card_id
	Name = card_info["Name"]
	PinyinName = card_info["PinyinName"]
	Type = str(int(str(ID)[0]))
	Score = card_info["Score"]
	Season = card_info["Season"]
	Describe = card_info["Describe"]
	BaseID = card_info["BaseID"]
	Special = card_info["Special"]

func update_card_info_by_id(card_id: int) -> void:
	var card_info = TableManager.get_instance().get_row("Cards", card_id)
	update_card_info(card_id, card_info)

func print_card_info() -> void:
	# 打印的时候去掉换行符
	var debug_describe = Describe.replace("\n", "")
	# 打印卡牌所有信息
	print("Card clicked: ", Name, " ID: ", ID, " Type: ", Type, " Score: ", Score, " Season: ", Season, " Describe: ", debug_describe, " BaseID: ", BaseID, " Special: ", Special, " IsEnableClick: ", is_enable_click)

func update_card() -> void:
	if Special:
		self.card_skill_num = CardSkill.get_skill_num_for_card(self)
	_load_image()

func _load_image() -> void:
	var path = CARD_TEXTURE_PATH + Type + "/Tex_" + PinyinName + ".png"
	var loaded_texture = load(path)
	if loaded_texture:
		self.texture_normal  = loaded_texture
	else:
		print("Failed to load texture: " + path + ". Will use default texture instead.")
		self.texture_normal  = load(DEFAULT_CARD_TEXTURE_PATH)

func set_pinyin_name(value: String) -> void:
	PinyinName = value
	update_card()

func set_card_back() -> void:
	self.texture_normal  = back_texture

func set_card_chooesd() -> void:
	choosed = true
	Image_ChooesdBG.visible = true

func set_card_unchooesd() -> void:
	choosed = false
	Image_ChooesdBG.visible = false

func get_card_chooesd() -> bool:
	return choosed

func change_card_chooesd() -> void:
	choosed = !choosed
	Image_ChooesdBG.visible = choosed

func disable_click() -> void:
	is_enable_click = false

func enable_click() -> void:
	is_enable_click = true

func set_card_pivot_offset_to_center() -> void:
	self.pivot_offset = Vector2(size.x/2, size.y/2)

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

# 设置卡面实例是否灰色
func set_card_gray(is_gray: bool) -> void:
	var gray_shader = load(GRAY_SHADER_PATH)
	var card_material = ShaderMaterial.new()
	card_material.shader = gray_shader
	card_material.set_shader_parameter("is_gray", is_gray)
	self.material = card_material
	
# 将普通卡牌升级为珍稀牌牌
func upgrade_to_special(special_card_id: int) -> void:
	var card_info = TableManager.get_instance().get_row("Cards", special_card_id)
	if card_info:
		update_card_info(special_card_id, card_info)
		Special = true
		print("卡牌升级成功：", Name, " ID: ", ID)
	else:
		print("卡牌升级失败，找不到ID为 ", special_card_id, " 的卡牌信息")
