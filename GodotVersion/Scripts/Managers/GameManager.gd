extends Node


class_name GameManager

var table_manager = TableManager.get_instance()
var card_manager = CardManager.get_instance()

var input_manager: InputManager

var animation_manager = AnimationManager.get_instance()

var sc_start = preload("res://Scenes/sc_start.tscn")
var sc_main = preload("res://Scenes/sc_main.tscn")
var current_scene = null

var current_all_cards

var player_a = Player.new()
var player_b = Player.new()
var public_deal = PublicCardDeal.new()

var cards_to_animate = []
var current_card_index = 0
var animation_timer: Timer

const PLAYER_A_SCORE_STR:String = "玩家A分数："
const PLAYER_B_SCORE_STR:String = "玩家B分数："

enum GameRound{
	WAITING = 0,
	PLAYER_A = 1,
	PLAYER_B = 2
}

var current_round = GameRound.WAITING

enum PlayerChooseState{
	# 未选中任何卡片，此时可以选择手牌
	CHOOSE_NONE = 0,
	# 选中一张手牌，此时可以选择公共区域中可选择的牌，或者取消选择，或者选择另一张手牌
	CHOOSE_HAND = 1,
	# 选中手牌的基础上，选择了一张公共区域中的牌，确认本回合的选择，切换回合
	CHOOSE_PUBLIC = 2
}

static var instance: GameManager = null

func _ready():
	if instance == null:
		instance = self
		add_child(animation_manager)

		input_manager = InputManager.new()
		add_child(input_manager)

		animation_timer = Timer.new()
		animation_timer.one_shot = true
		animation_timer.connect("timeout", Callable(self, "animate_next_card"))
		add_child(animation_timer)

		player_a.initialize("PlayerA", Player.PlayerPos.A)
		player_b.initialize("PlayerB", Player.PlayerPos.B)
		public_deal.bind_players(player_a, player_b)

		public_deal.connect("player_choose_public_card", Callable(self, "player_choose_public_card"))

		current_round = GameRound.WAITING
	else:
		return
	

	table_manager.load_csv("res://Tables/Cards.txt")

	StoryManager.get_instance().init_all_stories_state()
	
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	# 确保在准备就绪后立即加载开始场景
	call_deferred("load_start_scene")
	# input_manager.block_input()
	

# 开始新游戏
func start_new_game():
	print("开始新游戏")
	
	card_manager.collect_cardIDs_for_this_game([2,3])
	print("本局游戏卡牌 ID: ", card_manager.cardIDs)
	card_manager.shuffle_cardIDs()
	
	load_scene(sc_main)

	var ui_node = current_scene.get_node("UI")
	player_a.score_ui = ui_node.get_node("Text_AScore")
	player_b.score_ui = ui_node.get_node("Text_BScore")
	player_a.add_score(0)
	player_b.add_score(0)

	card_manager.create_cards_for_this_game(current_scene)

	# 收集玩家A的牌堆位置
	var player_a_deal_card_template = current_scene.get_node("Cards").get_node("PlayerADealCard")
	card_manager.PLAYER_A_DEAL_CARD_POS = player_a_deal_card_template.position

	# 收集玩家B的牌堆位置
	var player_b_deal_card_template = current_scene.get_node("Cards").get_node("PlayerBDealCard")
	card_manager.PLAYER_B_DEAL_CARD_POS = player_b_deal_card_template.position

	# 收集公共牌区域的位置
	var public_deal_cards_pos = []
	var public_deal_cards_rotation = []
	for i in range(1, 9):
		var node_name = "PublicDealCard" + str(i)
		var card = current_scene.get_node("Cards").get_node(node_name)
		public_deal_cards_pos.push_back(card.position)
		public_deal_cards_rotation.push_back(card.rotation)

	card_manager.collect_public_deal_cards_pos(public_deal_cards_pos, public_deal_cards_rotation)

	# 进入发牌流程 持续一段时间 结束后才能让玩家操作
	var skip_anim = true
	if not skip_anim:
		input_manager.block_input()
		send_card_for_play(card_manager.all_cards)
	else:
		send_card_for_play_without_anim(card_manager.all_cards)

func send_card_for_play_without_anim(cards):
	cards_to_animate = []
	current_card_index = 0

	for i in range(player_a.hand_cards_pos_array.size() + player_b.hand_cards_pos_array.size()):
		# A和B玩家轮流发牌
		var card = cards.pop_back()
		card.update_card()
		if i % 2 == 0:
			player_a.set_one_hand_card(card)
			card.position = player_a.hand_cards_pos_array.pop_front()
		else:
			player_b.set_one_hand_card(card)
			card.position = player_b.hand_cards_pos_array.pop_front()

	for i in range(card_manager.PUBLIC_CARDS_POS.size()):
		var position = card_manager.PUBLIC_CARDS_POS[i]
		var rotation = card_manager.PUBLIC_CRADS_ROTATION[i]
		var card = cards.pop_back()
		card.z_index = 8 - i - 1
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
			player_a.set_one_hand_card(card)
		else:
			cards_to_animate.append({"card": card, "position": player_b.hand_cards_pos_array.pop_front()})
			player_b.set_one_hand_card(card)

	for i in range(card_manager.PUBLIC_CARDS_POS.size()):
		var position = card_manager.PUBLIC_CARDS_POS[i]
		var rotation = card_manager.PUBLIC_CRADS_ROTATION[i]
		var card = cards.pop_back()
		card.z_index = 8 - i - 1
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
		print("玩家A手牌: ", player_a.hand_cards.keys())
		print("玩家B手牌: ", player_b.hand_cards.keys())
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
	
	# 重置当前轮次
	change_round()

func change_round():
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
	player_a.set_all_hand_card_can_click()

func change_to_b_round():
	current_round = GameRound.PLAYER_B
	player_a.set_player_state(Player.PlayerState.WAITING)
	player_a.set_all_hand_card_cannot_click()
	player_b.set_player_state(Player.PlayerState.SELF_ROUND_UNCHOOSING)
	player_b.set_all_hand_card_can_click()

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

	# 延时anim_dutation + 0.1秒后继续
	var temp_timer = Timer.new()
	get_tree().root.add_child(temp_timer )
	temp_timer.start(anim_dutation + 0.1)

	player.new_story_show_finished.connect(Callable(self, "show_new_finished_stories"))
	# 检查是否完成了故事
	player.check_finish_story()

func show_new_finished_stories():
	# 补充公共牌手牌
	public_deal.supply_hand_card()
	change_round()
	input_manager.allow_input()

# 同步加载场景
func load_scene(scene):
	print("开始加载新场景")
	
	# 实例化新场景
	var new_scene = scene.instantiate()
	print("新场景已实例化: ", new_scene.name)
	
	# 如果存在旧场景，先移除它
	if current_scene != null:
		print("正在移除旧场景: ", current_scene.name)
		current_scene.queue_free()
	
	# 将新场景添加到场景树
	get_tree().root.add_child(new_scene)
	print("新场景已添加到场景树")
	
	# 将新场景设置为当前场景
	get_tree().current_scene = new_scene
	print("新场景已设置为当前场景")
	
	# 更新当前场景引用
	current_scene = new_scene
	
	# 打印整个场景树
	print("当前场景树:")
	# print_scene_tree(get_tree().root)

# 打印场景树的辅助函数
func print_scene_tree(node, indent=""):
	print(indent + node.name)
	for child in node.get_children():
		print_scene_tree(child, indent + "  ")

# 加载开始场景
func load_start_scene():
	print("加载开始场景")
	load_scene(sc_start)
