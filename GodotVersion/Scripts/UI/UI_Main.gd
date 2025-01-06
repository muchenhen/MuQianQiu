extends Node

class_name UI_Main

@onready var player_a_deal:Button = $Cards/PlayerADeal
@onready var player_b_deal:Button = $Cards/PlayerBDeal

func _ready() -> void:
    # player_a_deal绑定点击事件
    player_a_deal.connect("pressed", Callable(self, "_on_player_a_deal_clcik"))
    # player_b_deal绑定点击事件
    player_b_deal.connect("pressed", Callable(self, "_on_player_b_deal_clcik"))

func _on_player_a_deal_clcik():
    print("玩家A牌堆点击")

func _on_player_b_deal_clcik():
    print("玩家B牌堆点击")