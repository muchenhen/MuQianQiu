extends Node

class_name GameManager

var tableManager = TableManager.get_instance()
var cardManager = CardManager.get_instance()

var sc_start = preload("res://scenes/sc_start.tscn")
var sc_main = preload("res://scenes/sc_main.tscn")
var current_scene = null

var animation_manager: AnimationManager

var current_all_cards

var cards_to_animate = []
var current_card_index = 0
var animation_timer: Timer


static var instance: GameManager = null

func _ready():
	if instance == null:
		instance = self
		animation_manager = AnimationManager.new()
		add_child(animation_manager)

		animation_timer = Timer.new()
		animation_timer.one_shot = true
		animation_timer.connect("timeout", Callable(self, "animate_next_card"))
		add_child(animation_timer)
	else:
		return
	

	tableManager.load_csv("res://Tables/Cards.csv")
	
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	# 确保在准备就绪后立即加载开始场景
	call_deferred("load_start_scene")

# 开始新游戏
func start_new_game():
	print("开始新游戏")
	
	cardManager.collect_cardIDs_for_this_game([2,3])
	print("本局游戏卡牌 ID: ", cardManager.cardIDs)
	cardManager.shuffle_cardIDs()
	
	load_scene(sc_main)

	var cards = cardManager.create_cards_for_this_game()
	current_all_cards = cards
	cardManager.init_cards_position_to_public_area(cards)
	for i in range(cards.size()):
		var card = cards[i]
		card.name = "Card_" + str(card.ID)
		current_scene.get_node("Cards").add_child(card)
		card.set_card_back()

	# 进入发牌流程 持续一段时间 结束后才能让玩家操作
	send_card_for_play(cards)

func send_card_for_play(cards):
	cards_to_animate = []
	current_card_index = 0
	
	var pos_array_player_a = cardManager.init_cards_position_tile(
		cardManager.PLAYER_B_CARD_AREA_SIZE,
		cardManager.PLAYER_B_CARD_AREA_POS,
		10)
	for i in range(pos_array_player_a.size()):
		var position = pos_array_player_a[i]
		var card = cards.pop_back()
		card.update_card()
		cards_to_animate.append({"card": card, "position": position})
	
	var pos_array_player_b = cardManager.init_cards_position_tile(
		cardManager.PlAYER_A_CARD_AREA_SIZE,
		cardManager.PLAYER_A_CARD_AREA_POS,
		10)
	for i in range(pos_array_player_b.size()):
		var position = pos_array_player_b[i]
		var card = cards.pop_back()
		card.update_card()
		cards_to_animate.append({"card": card, "position": position})
	
	# 开始第一张卡的动画
	animate_next_card()

func animate_next_card():
	if current_card_index < cards_to_animate.size():
		var card_data = cards_to_animate[current_card_index]
		var card = card_data["card"]
		var position = card_data["position"]
		
		animation_manager.start_parabolic_movement(card, position, 100, 2)
		current_card_index += 1
		
		# 设置下一张卡片动画的延迟
		# 这里设置为0.5秒，你可以根据需要调整
		animation_timer.start(0.5)
	else:
		# 所有卡片动画播放完毕
		print("All cards animated")

# 如果你需要中止动画序列
func stop_animation_sequence():
	animation_timer.stop()
	current_card_index = cards_to_animate.size()  # 这将阻止进一步的动画

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
	print_scene_tree(get_tree().root)

# 打印场景树的辅助函数
func print_scene_tree(node, indent=""):
	print(indent + node.name)
	for child in node.get_children():
		print_scene_tree(child, indent + "  ")

# 加载开始场景
func load_start_scene():
	print("加载开始场景")
	load_scene(sc_start)
