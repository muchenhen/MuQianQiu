extends Node

class_name GameManager

# 静态引用，指向当前游戏实例
static var instance: GameInstance = null

# 全局状态数据
static var is_open_first: bool = false
static var is_open_second: bool = false
static var is_open_third: bool = false
# 是否使用特殊牌
static var use_special_cards: bool = false

# 调试选项
static var debug_quick_restart_enabled: bool = true # 启用快速重启功能
static var debug_key_restart: String = "r" # 用于快速重启的键
static var debug_key_was_pressed: bool = false # 跟踪R键的上一个状态

# 游戏版本选择
static var choosed_versions = []

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
	if is_open_first:
		choosed_versions.push_back(1)
	if is_open_second:
		choosed_versions.push_back(2)
	if is_open_third:
		choosed_versions.push_back(3)

	if instance!= null:
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
	# 检查是否使用特殊卡
	if use_special_cards:
		print("使用特殊牌")
		# 打开选择特殊牌的UI
		var select_skill_card = instance.ui_manager.open_ui("UI_SelectInitSkillCard")
		instance.card_manager.collect_skill_cardIDs_for_this_game()
		select_skill_card.set_card_datas(instance.card_manager.skill_cardIDs)
		select_skill_card.init_card_table_view()
	else:
		print("不使用特殊牌")
		instance.start_new_game()

## 返回到主菜单
## 清理游戏状态，销毁UI，重置并初始化新的游戏实例
static func back_to_main(root_node):
	var ui_manager = UIManager.get_instance()
	
	# 销毁UI
	ui_manager.destroy_ui("UI_Result")
	ui_manager.destroy_ui("UI_Main")
	
	# 重新初始化游戏实例
	initialize_game(root_node)

# 这个游戏节点类仅用于挂载在场景中并处理输入
# 其他所有功能都通过静态方法实现
func _ready():
	# 初始化游戏
	GameManager.initialize_game(self)

func _process(_delta):
	# 处理快速重启游戏的调试功能
	if GameManager.debug_quick_restart_enabled:
		var key_pressed_now = Input.is_key_pressed(KEY_R)
		# 仅当键从未按下变为按下状态时触发
		if key_pressed_now and not GameManager.debug_key_was_pressed:
			print("调试：快速重启游戏")
			# 先返回主菜单，清理所有状态
			GameManager.back_to_main(self)
		# 更新键的状态
		GameManager.debug_key_was_pressed = key_pressed_now
