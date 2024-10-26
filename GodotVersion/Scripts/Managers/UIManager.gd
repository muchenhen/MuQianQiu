extends Node

class_name UIManager

var ui_elements_path = {}

var ui_element_single_instance = {}

var root: Node = null

static var instance: UIManager = null

static func get_instance() -> UIManager:
	if instance == null:
		instance = UIManager.new()
	return instance

func _init():
	if instance != null:
		push_error("UIManager already exists. Use UIManager.get_instance() instead.")

func _ready():
	root = get_tree().get_root()

func get_ui_tree_root() -> Node:
	return root

func register_ui_element(key: String, element_path: String) -> void:
	ui_elements_path[key] = element_path

func get_ui_instance(key: String) -> Node:
	if key in ui_elements_path:
		var path = ui_elements_path[key]
		if path in ui_element_single_instance:
			return ui_element_single_instance[path]
		else:
			var ui_instance = load(path).instantiate()
			ui_element_single_instance[path] = ui_instance
			return instance
	else:
		push_error("UIManager: No such UI element: " + key)
		return null

func open_ui(key: String) -> void:
	var ui_instance = get_ui_instance(key)
	if ui_instance:
		root.add_child(ui_instance)
