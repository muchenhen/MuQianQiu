extends Node

class_name GameInstance

enum GameRound {
	WAITING = 0,
	PLAYER_A = 1,
	PLAYER_B = 2
}

# 游戏开始信号，在游戏完全初始化后触发
signal game_start
# 技能触发调试信号（给UI调试面板）
signal skill_debug_event(payload: Dictionary)

# 全局设置
var is_open_first: bool = false
var is_open_second: bool = false
var is_open_third: bool = false
var use_special_cards: bool = false
var ai_difficulty: int = MatchConfig.AIDifficulty.SIMPLE
var opponent_hand_visible: bool = false

# 保存选择的游戏版本
var choosed_versions: Array[int] = []

# 管理器引用
var ui_manager: UIManager
var table_manager: TableManager
var card_manager: CardManager
var story_manager: StoryManager
var input_manager: InputManager
var animation_manager: AnimationManager
var audio_manager: AudioManager
var card_exchange_manager: CardExchangeManager
var skill_manager: SkillManager

# 核心模块
var match_config: MatchConfig = null
var match_state: MatchState = null
var turn_engine: TurnEngine = null
var ai_planner: AIPlanner = null

# 场景树引用
var scene_tree: SceneTree

# 游戏实例数据
var public_deal: PublicCardDeal = null
var player_a = Player.new()
var player_b = Player.new()

var animation_timer: Timer

var current_round: GameRound = GameRound.WAITING
var current_round_index: int = 0

# 保存对GameManager的引用，用于访问全局设置
var game_manager = null

func _init():
	ui_manager = UIManager.get_instance()
	table_manager = TableManager.get_instance()
	card_manager = CardManager.get_instance()
	story_manager = StoryManager.get_instance()
	input_manager = InputManager.get_instance()
	animation_manager = AnimationManager.get_instance()
	audio_manager = AudioManager.get_instance()
	card_exchange_manager = CardExchangeManager.get_instance()
	skill_manager = SkillManager.get_instance()

func initialize(root_node):
	game_manager = root_node
	scene_tree = root_node.get_tree()

	_sync_settings_from_manager()

	ui_manager.set_ui_tree_root(root_node)

	if not animation_manager.is_inside_tree():
		root_node.add_child(animation_manager, true)
	if not input_manager.is_inside_tree():
		root_node.add_child(input_manager)
	if not audio_manager.is_inside_tree():
		root_node.add_child(audio_manager)
	if not card_exchange_manager.is_inside_tree():
		root_node.add_child(card_exchange_manager)

	animation_timer = Timer.new()
	animation_timer.one_shot = true
	root_node.add_child(animation_timer)

	initialize_players()

	public_deal.connect("player_choose_public_card", Callable(self, "_route_card_selection"))

	card_exchange_manager.initialize(self)
	card_exchange_manager.exchange_completed.connect(Callable(self, "_on_exchange_completed"))

	player_a.action_resolution_completed.connect(Callable(self, "_on_player_action_resolution_completed"))
	player_b.action_resolution_completed.connect(Callable(self, "_on_player_action_resolution_completed"))

	initialize_round_state()
	_build_match_runtime()

	ui_manager.open_ui("UI_Start")

func _sync_settings_from_manager() -> void:
	is_open_first = game_manager.is_open_first
	is_open_second = game_manager.is_open_second
	is_open_third = game_manager.is_open_third
	use_special_cards = game_manager.use_special_cards
	ai_difficulty = game_manager.ai_difficulty
	opponent_hand_visible = game_manager.opponent_hand_visible

func _build_match_runtime() -> void:
	match_config = MatchConfig.new()
	match_config.selected_versions = choosed_versions.duplicate()
	match_config.use_special_cards = use_special_cards
	match_config.ai_difficulty = ai_difficulty
	match_config.opponent_hand_visible = opponent_hand_visible
	match_config.max_round = 20

	match_state = MatchState.new()
	match_state.initialize(match_config, player_a, player_b, public_deal, card_manager, story_manager)

	turn_engine = TurnEngine.new()
	turn_engine.initialize(match_state)
	turn_engine.turn_event_emitted.connect(Callable(self, "_on_turn_event_emitted"))

	ai_planner = AIPlanner.new()
	skill_manager.initialize(match_state)

func initialize_players():
	player_a.initialize("PlayerA", Player.PlayerPos.A)
	player_b.initialize("PlayerB", Player.PlayerPos.B)
	player_a.set_ai_controlled(false)
	player_b.set_ai_controlled(true)

	public_deal = PublicCardDeal.new()
	public_deal.bind_players(player_a, player_b)
	card_manager.bind_players(player_a, player_b)

func initialize_round_state():
	current_round = GameRound.WAITING
	current_round_index = 0

func set_choosed_versions(in_choosed_versions):
	choosed_versions = in_choosed_versions.duplicate()
	is_open_first = false
	is_open_second = false
	is_open_third = false
	for version in choosed_versions:
		if version == 1:
			is_open_first = true
		elif version == 2:
			is_open_second = true
		elif version == 3:
			is_open_third = true
	if game_manager:
		game_manager.is_open_first = is_open_first
		game_manager.is_open_second = is_open_second
		game_manager.is_open_third = is_open_third
	if match_config:
		match_config.selected_versions = choosed_versions.duplicate()

func set_use_special_cards(value):
	use_special_cards = value
	if game_manager:
		game_manager.use_special_cards = value
	if match_config:
		match_config.use_special_cards = value

func set_ai_difficulty(value: int):
	ai_difficulty = value
	if game_manager:
		game_manager.ai_difficulty = value
	if match_config:
		match_config.ai_difficulty = value

func set_opponent_hand_visible(value: bool):
	opponent_hand_visible = value
	if game_manager:
		game_manager.opponent_hand_visible = value
	if match_config:
		match_config.opponent_hand_visible = value
	_refresh_all_hand_visibility()

func start_new_game():
	print("开始新游戏")
	ui_manager.destroy_ui("UI_Start")
	ScoreManager.get_instance().reset_scores()
	_build_match_runtime()

	card_manager.prepare_cards_for_this_game(choosed_versions)
	print("本局游戏卡牌 ID: ", card_manager.cardIDs)

	ui_manager.open_ui("UI_Main")

	var ui_main = ui_manager.ensure_get_ui_instance("UI_Main")
	var player_a_score_ui = ui_main.get_node("UI/Text_AScore")
	var player_b_score_ui = ui_main.get_node("UI/Text_BScore")
	player_a_score_ui.text = "当前分数: 0"
	player_b_score_ui.text = "当前分数: 0"
	player_a.set_score_ui(player_a_score_ui)
	player_b.set_score_ui(player_b_score_ui)

	var cards_node = ui_main.get_node("Cards")
	card_manager.create_cards_for_this_game(cards_node)

	var player_a_deal_card_template = cards_node.get_node("PlayerADealCard")
	card_manager.PLAYER_A_DEAL_CARD_POS = player_a_deal_card_template.position

	var player_b_deal_card_template = cards_node.get_node("PlayerBDealCard")
	card_manager.PLAYER_B_DEAL_CARD_POS = player_b_deal_card_template.position

	var public_deal_cards_pos = []
	var public_deal_cards_rotation = []
	for i in range(1, 9):
		var node_name = "PublicDealCard" + str(i)
		var card = cards_node.get_node(node_name)
		public_deal_cards_pos.push_back(card.position)
		public_deal_cards_rotation.push_back(card.rotation)

	card_manager.collect_public_deal_cards_pos(public_deal_cards_pos, public_deal_cards_rotation)

	input_manager.block_input()
	card_manager.send_cards_for_play(card_manager.all_storage_cards, self)

func prepare_first_round():
	print("准备第一回合")
	if turn_engine == null:
		_build_match_runtime()
	turn_engine.start_match()

func _on_turn_event_emitted(event: TurnEvent) -> void:
	match event.type:
		TurnEvent.Type.ROUND_STARTED:
			_on_round_started(event.payload)
		TurnEvent.Type.PUBLIC_SUPPLY_REQUIRED:
			_handle_public_supply_async.call_deferred()
		TurnEvent.Type.EXCHANGE_REQUIRED:
			_handle_exchange_required(event.payload)
		TurnEvent.Type.ACTION_REQUIRED:
			_handle_action_required.call_deferred(event.payload)
		TurnEvent.Type.CARDS_MATCHED:
			_handle_cards_matched(event.payload)
		TurnEvent.Type.ROUND_ENDED:
			print("回合结束: ", event.payload.get("round_index", -1))
		TurnEvent.Type.GAME_ENDED:
			end_game()

func _on_round_started(payload: Dictionary) -> void:
	current_round_index = int(payload.get("round_index", 0))
	var round_player: Player = payload.get("player", null)
	if round_player == player_a:
		current_round = GameRound.PLAYER_A
	else:
		current_round = GameRound.PLAYER_B

func _handle_public_supply_async() -> void:
	await _supply_public_cards_with_effects()
	turn_engine.submit_public_supply_completed()

func _supply_public_cards_with_effects() -> void:
	while public_deal.need_supply_hand_card():
		var card_to_supply = skill_manager.pick_card_for_supply(card_manager)
		if card_to_supply != null:
			public_deal.supply_specific_card(card_to_supply)
		else:
			public_deal.supply_hand_card()
		await public_deal.common_suply_public_card

func _handle_exchange_required(payload: Dictionary) -> void:
	var actor: Player = payload.get("player", null)
	if actor == null:
		turn_engine.notify_exchange_completed(false)
		return

	_set_turn_state(actor)
	actor.set_player_state(Player.PlayerState.SELF_ROUND_CHANGE_CARD)
	actor.set_all_hand_card_can_click()
	card_exchange_manager.handle_card_exchange(actor)

func _handle_action_required(payload: Dictionary) -> void:
	var actor: Player = payload.get("player", null)
	if actor == null:
		return

	_set_turn_state(actor)
	actor.set_player_state(Player.PlayerState.SELF_ROUND_UNCHOOSING)
	if not actor.is_ai_player():
		actor.set_all_hand_card_can_click()
		actor.check_hand_card_season()
		return

	await scene_tree.create_timer(0.5).timeout
	_submit_ai_action(actor)

func _submit_ai_action(actor: Player) -> void:
	var opponent = _get_opponent(actor)
	var decision = ai_planner.choose_action(
		match_state,
		actor,
		opponent,
		public_deal,
		ai_difficulty,
		opponent_hand_visible
	)

	if decision.is_empty():
		turn_engine.notify_exchange_completed(false)
		return

	turn_engine.submit_action_selection(decision.get("hand_card", null), decision.get("public_card", null))

func _set_turn_state(actor: Player) -> void:
	var other_player = _get_opponent(actor)
	if other_player != null:
		other_player.set_player_state(Player.PlayerState.WAITING)
		other_player.set_all_hand_card_cannot_click()

func _handle_cards_matched(payload: Dictionary) -> void:
	var actor: Player = payload.get("player", null)
	var hand_card: Card = payload.get("hand_card", null)
	var public_card: Card = payload.get("public_card", null)
	if actor == null or hand_card == null or public_card == null:
		turn_engine.notify_action_resolved([])
		return

	# 无论玩家还是AI，都在此统一把被选择的公共牌从公共池状态中移除，
	# 避免AI路径绕过 PublicCardDeal.on_card_clicked 导致的“幽灵公共牌”问题。
	if public_deal != null:
		public_deal.set_aim_hand_card_empty(public_card)

	actor.handle_card_selection(hand_card, public_card, self)

func _route_card_selection(player_choosing_card: Card, public_choosing_card: Card):
	turn_engine.submit_action_selection(player_choosing_card, public_choosing_card)

func _on_exchange_completed(success: bool):
	if turn_engine:
		turn_engine.notify_exchange_completed(success)

func _on_player_action_resolution_completed(player: Player, action_cards: Array):
	if turn_engine == null:
		return

	var active_player = turn_engine.get_active_player()
	if player != active_player:
		return

	var opponent = _get_opponent(player)
	var action_cards_typed: Array[Card] = []
	for card in action_cards:
		if card is Card:
			action_cards_typed.append(card)

	var skill_result = skill_manager.resolve_turn_skills(player, opponent, action_cards_typed)
	var triggered_skills = skill_result.get("triggered", [])
	if triggered_skills is Array and triggered_skills.size() > 0:
		print("技能已触发，数量: ", triggered_skills.size(), " 详情: ", triggered_skills)
		var debug_entries: Array[Dictionary] = []
		for item in triggered_skills:
			if item is Dictionary:
				debug_entries.append(_build_skill_debug_entry(current_round_index, player, item))
		skill_debug_event.emit({
			"entries": debug_entries,
		})
	if skill_result.has("revealed_card_ids") and skill_result.revealed_card_ids.size() > 0:
		UIManager.get_instance().show_info_tip("技能生效：翻开了对手手牌")

	_refresh_all_hand_visibility()
	turn_engine.notify_action_resolved(action_cards_typed)

func get_current_active_player():
	if turn_engine != null:
		return turn_engine.get_active_player()
	if current_round == GameRound.PLAYER_A:
		return player_a
	if current_round == GameRound.PLAYER_B:
		return player_b
	return null

func _get_opponent(player: Player) -> Player:
	if player == player_a:
		return player_b
	return player_a

func end_game():
	print("游戏结束")
	ui_manager.open_ui("UI_Result")
	var ui_result_instance = ui_manager.get_ui_instance("UI_Result")
	ui_result_instance.z_index = 2999
	ui_result_instance.set_result(player_a.get_score(), player_b.get_score())

func process_special_cards():
	print("检查特殊卡效果")
	if not use_special_cards:
		return

	if not player_a.check_special_cards():
		return

	var ui_main = ui_manager.get_ui_instance("UI_Main")
	if ui_main == null:
		return

	ui_main.send_special_cards_to_player_a()
	if ui_main.has_node("CardAnimTimer"):
		await ui_main.skill_cards_animation_completed

func card_animation_end(card, is_player_choice = false):
	if is_player_choice:
		print("玩家选择卡牌动画结束: ", card.ID, card.Name)
	_refresh_card_visibility(card)

func _refresh_all_hand_visibility() -> void:
	_refresh_player_hand_visibility(player_a)
	_refresh_player_hand_visibility(player_b)

func _refresh_player_hand_visibility(player: Player) -> void:
	if player == null:
		return
	for card in player.get_all_hand_cards():
		_refresh_card_visibility(card)

func _refresh_card_visibility(card: Card) -> void:
	if card == null:
		return
	if _is_card_visible_for_local_player(card):
		card.update_card()
	else:
		card.set_card_back()

func _is_card_visible_for_local_player(card: Card) -> bool:
	# 公共区域和牌堆卡默认可见
	if card.player_owner == null:
		return true

	# 玩家A视角：自己的手牌总是可见
	if card.player_owner == player_a:
		return true

	# 玩家B（对手）手牌默认背面；打开设置后可见
	if card.player_owner == player_b:
		if not player_b.is_card_in_hand(card):
			return true
		if opponent_hand_visible:
			return true
		if match_state != null and match_state.revealed_opponent_hand_cards.has(player_a):
			var revealed_ids: Array = match_state.revealed_opponent_hand_cards[player_a]
			return revealed_ids.has(card.ID)
		return false

	return true

func _build_skill_debug_entry(round_index: int, player: Player, skill_item: Dictionary) -> Dictionary:
	var card_id = int(skill_item.get("card_id", -1))
	var skill_code = str(skill_item.get("skill", "UNKNOWN"))
	var actor_name = _format_player_display_name(player.player_name if player != null else "Unknown")

	var entry := {
		"round": round_index,
		"player": actor_name,
		"card_name": _get_card_name_by_id(card_id),
		"skill_name": _skill_code_to_cn(skill_code),
		"result": _build_skill_result_text(skill_code, skill_item),
	}
	return entry

func _format_player_display_name(raw_name: String) -> String:
	match raw_name:
		"PlayerA":
			return "玩家A"
		"PlayerB":
			return "玩家B"
		_:
			return raw_name

func _build_skill_result_text(skill_code: String, skill_item: Dictionary) -> String:
	match skill_code:
		"COPY_SKILL":
			var from_id = int(skill_item.get("from_card_id", -1))
			return "复制了 %s 的技能" % _get_card_name_by_id(from_id)
		"EXCHANGE_CARD":
			var self_id = int(skill_item.get("self_card_id", -1))
			var opp_id = int(skill_item.get("opponent_card_id", -1))
			return "交换了己方[%s]与对方[%s]" % [_get_card_name_by_id(self_id), _get_card_name_by_id(opp_id)]
		"DISABLE_SKILL":
			var target_id = int(skill_item.get("target_card_id", -1))
			return "禁用了对方[%s]的技能" % _get_card_name_by_id(target_id)
		"OPEN_OPPONENT_HAND":
			var opened_ids = skill_item.get("opened_ids", [])
			var opened_names: Array[String] = []
			if opened_ids is Array:
				for cid in opened_ids:
					opened_names.append(_get_card_name_by_id(int(cid)))
			if opened_names.is_empty():
				return "无可翻开目标"
			return "翻开了对手手牌: %s" % "、".join(opened_names)
		"GUARANTEE_APPEAR":
			var target_names = _target_names_to_text(skill_item.get("targets", []))
			return "下回合补牌保证出现: %s" % target_names
		"INCREASE_APPEAR":
			var target_names2 = _target_names_to_text(skill_item.get("targets", []))
			var probability = float(skill_item.get("probability", 0.0))
			return "下回合补牌出现概率提升(%.0f%%): %s" % [probability * 100.0, target_names2]
		"ADD_SCORE":
			var value = int(skill_item.get("value", 0))
			var target_name = str(skill_item.get("target_name", "")).strip_edges()
			var targets = target_name if target_name != "" else _target_names_to_text(skill_item.get("targets", []))
			if value > 0 and targets != "":
				return "已登记加分效果(+%d)，目标: %s（满足条件时生效）" % [value, targets]
			if value > 0:
				return "已登记加分效果(+%d)（满足条件时生效）" % value
			return "已登记加分效果（满足条件时生效）"
		_:
			return "技能已触发"

func _target_names_to_text(targets) -> String:
	if not (targets is Array):
		return "无"
	var names: Array[String] = []
	for cid in targets:
		names.append(_get_card_name_by_id(int(cid)))
	return "、".join(names)

func _get_card_name_by_id(card_id: int) -> String:
	if card_id <= 0:
		return "未知卡牌"
	var row = table_manager.get_row("Cards", card_id)
	if row != null and not row.is_empty() and row.has("Name"):
		return str(row["Name"])
	return "未知卡牌"

func _skill_code_to_cn(skill_code: String) -> String:
	match skill_code:
		"COPY_SKILL":
			return "复制技能"
		"EXCHANGE_CARD":
			return "交换卡牌"
		"DISABLE_SKILL":
			return "禁用技能"
		"OPEN_OPPONENT_HAND":
			return "翻开对手手牌"
		"GUARANTEE_APPEAR":
			return "保证出现"
		"INCREASE_APPEAR":
			return "增加出现概率"
		"ADD_SCORE":
			return "增加分数"
		_:
			return skill_code

func get_public_card_deal():
	return public_deal

func clear():
	if turn_engine != null and turn_engine.is_connected("turn_event_emitted", Callable(self, "_on_turn_event_emitted")):
		turn_engine.disconnect("turn_event_emitted", Callable(self, "_on_turn_event_emitted"))

	if public_deal != null and public_deal.is_connected("player_choose_public_card", Callable(self, "_route_card_selection")):
		public_deal.disconnect("player_choose_public_card", Callable(self, "_route_card_selection"))

	if player_a != null and player_a.is_connected("action_resolution_completed", Callable(self, "_on_player_action_resolution_completed")):
		player_a.disconnect("action_resolution_completed", Callable(self, "_on_player_action_resolution_completed"))
	if player_b != null and player_b.is_connected("action_resolution_completed", Callable(self, "_on_player_action_resolution_completed")):
		player_b.disconnect("action_resolution_completed", Callable(self, "_on_player_action_resolution_completed"))

	if card_exchange_manager and card_exchange_manager.is_connected("exchange_completed", Callable(self, "_on_exchange_completed")):
		card_exchange_manager.disconnect("exchange_completed", Callable(self, "_on_exchange_completed"))
	if card_exchange_manager:
		card_exchange_manager.clear()

	if public_deal != null:
		public_deal.clear()
	if player_a != null:
		player_a.clear()
	if player_b != null:
		player_b.clear()

	story_manager.clear()
	card_manager.clear()
	skill_manager.reset_for_match()

	if animation_timer != null and animation_timer.is_inside_tree():
		animation_timer.queue_free()
		animation_timer = null







