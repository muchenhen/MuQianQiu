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
var force_card_to_player_a_enabled: bool = false

## 要强制分给玩家A的卡牌 BaseID（303 = 云无月）
var force_card_to_player_a_base_id: int = 303

## 将所有特殊卡技能强制覆盖为“交换卡牌”
## - 仅影响技能类型判定，不修改数据表原始内容
## - 推荐仅在调试时开启
var force_all_special_skills_to_exchange_enabled: bool = false

## 保证指定卡牌ID一定分到玩家A手中
## - 仅影响开局发牌
## - 会优先在玩家A发牌轮次发出以下卡牌
var force_specific_cards_to_player_a_enabled: bool = false

## 要强制分给玩家A的卡牌ID列表
var force_specific_cards_to_player_a_ids: Array[int] = [205, 224, 225, 226]
