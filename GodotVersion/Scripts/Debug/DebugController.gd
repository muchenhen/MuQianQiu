extends RefCounted

class_name DebugController

## Debug 控制器 - 集中管理所有调试开关
##
## 使用方式: DebugController.get_instance().xxx = true

static var _instance: DebugController = null

static func get_instance() -> DebugController:
	if _instance == null:
		_instance = DebugController.new()
	return _instance

# ============================================================
# 调试开关
# ============================================================

## 保证指定的基础卡（通过 BaseID）一定分到玩家A手中
var force_card_to_player_a_enabled: bool = true

## 要强制分给玩家A的卡牌 BaseID（303 = 云无月）
var force_card_to_player_a_base_id: int = 303
