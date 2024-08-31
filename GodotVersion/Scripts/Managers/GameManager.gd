extends Node

class_name GameManager

var tableManager = TableManager.get_instance()
var cardManager = CardManager.get_instance()

var sc_start = preload("res://scenes/sc_start.tscn")
var sc_main = preload("res://scenes/sc_main.tscn")
var current_scene = null

var current_all_cards

static var instance: GameManager = null

func _ready():
	if instance == null:
		instance = self
	else:
		queue_free()
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
	var pos_array_player_a = cardManager.init_cards_position_tile(
		cardManager.PLAYER_B_CARD_AREA_SIZE,
		cardManager.PLAYER_B_CARD_AREA_POS,
		10)
	for i in range(pos_array_player_a.size()):
		var position = pos_array_player_a[i]
		var card = cards.pop_back()
		card.position = position
		card.update_card()
	var pos_array_player_b = cardManager.init_cards_position_tile(
		cardManager.PlAYER_A_CARD_AREA_SIZE,
		cardManager.PLAYER_A_CARD_AREA_POS,
		10)
	for i in range(pos_array_player_b.size()):
		var position = pos_array_player_b[i]
		var card = cards.pop_back()
		card.position = position
		card.update_card()

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
