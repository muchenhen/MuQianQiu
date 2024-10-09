extends Node

class_name Player

var card_manager = CardManager.get_instance()

var player_name: String = "Player"

var hand_cards = {}

var deal_cards = {}

var player_score: int = 0

var score_ui:Label = null

var player_finish_stories = []

var hand_cards_pos_array = []

var current_choosing_card_id = -1

var story_queue = []
var story_timer: Timer

signal player_choose_card(Player)

# 新完成的故事展示完毕
signal new_story_show_finished()

enum PlayerState{
	# 不在自己的回合中
	WAITING = 0,
	# 自己的回合中，未选择卡片
	SELF_ROUND_UNCHOOSING = 1,
	# 自己的回合中，已选择卡片
	SELF_ROUND_CHOOSING = 2,
	# 自己的回合中，选了手牌并选了公共区域的卡片
	SELF_ROUND_CHOOSING_FINISHED = 3,
}

var player_state

enum PlayerPos{
	A = 0,
	B = 1
}

func initialize(p_name, player_pos) -> void:
	player_name = p_name
	if player_pos == PlayerPos.A:
		hand_cards_pos_array = card_manager.init_cards_position_tile(
										card_manager.PLAYER_A_CARD_AREA_SIZE,
										card_manager.PLAYER_A_CARD_AREA_POS,
										10)
	else:
		hand_cards_pos_array = card_manager.init_cards_position_tile(
										card_manager.PLAYER_B_CARD_AREA_SIZE,
										card_manager.PLAYER_B_CARD_AREA_POS,
										10)


func set_hand_cards(cards: Array) -> void:
	hand_cards = cards

func set_one_hand_card(card: Node) -> void:
	hand_cards[card.ID] = card
	card.connect("card_clicked", Callable(self, "on_card_clicked"))

func set_player_state(state: PlayerState) -> void:
	player_state = state
	print("当前玩家 ", player_name, " 状态: ", player_state)

func on_card_clicked(card: Node) -> void:
	if player_state == PlayerState.WAITING:
		return
	if player_state == PlayerState.SELF_ROUND_UNCHOOSING:
		card.set_card_chooesd()
		set_player_state(PlayerState.SELF_ROUND_CHOOSING)
		current_choosing_card_id = card.ID
		player_choose_card.emit(self)
		return
	elif player_state == PlayerState.SELF_ROUND_CHOOSING:
		if current_choosing_card_id == card.ID:
			card.set_card_unchooesd()
			set_player_state(PlayerState.SELF_ROUND_UNCHOOSING)
			current_choosing_card_id = -1
			emit_signal("player_choose_card", self)
		else:
			set_all_hand_card_unchooesd()
			card.set_card_chooesd()
			current_choosing_card_id = card.ID
			emit_signal("player_choose_card", self)
		return
	elif player_state == PlayerState.SELF_ROUND_CHOOSING_FINISHED:
		return

func set_all_hand_card_unchooesd() -> void:
	for i in hand_cards.keys():
		var card = hand_cards[i]
		card.set_card_unchooesd()

func set_all_hand_card_cannot_click() -> void:
	for i in hand_cards.keys():
		var card = hand_cards[i]
		card.disable_click()

func set_all_hand_card_can_click() -> void:
	for i in hand_cards.keys():
		var card = hand_cards[i]
		card.enable_click()

func add_score(score: int) -> void:
	player_score += score
	print("玩家 ", player_name, " 得分: ", player_score)
	if score_ui:
		score_ui.text = "当前分数：" + str(player_score)

func set_score_ui(ui: Node) -> void:
	score_ui = ui

func send_card_to_deal(card: Node) -> void:
	deal_cards[card.ID] = card
	card.set_card_unchooesd()

# 一个玩家的回合结束，检查故事完成情况
func check_finish_story() -> void:
	var deal_cards_id = []
	for card_id in deal_cards.keys():
		deal_cards_id.append(card_id)
	var story_manager = StoryManager.get_instance()
	var this_time_completed_stories = story_manager.check_story_finish_by_cards_id(deal_cards_id)
	show_new_finished_stories(this_time_completed_stories)
	
func show_new_finished_stories(this_time_completed_stories: Array):
	story_queue = this_time_completed_stories.duplicate()
	_show_next_story()

func _show_next_story():
	if not story_queue.is_empty():
		var story = story_queue.pop_front()
		show_one_new_finished_story(story)
	else:
		print("玩家 ", player_name, " 所有新完成的故事展示完毕")
		new_story_show_finished.emit()

func show_one_new_finished_story(story):
	print("玩家 ", player_name, " 完成了故事 ", story["Name"])
	# 给对应玩家增加当前故事的分数
	add_score(story["Score"])
	# 使用sc_story_show展示当前故事的卡牌
	
	var sc = GameManager.instance.get_sc_story_show_instance()
	sc.modulate.a = 0
	sc.visible = true
	sc.z_index = 999
	# 将sc添加到最上层
	var tree = GameManager.instance.get_tree()
	var root = tree.get_root()
	root.add_child(sc)
	# 获取当前故事的所有id
	var card_ids = story["CardsID"]
	# 创建新的卡牌，添加到sc中
	for card_id in card_ids:
		var card = card_manager.create_one_card(card_id)
		card.z_index = 1000
		sc.add_card(card)
	sc.layout_children()
	AnimationManager.get_instance().start_linear_alpha(sc, 1, 0.5, AnimationManager.EaseType.LINEAR, Callable(self, "show_one_new_finished_story_anim_in_end"))

func show_one_new_finished_story_anim_in_end():
	# 0.5秒后开始消失动画
	await GameManager.instance.get_tree().create_timer(0.5).timeout
	AnimationManager.get_instance().start_linear_alpha(GameManager.instance.get_sc_story_show_instance(), 0, 0.5, AnimationManager.EaseType.LINEAR, Callable(self, "show_one_new_finished_story_anim_out_end"))
	
func show_one_new_finished_story_anim_out_end():
	var sc = GameManager.instance.get_sc_story_show_instance()
	sc.modulate.a = 0
	sc.clear_all_cards()
	sc.visible = false
	# 故事展示完毕，继续展示下一个故事
	_show_next_story()
