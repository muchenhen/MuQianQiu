extends Node

class_name GameManager

static var instance: GameManager = null

############################################
var ui_manager = UIManager.get_instance()

var table_manager = TableManager.get_instance()
var card_manager = CardManager.get_instance()
var story_manager = StoryManager.get_instance()
var input_manager: InputManager
var animation_manager = AnimationManager.get_instance()

var is_open_first:bool = false
var is_open_second:bool = false
var is_open_third:bool = false

var public_deal = PublicCardDeal.new()
var player_a = Player.new()
var player_b = Player.new()
const PLAYER_A_SCORE_STR:String = "玩家A分数："
const PLAYER_B_SCORE_STR:String = "玩家B分数："

var current_all_cards

var cards_to_animate = []
var current_card_index = 0
var animation_timer: Timer

var current_round = GameRound.WAITING

const MAX_ROUND = 20
var current_round_index:int = 0

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

func get_checked_count():
	var count = 0
	if is_open_first:
		count += 1
	if is_open_second:
		count += 1
	if is_open_third:
		count += 1
	return count

func _ready():
	if instance == null:
		instance = self
		ui_manager.set_ui_tree_root(instance)
		ui_manager.register_ui_element("UI_Main", "res://UI/UI_Main.tscn")
		ui_manager.register_ui_element("UI_PlayerChangeCard", "res://UI/UI_PlayerChangeCard.tscn")
		ui_manager.register_ui_element("UI_Result", "res://UI/UI_Result.tscn")
		ui_manager.register_ui_element("UI_Start", "res://UI/UI_Start.tscn")
		ui_manager.register_ui_element("UI_StoryShow", "res://UI/UI_StoryShow.tscn")

		add_child(animation_manager)

		input_manager = InputManager.new()
		add_child(input_manager)

		animation_timer = Timer.new()
		animation_timer.one_shot = true
		animation_timer.connect("timeout", Callable(self, "animate_next_card"))
		add_child(animation_timer)

		# 初始化玩家
		player_a.initialize("PlayerA", Player.PlayerPos.A)
		player_b.initialize("PlayerB", Player.PlayerPos.B)
		# 开启AI
		player_b.bind_ai_enable()

		public_deal.bind_players(player_a, player_b)
		card_manager.bind_players(player_a, player_b)

		public_deal.connect("player_choose_public_card", Callable(self, "player_choose_public_card"))

		current_round = GameRound.WAITING
		current_round_index = 0
	
		table_manager.load_csv("res://Tables/Cards.txt")
		StoryManager.get_instance().init_all_stories_state()

		ui_manager.open_ui("UI_Start")

# 开始新游戏
func start_new_game():
	print("开始新游戏")
	ui_manager.destroy_ui("UI_Start")

	var choosed_versions = []
	if is_open_first:
		choosed_versions.push_back(1)
	if is_open_second:
		choosed_versions.push_back(2)
	if is_open_third:
		choosed_versions.push_back(3)

	card_manager.prepare_cards_for_this_game(choosed_versions)
	print("本局游戏卡牌 ID: ", card_manager.cardIDs)

	ui_manager.open_ui("UI_Main")

	var ui_main = ui_manager.ensure_get_ui_instance("UI_Main")
	player_a.set_score_ui(ui_main.get_node("UI/Text_AScore"))
	player_b.set_score_ui(ui_main.get_node("UI/Text_BScore"))
	player_a.add_score(0)
	player_b.add_score(0)

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
	var skip_anim = false
	if not skip_anim:
		input_manager.block_input()
		send_card_for_play(card_manager.all_storage_cards)
	else:
		send_card_for_play_without_anim(card_manager.all_storage_cards)



func send_card_for_play_without_anim(cards):
	cards_to_animate = []
	current_card_index = 0

	for i in range(player_a.hand_cards_pos_array.size() + player_b.hand_cards_pos_array.size()):
		# A和B玩家轮流发牌
		var card = cards.pop_back()
		card.update_card()
		if i % 2 == 0:
			var index:int = player_a.get_player_first_enpty_hand_card_index()
			player_a.assign_player_hand_card_to_slot(card, index)
			card.position = player_a.hand_cards_pos_array.pop_front()
			card.set_player_owner(player_a)
		else:
			var index:int = player_b.get_player_first_enpty_hand_card_index()
			player_b.assign_player_hand_card_to_slot(card, index)
			card.position = player_b.hand_cards_pos_array.pop_front()
			card.set_player_owner(player_b)

	for i in range(card_manager.PUBLIC_CARDS_POS.size()):
		var position = card_manager.PUBLIC_CARDS_POS[i]
		var rotation = card_manager.PUBLIC_CRADS_ROTATION[i]
		var card = cards.pop_back()
		card.z_index = 8 - i
		card.set_input_priority(card.z_index)
		card.update_card()
		# 公共卡池的手牌禁止点击
		card.connect("card_clicked", Callable(self, "on_card_clicked"))
		public_deal.set_one_hand_card(card, position, rotation)
		card.position = position
		card.rotation = rotation
		
	start_round()


func send_card_for_play(cards):
	cards_to_animate = []
	current_card_index = 0

	for i in range(player_a.hand_cards_pos_array.size() + player_b.hand_cards_pos_array.size()):
		# A和B玩家轮流发牌
		var card = cards.pop_back()
		if i % 2 == 0:
			cards_to_animate.append({"card": card, "position": player_a.hand_cards_pos_array.pop_front()})
			var index:int = player_a.get_player_first_enpty_hand_card_index()
			player_a.assign_player_hand_card_to_slot(card, index)
		else:
			cards_to_animate.append({"card": card, "position": player_b.hand_cards_pos_array.pop_front()})
			var index:int = player_b.get_player_first_enpty_hand_card_index()
			player_b.assign_player_hand_card_to_slot(card, index)

	for i in range(card_manager.PUBLIC_CARDS_POS.size()):
		var position = card_manager.PUBLIC_CARDS_POS[i]
		var rotation = card_manager.PUBLIC_CRADS_ROTATION[i]
		var card = cards.pop_back()
		card.z_index = 8 - i
		card.set_input_priority(card.z_index)
		# 公共卡池的手牌禁止点击
		card.connect("card_clicked", Callable(self, "on_card_clicked"))
		public_deal.set_one_hand_card(card, position, rotation)
		cards_to_animate.append({"card": card, "position": position, "rotation":rotation })
	
	public_deal.disable_all_hand_card_click()
	# 开始第一张卡的动画
	animate_next_card()

func animate_next_card():
	if current_card_index < cards_to_animate.size():
		var card_data = cards_to_animate[current_card_index]
		var card = card_data["card"]
		var position = card_data["position"]

		animation_manager.start_linear_movement_pos(card, position, 0.6, animation_manager.EaseType.EASE_IN_OUT, Callable(self, "send_card_anim_end"), [card])
		
		if "rotation" in card_data:
			var rotation = card_data["rotation"]
			animation_manager.start_linear_movement_rotation(card, rotation, 0.6, animation_manager.EaseType.EASE_IN_OUT)

		current_card_index += 1
		
		# 设置下一张卡片动画的延迟
		# 这里设置为0.5秒，你可以根据需要调整
		animation_timer.start(0.1)
	else:
		# 所有卡片动画播放完毕
		print("All cards animated")
		for key in public_deal.hand_cards.keys():
			var public_card = public_deal.hand_cards[key]
			if public_card.isEmpty:
				continue
			print("公共区域手牌 ", key, " ID: ", public_card.card.ID)
		print("发牌完毕")
		input_manager.allow_input()
		change_round()

# 如果需要中止动画序列
func stop_animation_sequence():
	animation_timer.stop()
	current_card_index = cards_to_animate.size()  # 这将阻止进一步的动画

#  单个发牌动画结束后的回调
func send_card_anim_end(card):
	card.update_card()

func start_round():
	print("开始新一轮")

	# 重置所有卡片的选中状态
	for key in public_deal.hand_cards.keys():
		public_deal.hand_cards[key].card.set_card_unchooesd()

	player_a.update_self_card_z_index()
	player_b.update_self_card_z_index()
	
	# 重置当前轮次
	change_round()

func change_round():
	current_round_index += 1
	print("当前回合: ", current_round_index)
	if current_round_index > MAX_ROUND:
		print("游戏结束")
		ui_manager.open_ui("UI_Result")
		var ui_result_instance = ui_manager.get_ui_instance("UI_Result")
		ui_result_instance.z_index = 2999
		ui_result_instance.set_result(player_a.get_score(), player_b.get_score())
		return

	# 补充公共牌手牌
	public_deal.supply_hand_card()

	if current_round == GameRound.WAITING:
		change_to_a_round()
	elif current_round == GameRound.PLAYER_A:
		change_to_b_round()
	else:
		change_to_a_round()


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

# 玩家已经选择了一张手牌并且确认要选择了一张公共区域的牌
func player_choose_public_card(player_choosing_card, public_choosing_card):
	input_manager.block_input()
	var player
	var target_pos
	var target_rotation = card_manager.get_random_deal_card_rotation()
	if current_round == GameRound.PLAYER_A:
		player = player_a
		target_pos = card_manager.PLAYER_A_DEAL_CARD_POS

	else:
		player = player_b
		target_pos = card_manager.PLAYER_B_DEAL_CARD_POS

	print("玩家 ", player.player_name, " 选择了手牌 ", player_choosing_card.ID, " 和公共区域的牌 ", public_choosing_card.ID)

	var anim_dutation = 1

	player_choosing_card.disable_click()
	player_choosing_card.set_card_unchooesd()
	player_choosing_card.set_card_pivot_offset_to_center()

	animation_manager.start_linear_movement_combined(player_choosing_card, target_pos, target_rotation, anim_dutation, animation_manager.EaseType.EASE_IN_OUT, Callable(self, "player_choose_card_anim_end"), [player_choosing_card])

	public_choosing_card.set_card_pivot_offset_to_center()
	target_rotation = card_manager.get_random_deal_card_rotation()
	animation_manager.start_linear_movement_combined(public_choosing_card, target_pos, target_rotation, anim_dutation, animation_manager.EaseType.EASE_IN_OUT, Callable(self, "player_choose_card_anim_end"), [public_choosing_card])

	# 更新玩家分数
	player.add_score(player_choosing_card.Score + public_choosing_card.Score)
	
	player.send_card_to_deal(player_choosing_card)
	player.send_card_to_deal(public_choosing_card)

	player.remove_hand_card(player_choosing_card)

	# 延时anim_dutation + 0.1秒后继续
	var temp_timer = Timer.new()
	get_tree().root.add_child(temp_timer )
	temp_timer.start(anim_dutation + 0.1)
	
	player.new_story_show_finished.connect(Callable(self, "show_new_finished_stories"))

	player.check_finish_story()


func show_new_finished_stories():
	change_round()
	input_manager.allow_input()

# 打印场景树的辅助函数
func print_scene_tree(node, indent=""):
	print(indent + node.name)
	for child in node.get_children():
		print_scene_tree(child, indent + "  ")

func get_public_card_deal():
	return public_deal

func back_to_main():
	story_manager.clear()
	card_manager.clear()
	player_a.clear()
	player_b.clear()
	
	ui_manager.destroy_ui("UI_Result")
	ui_manager.destroy_ui("UI_Main")
	

	current_round_index = 0

	ui_manager.open_ui("UI_Start")
