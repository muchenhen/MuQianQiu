extends Node

class_name GameManager

var tableManager = TableManager.get_instance()
var cardManager = CardManager.get_instance()

var sc_start = preload("res://scenes/sc_start.tscn")
var sc_main = preload("res://scenes/sc_main.tscn")
var current_scene = null

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
	# 将卡牌添加到场景 垂直位置为屏幕中央，水平位置均匀分布但是左右距离屏幕边缘200
	for i in range(cards.size()):
		var card = cards[i]
		var viewport_size = get_viewport().size
		var width = viewport_size.x
		var height = viewport_size.y
		var card_width = card.get_size().x
		var card_height = card.get_size().y
		var x = 200 + (width - 200 - card_width) / (cards.size() - 1) * i
		# 垂直位置居中的情况下一个向上偏移卡牌高度的一半 一个向下偏移卡牌高度的一半
		var y = height / 2 - card_height / 2
		card.set_position(Vector2(x, y))
		card.name = "Card_" + str(card.ID)
		# 添加到Cards节点下
		current_scene.get_node("Cards").add_child(card)
		card.set_card_back()

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
