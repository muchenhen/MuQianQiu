@tool
extends TextureButton

signal state_changed(is_checked: bool)

enum State {CHECKED, UNCHECKED}

var _button_texture: Texture2D = null

@export var button_texture: Texture2D:
	set(value):
		if _button_texture != value:
			_button_texture = value
			_update_textures()
	get:
		return _button_texture

var _button_scale: Vector2 = Vector2.ONE

@export var button_scale: Vector2 = Vector2.ONE:
	set(value):
		if _button_scale != value:
			_button_scale = value
			scale = value
	get:
		return _button_scale
			
@export var checked_color: Color = Color.WHITE
@export var unchecked_color: Color = Color(0.6, 0.6, 0.6, 1.0)

var current_state: State = State.UNCHECKED

func _update_textures():
	if _button_texture:
		texture_normal = _button_texture
		texture_pressed = _button_texture
		texture_hover = _button_texture
		texture_disabled = _button_texture
		texture_focused = _button_texture
		print("纹理已更新")

func _enter_tree():
	_update_textures()

func _ready():
	scale = button_scale
	if _button_texture:
		self_modulate = unchecked_color
	if not Engine.is_editor_hint():
		if not pressed.is_connected(_on_pressed):
			pressed.connect(_on_pressed)
	

func _on_pressed():
	match current_state:
		State.CHECKED:
			set_state(State.UNCHECKED)
			state_changed.emit(false)
		State.UNCHECKED:
			set_state(State.CHECKED)
			state_changed.emit(true)

func set_state(new_state: State):
	current_state = new_state
	match current_state:
		State.CHECKED:
			self_modulate = checked_color
		State.UNCHECKED:
			self_modulate = unchecked_color

func get_state() -> State:
	return current_state

func is_checked() -> bool:
	return current_state == State.CHECKED
