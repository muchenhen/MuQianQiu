extends Node

class_name SkillManager

static var instance: SkillManager = null

# 获取单例实例
static func get_instance() -> SkillManager:
    if instance == null:
        instance = SkillManager.new()
    return instance

# 技能注册表 - 保存每个技能类型的处理函数
var skill_handlers = {}

func _init():
    # 注册各种技能处理函数
    register_skill_handlers()

# 注册所有技能的处理函数
func register_skill_handlers():
    skill_handlers[CardSkill.SKILL_TYPE.GUARANTEE_APPEAR] = Callable(self, "handle_guarantee_appear")
    skill_handlers[CardSkill.SKILL_TYPE.INCREASE_APPEAR] = Callable(self, "handle_increase_appear")
    skill_handlers[CardSkill.SKILL_TYPE.DISABLE_SKILL] = Callable(self, "handle_disable_skill")
    skill_handlers[CardSkill.SKILL_TYPE.COPY_SKILL] = Callable(self, "handle_copy_skill")
    skill_handlers[CardSkill.SKILL_TYPE.EXCHANGE_CARD] = Callable(self, "handle_exchange_card")
    skill_handlers[CardSkill.SKILL_TYPE.OPEN_OPPONENT_HAND] = Callable(self, "handle_open_opponent_hand")
    skill_handlers[CardSkill.SKILL_TYPE.EXCHANGE_DISABLE_SKILL] = Callable(self, "handle_exchange_disable_skill")
    # ADD_SCORE已经由ScoreManager处理，这里不需要重复注册

# 处理发牌前的技能效果
func process_card_distribution_skills(cards: Array, player_a: Player, player_b: Player) -> Array:
    # 处理"保证出现"和"增加出现概率"技能
    var modified_cards = cards.duplicate()
    
    # 收集两名玩家的技能效果
    var player_a_skills = collect_player_skills(player_a)
    var player_b_skills = collect_player_skills(player_b)
    
    # 处理保证出现技能
    modified_cards = handle_guarantee_appear_skills(modified_cards, player_a, player_a_skills, player_b, player_b_skills)
    
    # 处理增加出现概率技能
    modified_cards = handle_increase_appear_skills(modified_cards, player_a_skills, player_b_skills)
    
    return modified_cards

# 收集玩家的所有技能
func collect_player_skills(player: Player) -> Dictionary:
    var skills = {
        "guarantee_appear": [],
        "increase_appear": [],
        "disable_skill": [],
        "copy_skill": [],
        "exchange_card": [],
        "open_opponent_hand": [],
        "exchange_disable_skill": []
    }
    
    var selected_special_card_ids = player.get_selected_special_cards()
    var table_manager = TableManager.get_instance()
    
    for card_id in selected_special_card_ids:
        var skill_data = table_manager.get_row("Skills", card_id)
        if skill_data:
            # 处理技能1
            process_skill_data(skills, skill_data, "Skill1Type", "Skill1Target", "Skill1TargetID", "Skill1Value")
            # 处理技能2
            process_skill_data(skills, skill_data, "Skill2Type", "Skill2Target", "Skill2TargetID", "Skill2Value")
    
    return skills

# 处理技能数据并添加到对应类别
func process_skill_data(skills: Dictionary, skill_data: Dictionary, type_key: String, target_key: String, target_id_key: String, value_key: String):
    if not skill_data.has(type_key) or not skill_data[type_key]:
        return
        
    var skill_type = skill_data[type_key]
    var skill_info = {
        "type": skill_type,
        "target": skill_data.get(target_key, ""),
        "target_id": skill_data.get(target_id_key, ""),
        "value": skill_data.get(value_key, "")
    }
    
    match skill_type:
        "保证出现":
            skills["guarantee_appear"].append(skill_info)
        "增加出现概率":
            skills["increase_appear"].append(skill_info)
        "禁用技能":
            skills["disable_skill"].append(skill_info)
        "复制技能":
            skills["copy_skill"].append(skill_info)
        "交换卡牌":
            skills["exchange_card"].append(skill_info)
        "翻开对手手牌":
            skills["open_opponent_hand"].append(skill_info)
        "交换后无效":
            skills["exchange_disable_skill"].append(skill_info)

# 处理保证出现技能
func handle_guarantee_appear_skills(cards: Array, player_a: Player, player_a_skills: Dictionary, player_b: Player, player_b_skills: Dictionary) -> Array:
    # 解析两名玩家的保证出现目标
    var player_a_targets = parse_guarantee_targets(player_a_skills["guarantee_appear"])
    var player_b_targets = parse_guarantee_targets(player_b_skills["guarantee_appear"])
    
    # 处理冲突
    resolve_guarantee_conflicts(player_a_targets, player_b_targets)
    
    # 重新排序卡牌以确保保证出现的卡牌被适当分配
    return reorder_cards_for_guarantee(cards, player_a, player_a_targets, player_b, player_b_targets)

# 解析保证出现的目标ID
func parse_guarantee_targets(guarantee_skills: Array) -> Array:
    var targets = []
    
    for skill in guarantee_skills:
        var target_id = skill["target_id"]
        var parsed_ids = parse_target_id_string(target_id)
        targets.append_array(parsed_ids)
    
    return targets

# 解析目标ID字符串（可能是单个ID、列表或特殊格式）
func parse_target_id_string(target_id) -> Array:
    var result = []
    
    # 处理不同格式的目标ID
    if typeof(target_id) == TYPE_INT:
        result.append(target_id)
    elif typeof(target_id) == TYPE_STRING:
        if target_id.is_valid_int():
            # 单个数字ID
            result.append(int(target_id))
        elif target_id.begins_with("(") and target_id.ends_with(")"):
            # 格式如 "(101,102,103)"
            var content = target_id.substr(1, target_id.length() - 2)
            var parts = content.split(",")
            
            for part in parts:
                var trimmed = part.strip_edges()
                if trimmed.is_valid_int():
                    result.append(int(trimmed))
        elif ";" in target_id:
            # 格式如 "古剑晗光;昭明;无名之剑"
            var parts = target_id.split(";")
            
            # 这里可能需要通过名称查找对应的ID
            for part in parts:
                var id = get_card_id_by_name(part.strip_edges())
                if id > 0:
                    result.append(id)
    
    return result

# 根据卡牌名称查找ID
func get_card_id_by_name(card_name: String) -> int:
    var table_manager = TableManager.get_instance()
    var cards_table = table_manager.get_table("Cards")
    
    for id in cards_table.keys():
        if cards_table[id]["Name"] == card_name:
            return id
    
    print("未找到卡牌: ", card_name)
    return -1

# 解决两个玩家保证出现技能的冲突
func resolve_guarantee_conflicts(player_a_targets: Array, player_b_targets: Array):
    var conflicts = []
    
    for target_id in player_a_targets:
        if target_id in player_b_targets:
            conflicts.append(target_id)
    
    for conflict_id in conflicts:
        # 随机决定哪个玩家获得冲突卡牌的优先权
        if randf() > 0.5:
            # 玩家A获得优先权
            print("玩家A获得卡牌", conflict_id, "的优先权")
            player_b_targets.erase(conflict_id)
        else:
            # 玩家B获得优先权
            print("玩家B获得卡牌", conflict_id, "的优先权")
            player_a_targets.erase(conflict_id)

# 重新排序卡牌以确保保证出现的卡牌被分配给正确的玩家
func reorder_cards_for_guarantee(cards: Array, player_a: Player, player_a_targets: Array, player_b: Player, player_b_targets: Array) -> Array:
    # 创建卡牌ID到卡牌对象的映射
    var card_map = {}
    for card in cards:
        card_map[card.ID] = card
    
    # 创建新的卡牌顺序
    var reordered_cards = []
    var remaining_cards = cards.duplicate()
    
    # 为玩家A保留保证出现的卡牌
    var player_a_guaranteed = []
    for target_id in player_a_targets:
        if card_map.has(target_id):
            player_a_guaranteed.append(card_map[target_id])
            remaining_cards.erase(card_map[target_id])
    
    # 为玩家B保留保证出现的卡牌
    var player_b_guaranteed = []
    for target_id in player_b_targets:
        if card_map.has(target_id):
            player_b_guaranteed.append(card_map[target_id])
            remaining_cards.erase(card_map[target_id])
    
    # 洗牌剩余卡牌
    remaining_cards.shuffle()
    
    # 确保两个玩家都有足够的卡牌
    var player_a_count = player_a_guaranteed.size()
    var player_b_count = player_b_guaranteed.size()
    var max_hand_cards = 10  # 假设每个玩家最多有10张手牌
    
    # 为玩家A添加足够的随机卡牌
    while player_a_count < max_hand_cards / 2 and not remaining_cards.is_empty():
        player_a_guaranteed.append(remaining_cards.pop_front())
        player_a_count += 1
    
    # 为玩家B添加足够的随机卡牌
    while player_b_count < max_hand_cards / 2 and not remaining_cards.is_empty():
        player_b_guaranteed.append(remaining_cards.pop_front())
        player_b_count += 1
    
    # 随机洗牌玩家A和玩家B的牌组，保持保证出现的特性但增加随机性
    player_a_guaranteed.shuffle()
    player_b_guaranteed.shuffle()
    
    # 合并所有卡牌
    # 按照交替方式组合A和B的牌，模拟实际发牌过程
    var max_cards = max(player_a_guaranteed.size(), player_b_guaranteed.size())
    for i in range(max_cards):
        if i < player_a_guaranteed.size():
            reordered_cards.append(player_a_guaranteed[i])
        if i < player_b_guaranteed.size():
            reordered_cards.append(player_b_guaranteed[i])
    
    # 添加剩余的卡牌（公共区域等）
    reordered_cards.append_array(remaining_cards)
    
    return reordered_cards

# 处理增加出现概率技能
func handle_increase_appear_skills(cards: Array, player_a_skills: Dictionary, player_b_skills: Dictionary) -> Array:
    # 解析增加出现概率的目标
    var player_a_probs = parse_increase_probability_targets(player_a_skills["increase_appear"])
    var player_b_probs = parse_increase_probability_targets(player_b_skills["increase_appear"])
    
    # 如果没有增加出现概率的技能，直接返回原卡组
    if player_a_probs.is_empty() and player_b_probs.is_empty():
        return cards
    
    # 应用增加出现概率效果
    return apply_increased_probability(cards, player_a_probs, player_b_probs)

# 解析增加出现概率的目标
func parse_increase_probability_targets(increase_skills: Array) -> Dictionary:
    var probs = {}
    
    for skill in increase_skills:
        var target_id = skill["target_id"]
        var value = 2.0  # 默认提升为2倍概率
        
        if skill["value"] and str(skill["value"]).is_valid_float():
            value = float(skill["value"])
        
        var parsed_ids = parse_target_id_string(target_id)
        for id in parsed_ids:
            probs[id] = value
    
    return probs

# 应用增加出现概率效果
func apply_increased_probability(cards: Array, player_a_probs: Dictionary, player_b_probs: Dictionary) -> Array:
    # 创建权重映射
    var weights = {}
    
    for card in cards:
        var weight = 1.0
        
        # 检查玩家A的增加概率
        if player_a_probs.has(card.ID):
            weight *= player_a_probs[card.ID]
        
        # 检查玩家B的增加概率
        if player_b_probs.has(card.ID):
            weight *= player_b_probs[card.ID]
        
        weights[card] = weight
    
    # 根据权重排序卡牌
    cards.sort_custom(func(a, b): return weights[a] > weights[b])
    
    return cards

# 其他技能处理函数...
func handle_disable_skill(player: Player, opponent: Player, card: Card, skill_info: Dictionary):
    # 禁用技能逻辑实现
    pass

func handle_copy_skill(player: Player, opponent: Player, card: Card, skill_info: Dictionary):
    # 复制技能逻辑实现
    pass

func handle_exchange_card(player: Player, opponent: Player, card: Card, skill_info: Dictionary):
    # 交换卡牌逻辑实现
    pass

func handle_open_opponent_hand(player: Player, opponent: Player, card: Card, skill_info: Dictionary):
    # 翻开对手手牌逻辑实现
    pass

func handle_exchange_disable_skill(player: Player, opponent: Player, card: Card, skill_info: Dictionary):
    # 交换后禁用技能逻辑实现
    pass

# 处理玩家回合开始时的技能效果
func process_turn_start_skills(player: Player, opponent: Player):
    # 处理玩家回合开始时触发的技能
    pass

# 处理玩家回合结束时的技能效果
func process_turn_end_skills(player: Player, opponent: Player):
    # 处理玩家回合结束时触发的技能
    pass

# 处理卡牌使用时的技能效果
func process_card_use_skills(player: Player, opponent: Player, card: Card, target_card = null):
    # 处理卡牌使用时触发的技能
    pass