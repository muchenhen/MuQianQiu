extends Node2D

var animation_manager: AnimationManager

func _ready():
	animation_manager = AnimationManager.new()
	add_child(animation_manager)
	
	# 示例：启动一个线性移动动画
	var card = $Cards/Card  # 假设您有一个名为 Card 的子节点
	var target_position = Vector2(500, 300)
	animation_manager.start_linear_movement(card, target_position, 2.0)  # 2秒内移动到目标位置

func _process(delta):
	if Input.is_action_just_pressed("ui_select"):
		# 示例：当按下空格键时，开始一个新的随机移动
		var card = $Card
		var random_target = Vector2(randf_range(0, 1000), randf_range(0, 600))
		animation_manager.start_linear_movement(card, random_target, 1.5)
