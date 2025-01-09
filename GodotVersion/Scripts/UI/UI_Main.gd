extends Node

class_name UI_Main

@onready var player_a_deal:Button = $Cards/PlayerADeal
@onready var player_b_deal:Button = $Cards/PlayerBDeal

var ui_manager:UIManager = UIManager.get_instance()

func _ready() -> void:
	# player_a_deal绑定点击事件
	player_a_deal.connect("pressed", Callable(self, "_on_player_a_deal_clcik"))
	# player_b_deal绑定点击事件
	player_b_deal.connect("pressed", Callable(self, "_on_player_b_deal_clcik"))

func _on_player_a_deal_clcik():
	print("玩家A牌堆点击")
	var deal_status: UI_DealStatus = UIManager.get_instance().ensure_get_ui_instance("UI_DealStatus")
	ui_manager.open_ui_instance(deal_status)
	ui_manager.move_ui_instance_to_top(deal_status)
	deal_status.set_card_info_by_index_with_id(0, 301)

	

func _on_player_b_deal_clcik():
	print("玩家B牌堆点击")
