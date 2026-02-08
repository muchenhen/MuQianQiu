# 禁用技能逻辑更新计划

## 当前实现分析

### 禁用技能触发流程
1. 当玩家使用带有"禁用技能"的卡牌时，调用 `_register_disable_watch` 函数
2. 该函数将禁用技能注册到 `disable_watchers` 数组中
3. 当对手获得卡牌时，`check_disable_on_opponent_acquire` 函数会检查是否有禁用技能生效

### 当前逻辑的问题
1. 禁用技能不是在玩家获得禁用技能卡时立即生效
2. 无目标的禁用技能没有立即检查对手牌堆中的特殊牌
3. 固定目标的禁用技能没有在检测到基础卡时正确处理

## 需求变更

### 需求1：立即生效
- 当玩家或者AI有"禁用技能"的特殊卡进入到自己的牌堆时立即发动

### 需求2：有目标的特殊卡
- 有目标的特殊卡进入监视状态，持续监视对手是否有符合条件的目标进入牌堆
- 如果在对方牌堆没有检测到目标就持续监测
- 如果检测到对手牌堆有目标卡但是只有基础卡，则进行"发动"，结果是发送失败因为对方只有基础卡，后续就不需要每回合监视了
- 如果发现禁用技能的目标已经进入到自己的牌堆，那么也是进入"发送失败（目标卡在自己手里）"，也不用再每回合进行监视了

### 需求3：无目标的禁用技能
- 需要立即检查对手牌堆中当前的特殊牌，必须立即选择一张没有被禁用技能的特殊牌进行禁用操作
- 可以选择放弃，目标范围只能是对手已经位于牌堆的卡
- 放弃之后是为发动成功（玩家放弃）

## 修改方案

### 1. 修改 `_register_disable_watch` 函数

#### 无目标禁用技能处理
```gdscript
if disable_mode == DISABLE_MODE_PICK_OPPONENT_SPECIAL:
    # 立即获取对手玩家
    var opponent_player: Player = null
    if match_state != null:
        if current_player == match_state.player_a:
            opponent_player = match_state.player_b
        else:
            opponent_player = match_state.player_a
    
    if opponent_player != null:
        # 立即检查对手牌堆中的特殊牌
        var candidates = _collect_disable_pick_candidates(opponent_player)
        if not candidates.is_empty():
            # 让玩家选择目标
            var pick_result = await _resolve_disable_pick_target(current_player, opponent_player, {...})
            
            # 立即检查选中的目标是否存在于对手牌堆中
            var selected_instance_id = int(pick_result.get("selected_instance_id", 0))
            if selected_instance_id > 0:
                var target_card: Card = null
                var all_opponent_cards: Array[Card] = _collect_special_cards_from_player(opponent_player)
                for card in all_opponent_cards:
                    if card != null and card.get_instance_id() == selected_instance_id:
                        target_card = card
                        break
                
                if target_card != null:
                    # 检查是否是基础卡
                    if not target_card.Special:
                        # 目标是基础卡，发动失败
                        events.append(_make_event_by_source(...))
                    else:
                        # 目标是特殊卡，立即禁用
                        if _apply_disable_scope_to_card(disable_scope, target_card):
                            # 禁用成功
                        else:
                            # 禁用失败
                    # 无目标禁用技能使用后就完成，不需要加入监视器
                    _set_entry_state(entry, SkillUseState.USED)
                    return
                else:
                    # 目标不存在，加入监视器继续监视
            else:
                # 用户选择放弃，标记为已使用
        else:
            # 对手没有特殊牌可选，标记为已使用
```

#### 固定目标禁用技能处理
```gdscript
if disable_mode == DISABLE_MODE_FIXED_SINGLE or disable_mode == DISABLE_MODE_FIXED_GROUP:
    var opponent_player: Player = null
    if match_state != null:
        if current_player == match_state.player_a:
            opponent_player = match_state.player_b
        else:
            opponent_player = match_state.player_a
    
    if opponent_player != null:
        var all_opponent_cards: Array[Card] = _collect_special_cards_from_player(opponent_player)
        var hit_cards: Array[Card] = []
        
        for card in all_opponent_cards:
            if card == null:
                continue
            if not _card_matches_target_ids(card, target_ids):
                continue
            # ... 检查重复等
            
        if not hit_cards.is_empty():
            # 检查是否有特殊卡，如果有基础卡则标记为失败
            var has_special_target = false
            var has_basic_only_target = false
            var basic_target_names: Array[String] = []
            
            for target_card in hit_cards:
                if target_card.Special:
                    has_special_target = true
                else:
                    has_basic_only_target = true
                    basic_target_names.append(target_card.Name)
            
            if has_basic_only_target and not has_special_target:
                # 所有目标都是基础卡，发动失败
                events.append(_make_event_by_source(...))
                # 标记监视器为非活动，不再监视
            elif has_special_target:
                # 有特殊卡目标，立即禁用
                # 禁用后标记监视器为非活动
            else:
                # 没有找到任何匹配的目标，继续监视
        else:
            # 没有找到任何匹配的目标，继续监视
```

### 2. 修改 `_find_disable_hit_cards` 函数

需要增强对基础卡的检测逻辑，确保在检测到基础卡时能够正确处理。

### 3. 修改 `check_disable_on_opponent_acquire` 函数

需要添加检测目标是否在自己牌堆中的逻辑，如果目标在自己牌堆中则标记为失败。

## 实施步骤

1. 首先修改 `_register_disable_watch` 函数，实现立即生效逻辑
2. 修改 `_find_disable_hit_cards` 函数，增强目标检测能力
3. 修改 `check_disable_on_opponent_acquire` 函数，添加目标位置检测
4. 测试各种场景下的功能表现

## 预期结果

1. 无目标禁用技能立即生效，自动选择对手牌堆中的特殊牌
2. 固定目标禁用技能立即检查对手牌堆，如发现目标是基础卡则失败
3. 目标在自己牌堆中的情况被正确识别并标记为失败
4. 监视逻辑按预期工作，只在必要时持续监视