extends Node2D

var animation_manager: AnimationManager

const CARD_SCENE = preload("res://Scripts/Objects/Card.tscn")
const CARD_WIDTH = 240
const CARD_HEIGHT = 320
const DECK_SIZE = 54
var cards = []

func _ready():
	animation_manager = AnimationManager.new()
	add_child(animation_manager)

	create_desk()
	position_deck()

func create_desk():
	for i in range(DECK_SIZE):
		var card = CARD_SCENE.instantiate()
		cards.append(card)
		add_child(card)

func position_deck():
	var start_x = 0
	var start_y = 0
	for i in range(DECK_SIZE):
		cards[i].position = Vector2(start_x, start_y)

func _input(event):
	if event.is_action_pressed("ui_accept"):  # 按空格键开始洗牌
		shuffle_animation()

func shuffle_animation():
	var shuffled_positions = []
	var max_radius = 540  # 屏幕高度的一半

	for i in range(DECK_SIZE):
		var angle = randf() * 2 * PI  # 随机角度 (0 到 2π)
		var radius = sqrt(randf()) * max_radius  # 使用平方根来确保均匀分布
		
		var pos = Vector2(cos(angle) * radius, sin(angle) * radius)
		
		# 确保卡牌完全在屏幕内
		pos.x = clamp(pos.x, -960 + CARD_WIDTH / 2, 960 - CARD_WIDTH / 2)
		pos.y = clamp(pos.y, -540 + CARD_HEIGHT / 2, 540 - CARD_HEIGHT / 2)
		
		shuffled_positions.append(pos)

	shuffled_positions.shuffle()

	for i in range(DECK_SIZE):
		var duration = randf_range(0.5, 1.5)
		animation_manager.start_parabolic_movement(cards[i], shuffled_positions[i], randf_range(100, 300), duration)

	# 等待所有卡片动画完成后重新叠放
	await get_tree().create_timer(2.0).timeout
	restack_cards()

func restack_cards():
	var center = Vector2(0,0)
	for i in range(DECK_SIZE):
		var  duration = randf_range(0.5, 1.5)
		animation_manager.start_linear_movement(cards[i], center, duration)

func _process(delta):
	if Input.is_action_just_pressed("ui_select"):
		# 示例：当按下空格键时，开始一个新的随机移动
		var card = $Card
		var random_target = Vector2(randf_range(0, 1000), randf_range(0, 600))
		animation_manager.start_linear_movement(card, random_target, 1.5)
