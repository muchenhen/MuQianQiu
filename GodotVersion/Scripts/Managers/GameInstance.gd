extends Node

class_name GameInstance

# 回合状态枚举
enum RoundPhase {
	ROUND_START,           # 回合开始
	SUPPLY_PUBLIC_CARDS,   # 补充公共牌阶段
	CHECK_PLAYER_ACTION,   # 检查玩家行动能力
	PLAYER_ACTION,         # 玩家行动
	SPECIAL_CARD_EFFECT,   # 特殊卡效果结算
	STORY_CHECK,           # 故事完成检查
	ROUND_END              # 回合结束
}

var current_phase:RoundPhase = RoundPhase.ROUND_START

# 游戏开始信号，在游戏完全初始化后触发
signal game_start

############################################
# 全局管理的数据 - 从GameManager移植过来
var is_open_first:bool = false
var is_open_second:bool = false
var is_open_third:bool = false
var use_special_cards:bool = false

# 保存选择的游戏版本
var choosed_versions = []

# 管理器引用
var ui_manager
var table_manager
var card_manager
var story_manager
var input_manager
var animation_manager
var audio_manager

# 场景树引用
var scene_tree

# 游戏实例特有的数据
var public_deal:PublicCardDeal = null
var player_a = Player.new()
var player_b = Player.new()
const PLAYER_A_SCORE_STR:String = "玩家A分数："
const PLAYER_B_SCORE_STR:String = "玩家B分数："

var current_all_cards

var animation_timer: Timer

var current_round = GameRound.WAITING

const MAX_ROUND = 20
var current_round_index:int = 0

# 保存对GameManager的引用，用于访问全局设置
var game_manager = null

############################################

enum GameRound{
	WAITING = 0,
	PLAYER_A = 1,
	PLAYER_B = 2
}

enum PlayerChooseState{
	# 未选中任何卡片，此时可以选择手牌
	CHOOSE_NONE = 0,
	# 选中一张手牌，此时可以选择公共区域中可选择的牌，或者取消选择，或者选择另一张手牌
	CHOOSE_HAND = 1,
	# 选中手牌的基础上，选择了一张公共区域中的牌，确认本回合的选择，切换回合
	CHOOSE_PUBLIC = 2
}

############################################

func _init():
	# 获取所有管理器的引用
	ui_manager = UIManager.get_instance()
	table_manager = TableManager.get_instance()
	card_manager = CardManager.get_instance()
	story_manager = StoryManager.get_instance()
	input_manager = InputManager.get_instance()
	animation_manager = AnimationManager.get_instance()
	audio_manager = AudioManager.get_instance()

## 初始化GameInstance
## 设置UI树根节点，添加必要的子节点，绑定信号
func initialize(root_node):
	# 保存GameManager引用
	game_manager = root_node
	
	# 保存场景树引用
	scene_tree = root_node.get_tree()
	
	# 从GameManager同步全局设置
	is_open_first = game_manager.is_open_first
	is_open_second = game_manager.is_open_second
	is_open_third = game_manager.is_open_third
	use_special_cards = game_manager.use_special_cards
	
	# 设置UI树根节点
	ui_manager.set_ui_tree_root(root_node)
	
	# 将动画管理器添加到场景树
	if not animation_manager.is_inside_tree():
		root_node.add_child(animation_manager, true)

	if not input_manager.is_inside_tree():
		root_node.add_child(input_manager)

	# 创建新计时器
	animation_timer = Timer.new()
	animation_timer.one_shot = true
	root_node.add_child(animation_timer)

	if not audio_manager.is_inside_tree():
		root_node.add_child(audio_manager)

	initialize_players()

	# 绑定信号
	public_deal.connect("player_choose_public_card", Callable(self, "player_choose_public_card"))
	public_deal.connect("common_suply_public_card", Callable(self, "on_suply_public_card"))

	initialize_round_state()

	ui_manager.open_ui("UI_Start")

## 获取当前选中的版本数量
## 返回：选中版本的总数
func get_checked_count():
	var count = 0
	if is_open_first:
		count += 1
	if is_open_second:
		count += 1
	if is_open_third:
		count += 1
	return count

# 当外部修改选项状态时，同步更新GameManager
func set_open_first(value):
	is_open_first = value
	if game_manager:
		game_manager.is_open_first = value

func set_open_second(value):
	is_open_second = value
	if game_manager:
		game_manager.is_open_second = value

func set_open_third(value):
	is_open_third = value
	if game_manager:
		game_manager.is_open_third = value

func set_choosed_versions(in_choosed_versions):
	# 设置选择的游戏版本
	choosed_versions = in_choosed_versions
	for version in choosed_versions:
		print("选择的版本: ", version)
		if version == 1:
			is_open_first = true
		elif version == 2:
			is_open_second = true
		elif version == 3:
			is_open_third = true

func set_use_special_cards(value):
	use_special_cards = value
	if game_manager:
		game_manager.use_special_cards = value

func initialize_players():
	# 初始化玩家
	player_a.initialize("PlayerA", Player.PlayerPos.A)
	player_b.initialize("PlayerB", Player.PlayerPos.B)
	# 开启AI
	player_b.bind_ai_enable()
	# 绑定玩家
	public_deal = PublicCardDeal.new()
	public_deal.bind_players(player_a, player_b)
	card_manager.bind_players(player_a, player_b)

func initialize_round_state():
	# 初始化回合状态
	current_round = GameRound.WAITING
	current_round_index = 0


## 开始新游戏
## 播放背景音乐，初始化UI，准备卡牌
## 设置玩家分数UI，创建卡牌实例并收集各个位置信息
func start_new_game():
	print("开始新游戏")
	# 
	ui_manager.destroy_ui("UI_Start")

	card_manager.prepare_cards_for_this_game(self.choosed_versions)
	print("本局游戏卡牌 ID: ", card_manager.cardIDs)

	ui_manager.open_ui("UI_Main")

	var ui_main = ui_manager.ensure_get_ui_instance("UI_Main")
	var player_a_score_ui = ui_main.get_node("UI/Text_AScore")
	var player_b_score_ui = ui_main.get_node("UI/Text_BScore")
	player_a_score_ui.text = "当前分数: 0"
	player_b_score_ui.text = "当前分数: 0"
	player_a.set_score_ui(player_a_score_ui)
	player_b.set_score_ui(player_b_score_ui)

	player_a.new_story_show_finished.connect(Callable(self, "show_new_finished_stories"))
	player_b.new_story_show_finished.connect(Callable(self, "show_new_finished_stories"))

	var cards_node = ui_main.get_node("Cards")
	card_manager.create_cards_for_this_game(cards_node)

	# 收集玩家A的牌堆位置
	var player_a_deal_card_template = cards_node.get_node("PlayerADealCard")
	card_manager.PLAYER_A_DEAL_CARD_POS = player_a_deal_card_template.position

	# 收集玩家B的牌堆位置
	var player_b_deal_card_template = cards_node.get_node("PlayerBDealCard")
	card_manager.PLAYER_B_DEAL_CARD_POS = player_b_deal_card_template.position

	# 收集公共牌区域的位置
	var public_deal_cards_pos = []
	var public_deal_cards_rotation = []
	for i in range(1, 9):
		var node_name = "PublicDealCard" + str(i)
		var card = cards_node.get_node(node_name)
		public_deal_cards_pos.push_back(card.position)
		public_deal_cards_rotation.push_back(card.rotation)

	card_manager.collect_public_deal_cards_pos(public_deal_cards_pos, public_deal_cards_rotation)

	# 进入发牌流程 持续一段时间 结束后才能让玩家操作
	input_manager.block_input()
	# 发牌
	card_manager.send_cards_for_play(card_manager.all_storage_cards, self)

func prepare_first_round():
	print("准备第一回合")
	current_round_index = 1
	current_round = GameRound.PLAYER_A
	# 进入回合开始阶段
	current_phase = RoundPhase.ROUND_START
	process_round_phase()


## 处理玩家回合
func process_round_phase():
	match current_phase:
		RoundPhase.ROUND_START:
			# 回合开始逻辑
			start_round()

		RoundPhase.SUPPLY_PUBLIC_CARDS:
			# 补充公共卡牌逻辑
			supply_public_cards_with_effects()

		RoundPhase.CHECK_PLAYER_ACTION:
			# 检查当前玩家是否可以行动
			check_current_player_can_act()

		RoundPhase.PLAYER_ACTION:
			# 等待玩家行动(玩家行动结束后会调用player_choose_public_card)
			enable_current_player_action()

		RoundPhase.SPECIAL_CARD_EFFECT:
			# 处理特殊卡效果
			process_special_card_effects()

		RoundPhase.STORY_CHECK:
			# 检查故事完成情况
			check_stories_completion()

		RoundPhase.ROUND_END:
			# 回合结束，准备下一回合
			prepare_next_round()

# ROUND_START 回合开始阶段
func start_round():
	print("回合", str(current_round_index), "开始")
	current_phase = RoundPhase.SUPPLY_PUBLIC_CARDS
	process_round_phase()

# SUPPLY_PUBLIC_CARDS 补充公共卡牌阶段
func supply_public_cards_with_effects():
	# 检查需要生效的技能
	# 检查是否有保证出现
	var has_guarantee_card = SkillManager.get_instance().check_guarantee_card_skills()
	if not has_guarantee_card:
		# 检查是否有增加出现概率
		var has_increased_prob = SkillManager.get_instance().check_increased_probability_skills()
		if not has_increased_prob:
			# 正常补充牌
			public_deal.supply_hand_card()
			
	# 补充完毕之后进入下一阶段
	current_phase = RoundPhase.CHECK_PLAYER_ACTION
	process_round_phase()

# CHECK_PLAYER_ACTION 检查玩家行动能力阶段
func check_current_player_can_act():

	# TODO: 检查玩家是否可以行动
	current_phase = RoundPhase.PLAYER_ACTION
	process_round_phase()

# PLAYER_ACTION 等待玩家行动阶段
func enable_current_player_action():
	
	# TODO: 等待玩家行动
	current_phase = RoundPhase.SPECIAL_CARD_EFFECT
	process_round_phase()

# SPECIAL_CARD_EFFECT 处理特殊卡效果阶段
func process_special_card_effects():
	# 检查玩家是否有特殊卡效果需要处理
	# TODO: 处理特殊卡效果
	
	current_phase = RoundPhase.STORY_CHECK
	process_round_phase()

# STORY_CHECK 检查故事完成情况阶段
func check_stories_completion():
	# 检查玩家故事是否完成
	# TODO: 检查故事完成情况
	
	current_phase = RoundPhase.ROUND_END
	process_round_phase()

# ROUND_END 准备下一回合阶段
func prepare_next_round():
	print("回合", str(current_round_index), "结束")
	
	# 清理当前回合的临时状态
	var active_player = player_a if current_round == GameRound.PLAYER_A else player_b
	active_player.clear_round_state()
	
	# 增加回合索引
	current_round_index += 1
	print("准备进入回合:", current_round_index)
	
	# 检查游戏是否结束
	if current_round_index > MAX_ROUND:
		end_game()
		return
		
	# 设置下一回合的玩家
	if current_round_index % 2 == 1:
		current_round = GameRound.PLAYER_A
	else:
		current_round = GameRound.PLAYER_B
		
	# 进入下一回合的开始阶段
	current_phase = RoundPhase.ROUND_START
	process_round_phase()

## 切换回合
## 更新回合计数，检查游戏是否结束，补充公共卡牌
func change_round():
	current_round_index += 1
	print("当前回合: ", current_round_index)
	
	# 检查游戏是否结束
	if current_round_index > MAX_ROUND:
		end_game()
		return

	# 设置当前回合的玩家
	if current_round_index % 2 == 1:
		current_round = GameRound.PLAYER_A
	else:
		current_round = GameRound.PLAYER_B

	# 进入回合开始阶段
	current_phase = RoundPhase.ROUND_START
	process_round_phase()

func end_game():
	print("游戏结束")
	ui_manager.open_ui("UI_Result")
	var ui_result_instance = ui_manager.get_ui_instance("UI_Result")
	ui_result_instance.z_index = 2999
	ui_result_instance.set_result(player_a.get_score(), player_b.get_score())

## 处理玩家特殊卡逻辑
## 在发牌动画完成后、进入回合前检查并应用特殊卡效果
func process_special_cards():
	print("检查特殊卡效果")
	if use_special_cards:
		# 检查玩家A的特殊卡
		if player_a.check_special_cards():
			# 播放应用特殊卡的动画
			var ui_main = ui_manager.get_ui_instance("UI_Main")
			ui_main.send_special_cards_to_player_a()
			
		# player_a.apply_special_cards()
		# player_b.apply_special_cards()

## 卡牌动画结束的统一回调函数
## 参数：
## - card: 完成动画的卡牌
## - is_player_choice: 是否为玩家选择的卡牌（可选参数，默认为false）
func card_animation_end(card, is_player_choice = false):
	if is_player_choice:
		print("玩家选择卡牌动画结束: ", card.ID, card.Name)
	card.update_card()

## 处理公共卡牌补充事件
## 参数：
## - type: 补充类型
## 根据当前回合状态切换到下一个玩家的回合
func on_suply_public_card(type):
	print_debug("补充公共卡牌类型: ", type)
	if type == "supply_end":
		if current_round == GameRound.WAITING:
			change_to_a_round()
		elif current_round == GameRound.PLAYER_A:
			change_to_b_round()
		else:
			change_to_a_round()

## 切换到玩家A的回合
## 设置玩家状态，更新卡牌可点击状态，处理AI玩家
func change_to_a_round():
	current_round = GameRound.PLAYER_A
	player_b.set_player_state(Player.PlayerState.WAITING)
	player_b.set_all_hand_card_cannot_click()
	player_a.set_player_state(Player.PlayerState.SELF_ROUND_UNCHOOSING)
	# 调试单个季节
	public_deal.set_all_card_one_season()

	# AI玩家开始自己的回合
	if player_a.is_ai_player():
		player_a.start_ai_round()
		return

	player_a.set_all_hand_card_can_click()
	if player_a.has_hand_card():
		player_a.check_hand_card_season()

## 切换到玩家B的回合
## 设置玩家状态，更新卡牌可点击状态，处理AI玩家
func change_to_b_round():
	current_round = GameRound.PLAYER_B
	player_a.set_player_state(Player.PlayerState.WAITING)
	player_a.set_all_hand_card_cannot_click()
	player_b.set_player_state(Player.PlayerState.SELF_ROUND_UNCHOOSING)
	# 调试单个季节
	public_deal.set_all_card_one_season()

	# AI玩家开始自己的回合
	if player_b.is_ai_player():
		player_b.start_ai_round()
		return

	player_b.set_all_hand_card_can_click()
	if player_b.has_hand_card():
		player_b.check_hand_card_season()

## 处理玩家选择公共卡牌的事件
## 参数：
## - player_choosing_card: 玩家选择的手牌
## - public_choosing_card: 选择的公共卡牌
## 执行卡牌移动动画，更新玩家分数
func player_choose_public_card(player_choosing_card:Card, public_choosing_card:Card):
	input_manager.block_input()
	var player
	var target_pos
	if current_round == GameRound.PLAYER_A:
		player = player_a
		target_pos = card_manager.PLAYER_A_DEAL_CARD_POS
	else:
		player = player_b
		target_pos = card_manager.PLAYER_B_DEAL_CARD_POS

	print("玩家 ", player.player_name, " 选择了手牌 ", player_choosing_card.ID, player_choosing_card.Name, " 和公共区域的牌 ", public_choosing_card.ID, public_choosing_card.Name)

	var anim_dutation = 1

	player_choosing_card.disable_click()
	player_choosing_card.set_card_unchooesd()
	player_choosing_card.set_card_pivot_offset_to_center()

	var continue_after_animation = func():
		animation_manager.start_linear_movement_combined(
			player_choosing_card, 
			target_pos, 
			card_manager.get_random_deal_card_rotation(), 
			anim_dutation, 
			animation_manager.EaseType.EASE_IN_OUT, 
			Callable(self, "card_animation_end"), [player_choosing_card, true])

		public_choosing_card.set_card_pivot_offset_to_center()

		animation_manager.start_linear_movement_combined(
			public_choosing_card, 
			target_pos, 
			card_manager.get_random_deal_card_rotation(), 
			anim_dutation, 
			animation_manager.EaseType.EASE_IN_OUT, 
			Callable(self, "card_animation_end"), [public_choosing_card, true])

		# 更新玩家分数
		ScoreManager.get_instance().add_card_score(player, player_choosing_card)
		ScoreManager.get_instance().add_card_score(player, public_choosing_card)
		
		player.send_card_to_deal(player_choosing_card)
		player.send_card_to_deal(public_choosing_card)

		player.remove_hand_card(player_choosing_card)

		# 延时anim_dutation + 0.1秒后继续
		var temp_timer = GameManager.create_timer(anim_dutation + 0.1, func(): pass)
		await temp_timer.timeout

		player.check_finish_story()

	var play_player_choosing_card_upgrade_anim = func(special_card:Card):
		print("玩家选择的公共卡可以升级为特殊卡: ", special_card.Name)
		# 插入一段动画，将玩家手中的特殊卡位移到当前public_choosing_card的位置 包括旋转角度 zindex等
		
		# 保存特殊卡的原始z_index，用于动画结束后恢复
		var original_zindex = special_card.z_index
		
		# 临时提高z_index确保特殊卡显示在最上层
		special_card.z_index = 1000
		
		# 禁用输入，确保动画期间无法点击
		special_card.disable_click()
		public_choosing_card.disable_click()
		
		# 设置卡片中心点用于旋转动画
		special_card.set_card_pivot_offset_to_center()
		public_choosing_card.set_card_pivot_offset_to_center()
				
		# 启动移动动画，将特殊卡移动到公共卡位置
		animation_manager.start_linear_movement_combined(
			special_card, 
			public_choosing_card.position, 
			public_choosing_card.rotation, 
			0.8, 
			animation_manager.EaseType.EASE_IN_OUT, 
			Callable(self, "_on_special_card_upgrade_complete"), 
			[special_card, public_choosing_card, original_zindex, continue_after_animation]
		)
		
		# 使用await暂停函数执行，直到所有动画完成
		await GameManager.create_timer(1.0, func(): pass).timeout

	# 检查玩家选择的卡能否被升级为特殊卡
	var public_choosing_card_special = player.check_card_can_upgrade(public_choosing_card)
	if public_choosing_card_special:
		play_player_choosing_card_upgrade_anim.call(public_choosing_card_special)
	else:
		print("玩家选择的公共卡不能升级为特殊卡")
		continue_after_animation.call()
	

## 特殊卡升级动画完成的回调函数
## 参数：
## - special_card: 特殊卡对象
## - public_card: 公共卡对象
## - original_zindex: 特殊卡原始z_index值
## - player: 玩家对象
## - target_scale: 目标缩放比例
func _on_special_card_upgrade_complete(special_card, public_card, original_zindex, continue_after_animation):
	print("特殊卡升级动画完成")
	# 确保特殊卡与公共卡完全对齐
	special_card.position = public_card.position
	special_card.rotation = public_card.rotation
	
	# 将公共卡升级为特殊卡
	public_card.upgrade_to_special(special_card.ID)
	
	# 隐藏特殊卡，因为公共卡已经升级成特殊卡了
	special_card.visible = false
	
	# 恢复特殊卡的原始z_index
	special_card.z_index = original_zindex
	
	# 启用公共卡的点击（现在是升级后的特殊卡）
	public_card.enable_click()
	
	# 继续执行选择卡牌的后续流程
	continue_after_animation.call()
	

## 显示新完成的故事
## 切换回合并允许输入
func show_new_finished_stories():
	prepare_next_round()
	input_manager.allow_input()

## 获取公共卡牌管理对象
## 返回：PublicCardDeal实例
func get_public_card_deal():
	return public_deal

## 清理游戏实例
## 清理游戏状态，重置玩家对象和公共牌区域
func clear():
	if public_deal != null:
		public_deal.clear()
	
	if player_a != null:
		player_a.clear()
	
	if player_b != null:
		player_b.clear()
	
	story_manager.clear()
	card_manager.clear()
	
	# 断开所有信号连接
	if public_deal != null:
		if public_deal.is_connected("player_choose_public_card", Callable(self, "player_choose_public_card")):
			public_deal.disconnect("player_choose_public_card", Callable(self, "player_choose_public_card"))
		
		if public_deal.is_connected("common_suply_public_card", Callable(self, "on_suply_public_card")):
			public_deal.disconnect("common_suply_public_card", Callable(self, "on_suply_public_card"))
	
	# 清理计时器
	if animation_timer != null and animation_timer.is_inside_tree():
		animation_timer.queue_free()
		animation_timer = null
