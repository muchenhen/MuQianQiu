extends Node

class_name UIManager

var ui_elements_path = {}

var ui_element_single_instance = {}
var ui_element_multi_instance = {}

var root: Node = null

static var instance: UIManager = null

static func get_instance() -> UIManager:
	if instance == null:
		instance = UIManager.new()
		instance.intialize()
	return instance

func intialize() -> void:
	instance.regiester_ui_elements()

func set_ui_tree_root(node: Node) -> void:
	root = node

func get_ui_tree_root() -> Node:
	return root

func regiester_ui_elements() -> void:
	register_ui_element("UI_Main", "res://UI/UI_Main.tscn")
	register_ui_element("UI_PlayerChangeCard", "res://UI/UI_PlayerChangeCard.tscn")
	register_ui_element("UI_Result", "res://UI/UI_Result.tscn")
	register_ui_element("UI_Start", "res://UI/UI_Start.tscn")
	register_ui_element("UI_StoryShow", "res://UI/UI_StoryShow.tscn")
	register_ui_element("UI_DealStatus", "res://UI/UI_DealStatus.tscn")
	register_ui_element("UI_DealStoryStatus", "res://UI/UI_DealStoryStatus.tscn")
	register_ui_element("UI_Setting", "res://UI/UI_Setting.tscn")
	register_ui_element("UI_SelectInitSkillCard", "res://UI/UI_SelectInitSkillCard.tscn")
	register_ui_element("UI_Tip", "res://UI/UI_Tip.tscn")
	register_ui_element("UI_CheckSkill", "res://UI/UI_CheckSkill.tscn")
	register_ui_element("UI_SkillCast", "res://UI/UI_SkillCast.tscn")

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

# 创建UI实例并返回，用于多实例对象的UI
func create_ui_instance_for_multi(key: String) -> Node:
	# 实例化UI
	var ui_instance = load(ui_elements_path[key]).instantiate()
	if not ui_instance:
		push_error("UI实例化失败: %s" % key)
		return null
	
	# 初始化多实例字典
	if not ui_element_multi_instance.has(key):
		ui_element_multi_instance[key] = []
	
	# 添加到多实例列表
	ui_element_multi_instance[key].append(ui_instance)
	
	return ui_instance


func open_ui(key: String) -> Node:
	var ui_instance = ensure_get_ui_instance(key)
	if ui_instance:
		print("UIManager: Open UI: ", key)
		root.add_child(ui_instance)
		return ui_instance
	else:
		push_error("UIManager: Open UI failed: ", key)
		return null

func open_ui_to_top(key: String) -> Node:
	var ui_instance = open_ui(key)
	if ui_instance:
		move_ui_instance_to_top(ui_instance)
		return ui_instance
	else:
		push_error("UIManager: Open UI to top failed: ", key)
		return null

func open_ui_instance(ui_instance: Node) -> void:
	root.add_child(ui_instance)

func move_ui_instance_to_top(ui_instance: Node) -> Node:
	if ui_instance is CanvasLayer:
		ui_instance.layer = 120
	elif ui_instance is CanvasItem:
		ui_instance.z_as_relative = true
		ui_instance.z_index = 999
	return ui_instance

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

# 显示快速提示
func show_tip(text: String, duration: float = 2.0, color: Color = Color.TRANSPARENT) -> void:
	var tip:UI_Tip = create_ui_instance_for_multi("UI_Tip")
	if tip:
		# 先添加到UI树
		open_ui_instance(tip)
		move_ui_instance_to_top(tip)
		
		# 再设置属性
		tip.set_text(text)
		if color != Color.TRANSPARENT:
			tip.set_color(color)
		tip.display_duration = duration
		
		# 最后显示动画
		tip.show_tip()

# 显示成功提示
func show_success_tip(text: String, duration: float = 2.0) -> void:
	show_tip(text, duration, Color(0.2, 0.7, 0.2, 0.8))

# 显示错误提示
func show_error_tip(text: String, duration: float = 2.0) -> void:
	show_tip(text, duration, Color(0.7, 0.2, 0.2, 0.8))

# 显示警告提示
func show_warning_tip(text: String, duration: float = 2.0) -> void:
	show_tip(text, duration, Color(0.7, 0.7, 0.2, 0.8))

# 显示信息提示
func show_info_tip(text: String, duration: float = 2.0) -> void:
	show_tip(text, duration, Color(0.2, 0.2, 0.7, 0.8))
