extends Node

class_name UI_Main

@onready var player_a_deal:Button = $PlayerADeal
@onready var player_b_deal:Button = $PlayerBDeal
@onready var player_a_skill_card_zone:ColorRect = $Cards/PlayerASkillCardZone

var ui_manager:UIManager = UIManager.get_instance()
var card_manager = CardManager.get_instance()

# 玩家A的特殊卡实例
var player_a_skill_cards = []

func _ready() -> void:
	# player_a_deal绑定点击事件
	player_a_deal.connect("pressed", Callable(self, "_on_player_a_deal_clcik"))
	# player_b_deal绑定点击事件
	player_b_deal.connect("pressed", Callable(self, "_on_player_b_deal_clcik"))
	
	# 确保技能卡区域不会被显示，但卡会显示
	if player_a_skill_card_zone:
		player_a_skill_card_zone.color = Color(0, 0, 0, 0)
	
	# 监听玩家A特殊卡选择变化
	var game_instance = GameManager.instance
	if game_instance:
		# 确保信号未连接才进行连接，避免重复
		if not game_instance.is_connected("game_start", Callable(self, "_on_game_start")):
			game_instance.connect("game_start", Callable(self, "_on_game_start"))
			print("UI_Main: 已连接game_start信号")

# 游戏开始后，显示玩家的特殊卡
func _on_game_start():
	print("UI_Main: 收到游戏开始信号")
	var player_a = GameManager.instance.player_a
	if player_a:
		print("UI_Main: 开始更新玩家A的特殊卡")
		update_player_a_skill_cards(player_a)
	else:
		print("UI_Main: 无法获取player_a对象")

# 将两个点击牌堆的按钮移动到最上面

func _on_player_a_deal_clcik():
	print("玩家A牌堆点击")
	var player_a = GameManager.instance.player_a
	var deal_status:UI_DealStatus = ui_manager.open_ui("UI_DealStatus")
	ui_manager.move_ui_instance_to_top(deal_status)
	deal_status.update_deal_status_by_player(player_a)

func _on_player_b_deal_clcik():
	print("玩家B牌堆点击")
	
# 更新玩家A的特殊卡显示
func update_player_a_skill_cards(player:Player) -> void:
	# 清理旧的卡牌
	for card in player_a_skill_cards:
		if is_instance_valid(card):
			card.queue_free()
	player_a_skill_cards.clear()
	
	# 获取玩家选择的特殊卡ID数组
	var skill_card_ids = player.get_selected_special_cards()
	if skill_card_ids.size() == 0:
		return
		
	# 计算特殊卡区域的布局参数
	var zone_width = player_a_skill_card_zone.size.x
	var card_width = card_manager.CARD_WIDTH
	# 使用下划线前缀表示暂时未使用的变量
	var _card_height = card_manager.CARD_HEIGHT
	
	# 计算卡片之间的间距
	var total_cards = skill_card_ids.size()
	var spacing = 0
	if total_cards > 1:
		spacing = min(20, (zone_width - card_width * total_cards) / (total_cards - 1))
		if spacing < 0:
			spacing = 0
	
	# 计算第一张卡的起始x坐标，使卡片居中显示
	var start_x = player_a_skill_card_zone.position.x
	if spacing > 0:
		var total_width = card_width * total_cards + spacing * (total_cards - 1)
		start_x = player_a_skill_card_zone.position.x + (zone_width - total_width) / 2
	else:
		# 若空间不足，平均分配空间
		spacing = (zone_width - card_width) / (total_cards - 1) if total_cards > 1 else 0
	
	# 创建并放置特殊卡
	for i in range(skill_card_ids.size()):
		var card_id = skill_card_ids[i]
		var card = card_manager.create_one_card(card_id)
		
		# 添加到场景中
		$Cards.add_child(card)
		player_a_skill_cards.append(card)
		
		# 设置卡牌位置
		var x_pos = start_x + i * (card_width + spacing)
		card.position = Vector2(x_pos, player_a_skill_card_zone.position.y)
		
		# 设置Z序，右侧卡片层级高
		card.z_index = player_a_skill_card_zone.z_index + i + 1
		
		# 更新卡牌显示并禁用点击
		card.update_card()
		card.disable_click()
		
	print("玩家A特殊卡更新完成，共", player_a_skill_cards.size(), "张卡")
