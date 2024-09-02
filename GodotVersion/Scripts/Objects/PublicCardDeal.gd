extends Node

class_name PublicCardDeal

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

func set_one_hand_card(card, position, rotation) -> void:
	hand_cards[hand_cards.size()+1] = PublicHandCardInfo.new( card, position, rotation, false)
	card.connect("card_clicked", Callable(self, "on_card_clicked"))

func on_card_clicked(card):
	print("Card clicked: ", card.Name, " ID: ", card.ID)