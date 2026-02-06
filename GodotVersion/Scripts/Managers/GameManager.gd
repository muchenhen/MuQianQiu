extends Node

class_name GameManager

# 静态引用，指向当前游戏实例
static var instance: GameInstance = null
static var manager_node: GameManager = null

# 全局状态数据
static var is_open_first: bool = false
static var is_open_second: bool = false
static var is_open_third: bool = false
# 是否使用特殊牌
static var use_special_cards: bool = false
# AI难度（1简单，2普通，3困难）
static var ai_difficulty: int = MatchConfig.AIDifficulty.SIMPLE
# 对手手牌可见性（普通AI受此影响）
static var opponent_hand_visible: bool = false

# 调试选项
static var debug_quick_restart_enabled: bool = true # 启用快速重启功能
static var debug_key_restart: String = "r" # 用于快速重启的键
static var debug_key_was_pressed: bool = false # 跟踪R键的上一个状态

# 游戏版本选择
static var choosed_versions: Array[int] = []

############################################

## 获取当前选中的版本数量
## 返回：选中版本的总数
static func get_checked_count():
	var count = 0
	if is_open_first:
		count += 1
	if is_open_second:
		count += 1
	if is_open_third:
		count += 1
	return count

## 更新choosed_versions
static func update_choosed_versions():
	choosed_versions.clear()
	if is_open_first:
		choosed_versions.push_back(1)
	if is_open_second:
		choosed_versions.push_back(2)
	if is_open_third:
		choosed_versions.push_back(3)

	if instance != null:
		instance.set_choosed_versions(choosed_versions)

	return choosed_versions

## 初始化游戏
## 创建新的游戏实例并初始化
static func initialize_game(root_node):
	# 如果已经有游戏实例，先清理旧实例
	if instance != null:
		instance.clear()
		instance = null

	# 创建新的游戏实例，并将其设置为静态instance
	instance = GameInstance.new()
	instance.initialize(root_node)

## 开始新游戏
static func start_new_game():
	if use_special_cards:
		print("使用特殊牌")
		var select_skill_card = instance.ui_manager.open_ui("UI_SelectInitSkillCard")
		instance.card_manager.collect_skill_cardIDs_for_this_game()
		select_skill_card.set_card_datas(instance.card_manager.skill_cardIDs)
		select_skill_card.init_card_table_view()
	else:
		print("不使用特殊牌")
		instance.start_new_game()

## 返回到主菜单
## 清理游戏状态，销毁UI，重置并初始化新的游戏实例
static func back_to_main():
	var ui_manager = UIManager.get_instance()
	ui_manager.destroy_ui("UI_Result")
	ui_manager.destroy_ui("UI_Main")
	initialize_game(manager_node)

# 这个游戏节点类仅用于挂载在场景中并处理输入
func _ready():
	GameManager.manager_node = self
	GameManager.initialize_game(self)

func _process(_delta):
	if GameManager.debug_quick_restart_enabled:
		var key_pressed_now = Input.is_key_pressed(KEY_R)
		if key_pressed_now and not GameManager.debug_key_was_pressed:
			print("调试：快速重启游戏")
			GameManager.back_to_main()
		GameManager.debug_key_was_pressed = key_pressed_now

static func set_use_special_cards(use_special: bool):
	use_special_cards = use_special
	print("设置使用特殊牌: ", use_special_cards)
	if instance != null:
		instance.set_use_special_cards(use_special_cards)

static func set_ai_difficulty(level: int):
	ai_difficulty = level
	print("设置AI难度: ", ai_difficulty)
	if instance != null:
		instance.set_ai_difficulty(level)

static func set_opponent_hand_visible(visible: bool):
	opponent_hand_visible = visible
	print("设置对手手牌可见性: ", opponent_hand_visible)
	if instance != null:
		instance.set_opponent_hand_visible(visible)

## 创建一个定时器并返回
static func create_timer(wait_time: float, callback: Callable) -> SceneTreeTimer:
	if not is_instance_valid(instance) or not is_instance_valid(instance.scene_tree):
		push_error("GameManager: 无法创建计时器，游戏实例或场景树无效")
		return null

	var timer = instance.scene_tree.create_timer(wait_time)
	timer.timeout.connect(callback)
	return timer

## 创建一个高级定时器并返回
static func create_timer_advanced(wait_time: float, callback: Callable, process_physics: bool = false, process_always: bool = false, process_in_editor: bool = false) -> SceneTreeTimer:
	if not is_instance_valid(instance) or not is_instance_valid(instance.scene_tree):
		push_error("GameManager: 无法创建计时器，游戏实例或场景树无效")
		return null

	var timer = instance.scene_tree.create_timer(wait_time, process_physics, process_always, process_in_editor)
	timer.timeout.connect(callback)
	return timer
