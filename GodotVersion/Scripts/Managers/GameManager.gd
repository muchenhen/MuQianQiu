extends Node

class_name GameManager

var sc_start = preload("res://scenes/sc_start.tscn")
var sc_main = preload("res://scenes/sc_main.tscn")
var current_scene = null

static var instance: GameManager = null

func _ready():
	if instance == null:
		instance = self
	else:
		queue_free()
	
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	load_start_scene()

# 开始新游戏
func start_new_game():
	print("开始新游戏")
	call_deferred("_deferred_load_scene", sc_main)

# 延迟加载场景
func _deferred_load_scene(scene):
	print("开始加载新场景")
	
	# 清理当前场景
	if current_scene != null:
		print("正在清理当前场景")
		current_scene.queue_free()
	
	# 清理所有直接子节点（可能包括之前的场景）
	for child in get_tree().root.get_children():
		if child != self:  # 不要移除GameManager自身
			print("正在清理子节点: ", child.name)
			child.queue_free()
	
	# 等待一帧，确保所有要被移除的节点都被清理
	await get_tree().process_frame
	
	# 强制删除所有仍然存在的非GameManager子节点
	for child in get_tree().root.get_children():
		if child != self:
			print("强制删除子节点: ", child.name)
			child.free()
	
	# 实例化新场景
	current_scene = scene.instantiate()
	print("新场景已实例化: ", current_scene.name)
	
	# 将新场景添加到场景树
	get_tree().root.add_child(current_scene)
	print("新场景已添加到场景树")
	
	# 将新场景设置为当前场景
	get_tree().current_scene = current_scene
	print("新场景已设置为当前场景")
	
	# 打印整个场景树
	print("当前场景树:")
	print_scene_tree(get_tree().root)

# 打印场景树的辅助函数
func print_scene_tree(node, indent=""):
	print(indent + node.name)
	for child in node.get_children():
		print_scene_tree(child, indent + "  ")

# 加载开始场景
func load_start_scene():
	call_deferred("_deferred_load_scene", sc_start)
