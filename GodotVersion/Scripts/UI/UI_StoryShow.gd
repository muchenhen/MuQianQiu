extends Control

class_name UI_StoryShow

@onready var text_story_name: Label = $CenterContainer/VBoxContainer/Text_StoryName
@onready var card_box: HBoxContainer = $CenterContainer/VBoxContainer/CardBox
@onready var color_rect_bg: ColorRect = $ColorRect_BG

func _ready() -> void:
	# 初始状态隐藏
	modulate.a = 0
	visible = false
	z_index = 4096 # 确保在最上层
	
	if card_box:
		clear_all_cards()

func add_card(card: Node) -> void:
	if card_box:
		card_box.add_child(card)
		# 确保卡牌继承高层级的Z-index
		if card is CanvasItem:
			card.z_as_relative = true
			card.z_index = 0

func layout_children() -> void:
	# HBoxContainer 自动布局，不需要手动调用
	pass

func set_story_name(story_name: String) -> void:
	if text_story_name:
		text_story_name.text = story_name

func clear_all_cards() -> void:
	if card_box == null:
		print_debug("card_box is null")
		return
	# 销毁card_box中的所有子节点
	for child in card_box.get_children():
		card_box.remove_child(child)
		child.queue_free()

# 播放故事展示动画
# @param story_name: 故事名称
# @param cards: 卡牌节点列表
# @param on_complete: 动画完成后的回调
func play_story(story_name: String, cards: Array, on_complete: Callable = Callable()) -> void:
	# 1. 准备阶段
	visible = true
	modulate.a = 0
	set_story_name(story_name)
	clear_all_cards()
	
	# 重置卡牌状态并添加到容器
	for card in cards:
		add_card(card)
		# 修复层级问题：确保卡牌相对于父节点层级（父节点UI_StoryShow层级为999）
		card.z_as_relative = true
		card.z_index = 0 # 确保相对层级正确，会在背景之上（背景在树的前面）
		
		# 初始状态：卡牌不可见（透明或缩放为0），等待动画
		card.modulate.a = 0
		card.scale = Vector2(0.8, 0.8)
		# 确保卡牌以中心为基准缩放
		if card.has_method("set_card_pivot_offset_to_center"):
			card.set_card_pivot_offset_to_center()
	
	# 2. 进场动画序列
	var tween = create_tween()
	tween.set_parallel(false) # 串行执行
	
	# 2.1 背景淡入
	tween.tween_property(self, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# 2.2 故事名称出现（淡入 + 轻微上浮）
	text_story_name.modulate.a = 0
	text_story_name.position.y += 20
	var name_tween = create_tween()
	name_tween.set_parallel(true)
	name_tween.tween_property(text_story_name, "modulate:a", 1.0, 0.8)
	# 由于是在VBox中，直接修改position可能被覆盖或无效，这里我们修改modulate即可，
	# 或者如果想要位移效果，可以使用专门的Control节点包裹Label进行位移，但这里简单处理只做淡入
	# 如果一定要位移，可以考虑tween visual_position或者在shader中做
	
	# 2.3 卡牌逐个进入
	# 为了视觉效果，我们让卡牌稍微有些间隔地出现
	var cards_tween = create_tween()
	cards_tween.set_parallel(true)
	
	var delay = 0.5 # 从背景淡入完成后开始
	for i in range(cards.size()):
		var card = cards[i]
		# 卡牌淡入 + 缩放回正
		cards_tween.tween_property(card, "modulate:a", 1.0, 0.4).set_delay(delay).set_trans(Tween.TRANS_SINE)
		cards_tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.5).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		delay += 0.2 # 每个卡牌间隔0.2秒
	
	# 等待所有进场动画完成
	tween.chain().tween_interval(2.0 + (cards.size() * 0.2)) # 展示停留时间
	
	# 3. 离场动画
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# 4. 动画结束回调
	tween.tween_callback(func():
		visible = false
		clear_all_cards()
		if on_complete.is_valid():
			on_complete.call()
	)
