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

func set_ui_tree_root(node: Node) -> void:
	root = node

func get_ui_tree_root() -> Node:
	return root

func register_ui_element(key: String, element_path: String) -> void:
	ui_elements_path[key] = element_path

func ensure_get_ui_instance(key: String) -> Node:
	var ui_instance  = get_ui_instance(key)
	if not ui_instance:
		ui_instance = create_ui_instance(key)
	return ui_instance

func get_ui_instance(key: String) -> Node:
	if key in ui_element_single_instance:
		return ui_element_single_instance[key]
	else:
		return null

func create_ui_instance(key: String) -> Node:
	if key in ui_elements_path:
		var ui_instance = load(ui_elements_path[key]).instantiate()
		ui_element_single_instance[key] = ui_instance
		return ui_instance
	else:
		push_error("UIManager: UI element not found: ", key)
		return null

func open_ui(key: String) -> void:
	var ui_instance = ensure_get_ui_instance(key)
	if ui_instance:
		print("UIManager: Open UI: ", key)
		root.add_child(ui_instance)

# 关闭显示但是不销毁
func close_ui(key: String) -> void:
	var ui_instance: Node = get_ui_instance(key)
	if ui_instance:
		print("UIManager: Close UI: ", key)
		ui_instance.visible = false
		ui_instance.z_index = -1
		ui_instance.set_process(false)
		ui_instance.set_physics_process(false)

# 销毁
func destroy_ui(key: String) -> void:
	var ui_instance: Node = get_ui_instance(key)
	if ui_instance:
		print("UIManager: Destroy UI: ", key)
		ui_instance.queue_free()
		# 从缓存中移除
		if key in ui_element_single_instance:
			ui_element_single_instance.erase(ui_instance)
			ui_element_single_instance.erase(key)
