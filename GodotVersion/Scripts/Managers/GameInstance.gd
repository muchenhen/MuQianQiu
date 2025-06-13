extends Node

class_name GameInstance

# const CardExchangeManager = preload("res://Scripts/Managers/CardExchangeManager.gd")

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
var card_exchange_manager

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
	card_exchange_manager = CardExchangeManager.get_instance()

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

	# 绑定信号 - 修改为路由到当前玩家
	public_deal.connect("player_choose_public_card", Callable(self, "_route_card_selection"))
	public_deal.connect("common_suply_public_card", Callable(self, "on_suply_public_card"))

	initialize_round_state()

	ui_manager.open_ui("UI_Start")

	# 初始化卡牌交换管理器
	card_exchange_manager.initialize(self)
	
	# 连接卡牌交换完成信号
	card_exchange_manager.exchange_completed.connect(Callable(self, "_on_exchange_completed"))

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

func get_current_active_player():
	# 获取当前回合的玩家
	if current_round == GameRound.PLAYER_A:
		return player_a
	elif current_round == GameRound.PLAYER_B:
		return player_b
	else:
		return null

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

	# 根据回合数判断当前是哪个玩家的回合
	if current_round_index % 2 == 1:
		current_round = GameRound.PLAYER_A
		print("当前是玩家A的回合")
	else:
		current_round = GameRound.PLAYER_B
		print("当前是玩家B的回合")
		
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
			if public_deal.need_supply_hand_card():
				public_deal.supply_hand_card()
			
	# 补充完毕之后进入下一阶段
	current_phase = RoundPhase.CHECK_PLAYER_ACTION
	process_round_phase()

# CHECK_PLAYER_ACTION 检查玩家行动能力阶段
func check_current_player_can_act():
	var current_player = get_current_active_player()
	if current_player == null:
		print("当前没有玩家可以行动")
		return
	
	# 检查玩家是否有手牌
	if not current_player.has_hand_card():
		print("玩家 ", current_player.player_name, " 没有手牌，无法行动")
		# 没有手牌直接结束游戏
		end_game()
		return

	# 检查玩家手牌是否与公共区域季节匹配
	if not current_player.check_hand_card_season():
		print("玩家 ", current_player.player_name, " 需要换牌")
		# 进入换牌流程
		card_exchange_manager.handle_card_exchange(current_player)
		return

	# 玩家可以正常行动，进入行动阶段
	current_phase = RoundPhase.PLAYER_ACTION
	process_round_phase()

# 处理卡牌交换完成信号
func _on_exchange_completed(success: bool):
	if not success:
		# 换牌失败，游戏结束
		end_game()
		return
	
	# 换牌成功，进入玩家行动阶段
	current_phase = RoundPhase.PLAYER_ACTION
	process_round_phase()

# PLAYER_ACTION 等待玩家行动阶段
func enable_current_player_action():
	
	var current_player = get_current_active_player()
	if current_player == null:
		print("当前没有玩家可以行动")
		return
	# 设置当前玩家状态为可以行动
	current_player.set_player_state(Player.PlayerState.SELF_ROUND_CHOOSING)
	# 设置另一个玩家为等待状态
	var other_player = player_a if current_player == player_b else player_b
	other_player.set_player_state(Player.PlayerState.WAITING)

	# TODO: 等待玩家行动
	
	# current_phase = RoundPhase.SPECIAL_CARD_EFFECT
	# process_round_phase()
	pass

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

## 路由卡牌选择到当前活跃玩家
func _route_card_selection(player_choosing_card: Card, public_choosing_card: Card):
	var current_player = get_current_active_player()
	if current_player:
		current_player.handle_card_selection(player_choosing_card, public_choosing_card, self)

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

	# 断开卡牌交换管理器信号
	if card_exchange_manager and card_exchange_manager.is_connected("exchange_completed", Callable(self, "_on_exchange_completed")):
		card_exchange_manager.disconnect("exchange_completed", Callable(self, "_on_exchange_completed"))
	
	if card_exchange_manager:
		card_exchange_manager.clear()
	
	# 清理计时器
	if animation_timer != null and animation_timer.is_inside_tree():
		animation_timer.queue_free()
		animation_timer = null
