extends Node

class_name PublicCardDeal

var player_a = null
var player_b = null

class PublicHandCardInfo:
	var card: Node
	var position: Vector2
	var rotation: float
	var isEmpty: bool

	func _init(p_card = null, p_position = Vector2(), p_rotation = 0, p_isEmpty = true):
		self.card = p_card
		self.position = p_position
		self.rotation = p_rotation
		self.isEmpty = p_isEmpty

var hand_cards = {}

const PUBLIC_HAND_MAX = 8


func initialize() -> void:
	# 初始化公共区域手牌的每一个位置
	pass

func bind_players(p_a, p_b) -> void:
	player_a = p_a
	player_b = p_b
	player_a.connect("player_choose_card", Callable(self, "on_player_choose_card"))
	player_b.connect("player_choose_card", Callable(self, "on_player_choose_card"))

func set_one_hand_card(card, position, rotation) -> void:
	hand_cards[hand_cards.size()+1] = PublicHandCardInfo.new( card, position, rotation, false)
	card.connect("card_clicked", Callable(self, "on_card_clicked"))

func on_card_clicked(card):
	print("Card clicked: ", card.Name, " ID: ", card.ID)

func on_player_choose_card(player):
	set_all_hand_card_unchooesd()
	print("Player choose card: ", player.player_name)
	var player_current_choosing_card_id = player.current_choosing_card_id

	if player_current_choosing_card_id == -1:
		set_all_hand_card_unchooesd()
		return
		
	var current_choosing_card = player.hand_cards[player.current_choosing_card_id]
	var season = current_choosing_card.Season
	set_aim_season_hand_card_chooesd(season)

func set_all_hand_card_unchooesd() -> void:
	for i in hand_cards.keys():
		var card_info = hand_cards[i]
		if not card_info.isEmpty:
			card_info.card.set_card_unchooesd()

func set_aim_season_hand_card_chooesd(season) -> void:
	for i in hand_cards.keys():
		var card_info = hand_cards[i]
		if not card_info.isEmpty:
			if card_info.card.Season == season:
				card_info.card.set_card_chooesd()