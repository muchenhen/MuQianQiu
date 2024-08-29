extends Node2D

const CARD_SCENE = preload("res://Scripts/Objects/Card.tscn")
const CARD_WIDTH = 240
const CARD_HEIGHT = 320
const DECK_SIZE = 54

var cards = []
var animation_manager: AnimationManager
var current_stage = 0
var stages = [
	"card_spread_out",
	"circular_rotation",
	"spread_and_scale",
	"sunburst_formation",
	"random_rotation",
	"spiral_return",
	"restack_cards"
]

func _ready():
	animation_manager = AnimationManager.new()
	add_child(animation_manager)
	
	create_deck()
	position_deck()

func create_deck():
	for i in range(DECK_SIZE):
		var card = CARD_SCENE.instantiate()
		cards.append(card)
		add_child(card)

func position_deck():
	for i in range(DECK_SIZE):
		cards[i].position = Vector2.ZERO
		cards[i].scale = Vector2.ONE

func _input(event):
	if event.is_action_pressed("ui_accept"):  # 按空格键开始洗牌
		super_shuffle_animation()

func super_shuffle_animation():
	current_stage = 0
	execute_next_stage()

func execute_next_stage():
	if current_stage < stages.size():
		call(stages[current_stage])
	else:
		print("Shuffle animation completed")

func start_next_stage_timer(duration: float):
	var timer = get_tree().create_timer(duration)
	timer.connect("timeout", Callable(self, "execute_next_stage"))
	current_stage += 1

func card_spread_out():
	var radius = 400
	var center = Vector2(0, 0)
	var angle_step = 2 * PI / DECK_SIZE
	var duration = 2.0

	for i in range(DECK_SIZE):
		var angle = i * angle_step
		var card = cards[i]
		
		# 设置卡片的初始位置（原点）
		card.position = center
		
		# 设置卡片的初始旋转，使其垂直于圆心
		card.rotation = angle + PI/2
		
		# 开始扇形展开动画
		animation_manager.start_spread_out_movement(card, center, radius, angle, duration)

	start_next_stage_timer(duration)

func circular_rotation():
	var radius = 400
	var center = Vector2.ZERO
	var angle_step = 2 * PI / DECK_SIZE

	for i in range(DECK_SIZE):
		var angle = i * angle_step
		var card = cards[i]
		
		# 设置卡片的初始位置
		# var initial_position = center + Vector2(cos(angle), sin(angle)) * radius
		# card.position = initial_position
		
		# 设置卡片的旋转，使其垂直于圆心
		card.rotation = angle + PI/2  # 加上 PI/2 使卡片垂直于半径
		
		# 开始圆周运动
		animation_manager.start_circular_movement(card, center, radius, angle, 2.0)

	start_next_stage_timer(2.0)

func spread_and_scale():
	var positions = []
	var rows = 6
	var cols = 9
	var start_x = -850
	var start_y = -450
	var spacing_x = 200
	var spacing_y = 180

	for i in range(rows):
		for j in range(cols):
			if len(positions) < DECK_SIZE:
				positions.append(Vector2(start_x + j * spacing_x, start_y + i * spacing_y))

	positions.shuffle()

	for i in range(DECK_SIZE):
		animation_manager.start_movement_with_scale(cards[i], positions[i], Vector2(0.8, 0.8), 1.0)

	start_next_stage_timer(1.0)

func sunburst_formation():
	var radius = 450
	var angle_step = 2 * PI / DECK_SIZE

	for i in range(DECK_SIZE):
		var angle = i * angle_step
		var target = Vector2(cos(angle), sin(angle)) * radius
		animation_manager.start_linear_movement(cards[i], target, 1.0)

	start_next_stage_timer(1.0)

func random_rotation():
	for card in cards:
		var rotation_speed = randf_range(1, 3) * (1 if randf() > 0.5 else -1)
		var duration = randf_range(2, 4)
		animation_manager.start_rotation(card, rotation_speed, duration)

	start_next_stage_timer(3.0)

func spiral_return():
	var a = 0.1
	var b = 0.2

	for i in range(DECK_SIZE):
		var t = i * 0.2
		var x = (a + b * t) * cos(t)
		var y = (a + b * t) * sin(t)
		var target = Vector2(x, y) * 1000  # 调整大小以适应屏幕
		
		var duration = randf_range(0.5, 1.5)
		animation_manager.start_parabolic_movement(cards[i], target, randf_range(100, 300), duration)

	start_next_stage_timer(1.5)

func restack_cards():
	for i in range(DECK_SIZE):
		var duration = randf_range(0.3, 0.8)
		animation_manager.start_movement_with_scale(cards[i], Vector2.ZERO, Vector2.ONE, duration)

	# 这是最后一个阶段，不需要启动下一个阶段
