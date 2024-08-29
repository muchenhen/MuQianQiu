extends Node

class_name GameManager

var sc_start = preload("res://Scenes/sc_start.tscn")

var current_scene = null

# 单例模式
static var instance: GameManager = null

func _ready():
	if instance == null:
		instance = self
	else:
		queue_free()
	
	# 确保GameManager不会在场景切换时被销毁
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	load_main_menu()

# 加载主菜单
func load_main_menu():
	call_deferred("_deferred_load_scene", sc_start)
	

# 开始新游戏
func start_new_game():
	print("开始新游戏")

# 延迟加载场景
func _deferred_load_scene(scene):
	# 清理当前场景
	if current_scene != null:
		current_scene.free()
	
	# 实例化新场景
	current_scene = scene.instantiate()
	# 将新场景添加到场景树
	get_tree().root.add_child(current_scene)
	# 将新场景设置为当前场景
	get_tree().current_scene = current_scene

# 游戏结束
func end_game():
	# 在这里添加游戏结束时的逻辑
	print("游戏结束")
	load_main_menu()

# 暂停游戏
func pause_game():
	get_tree().paused = true

# 恢复游戏
func resume_game():
	get_tree().paused = false
