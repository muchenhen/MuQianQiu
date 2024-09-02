extends Node

class_name Player

var card_manager = CardManager.get_instance()

var player_name: String = "Player"

var hand_cards = {}

var deal_cards = {}

var player_score: int = 0

var player_finish_stories = []

var hand_cards_pos_array = []

enum PlayerPos{
    A = 0,
    B = 1
}

func initialize(player_pos) -> void:
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


