extends Node

class_name Player

var player_name: String = "Player"

var hand_cards = {}

var deal_cards = {}

var player_score: int = 0

var player_finish_stories = []

func _ready() -> void:
    pass

func set_hand_cards(cards: Array) -> void:
    hand_cards = cards

func set_one_hand_card(card: Node) -> void:
    hand_cards[card.ID] = card


