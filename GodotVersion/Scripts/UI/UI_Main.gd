extends Node

class_name UI_Main

@onready var player_a_deal:Button = $PlayerADeal
@onready var player_b_deal:Button = $PlayerBDeal

var ui_manager:UIManager = UIManager.get_instance()

func _ready() -> void:
	# player_a_deal绑定点击事件
	player_a_deal.connect("pressed", Callable(self, "_on_player_a_deal_clcik"))
	# player_b_deal绑定点击事件
	player_b_deal.connect("pressed", Callable(self, "_on_player_b_deal_clcik"))

# 将两个点击牌堆的按钮移动到最上面

func _on_player_a_deal_clcik():
	print("玩家A牌堆点击")
	var player_a = GameManager.instance.player_a
	var deal_status:UI_DealStatus = ui_manager.open_ui("UI_DealStatus")
	ui_manager.move_ui_instance_to_top(deal_status)
	deal_status.update_deal_status_by_player(player_a)

func _on_player_b_deal_clcik():
	print("玩家B牌堆点击")
