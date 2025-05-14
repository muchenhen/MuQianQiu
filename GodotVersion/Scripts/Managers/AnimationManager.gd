extends Node

class_name AnimationManager

var animated_objects = {}

static var instance: AnimationManager = null

# 动画速度全局缩放因子，用于控制动画速度
var anim_speed_scale = 2.0

enum EaseType {
	LINEAR,
	EASE_IN,
	EASE_OUT,
	EASE_IN_OUT,
	BOUNCE,
	ELASTIC
}

static func get_instance() -> AnimationManager:
	if instance == null:
		instance = AnimationManager.new()
	return instance

func _process(delta):
	# 创建一个待移除的keys列表，避免在遍历时修改字典
	var to_remove = []
	var anim_types_to_remove = {}
	
	for obj in animated_objects.keys():
		# 检查对象是否仍有效
		if not is_instance_valid(obj) or obj == null:
			to_remove.append(obj)
			continue
			
		# 为这个对象创建一个待移除的动画类型列表
		anim_types_to_remove[obj] = []
		
		for anim_type in animated_objects[obj].keys():
			# 检查动画数据是否有效
			if not animated_objects[obj].has(anim_type) or not animated_objects[obj][anim_type].has("active"):
				anim_types_to_remove[obj].append(anim_type)
				continue
				
			if animated_objects[obj][anim_type]["active"]:
				_update_animation(obj, anim_type, delta)
			else:
				# 如果动画不再活跃，将其加入移除列表
				anim_types_to_remove[obj].append(anim_type)
	
	# 清理无效的动画类型
	for obj in anim_types_to_remove.keys():
		if is_instance_valid(obj) and animated_objects.has(obj):
			for anim_type in anim_types_to_remove[obj]:
				if animated_objects[obj].has(anim_type):
					animated_objects[obj].erase(anim_type)
			
			# 如果对象没有任何动画，将其从字典中移除
			if animated_objects[obj].size() == 0:
				to_remove.append(obj)
	
	# 清理无效的对象
	for obj in to_remove:
		if animated_objects.has(obj):  # 安全检查
			animated_objects.erase(obj)

func start_linear_movement_combined(
	obj: Node, 
	target_pos: Vector2, 
	target_rotation: float, 
	duration: float = 1.0, 
	ease_type: EaseType = EaseType.LINEAR, 
	callback: Callable = Callable(), 
	callback_args: Array = []
):
	_add_animation(obj, "linear_movement_combined", {
		"start_pos": obj.global_position,
		"target_pos": target_pos,
		"start_rotation": obj.rotation,
		"target_rotation": target_rotation,
		"duration": duration / anim_speed_scale,
		"elapsed_time": 0,
		"active": true,
		"ease_type": ease_type,
		"callback": callback,
		"callback_args": callback_args
	})

func start_linear_movement_pos(obj: Node, target: Vector2, duration: float = 0.5, ease_type: EaseType = EaseType.LINEAR, callback: Callable = Callable(), callback_args: Array = []):
	_add_animation(obj, "linear_movement_pos", {
		"start_pos": obj.global_position,
		"target": target,
		"duration": duration / anim_speed_scale,
		"elapsed_time": 0,
		"active": true,
		"ease_type": ease_type,
		"callback": callback,
		"callback_args": callback_args
	})

func start_linear_movement_rotation(obj: Node, target: float, duration: float = 0.5, ease_type: EaseType = EaseType.LINEAR, callback: Callable = Callable(), callback_args: Array = []):
	_add_animation(obj, "linear_movement_rotation", {
		"start_rotation": obj.rotation,
		"target": target,
		"duration": duration / anim_speed_scale,
		"elapsed_time": 0,
		"active": true,
		"ease_type": ease_type,
		"callback": callback,
		"callback_args": callback_args
	})


# 启动给定对象的线性 alpha 动画。
#
# 此函数将对象的 modulate 属性的 alpha 值从当前值动画到目标值，持续时间为指定的秒数。
#
# @param obj 要应用 alpha 动画的节点。
# @param target_alpha 要动画到的目标 alpha 值。
# @param duration 动画的持续时间（秒）。
# @param ease_type 要应用于动画的缓动类型。默认为 EaseType.LINEAR。
# @param callback 动画完成时要调用的可选 Callable。默认为空 Callable。
# @param callback_args 传递给回调的可选参数数组。默认为空数组。
func start_linear_alpha(obj: Node, target_alpha: float, duration: float = 0.5, ease_type: EaseType = EaseType.LINEAR, callback: Callable = Callable(), callback_args: Array = []):
	# 安全检查：确保对象有modulate属性且有效
	if not is_instance_valid(obj) or not "modulate" in obj or obj.modulate == null:
		return
		
	# 安全获取当前alpha值
	var current_alpha = obj.modulate.a
	
	_add_animation(obj, "linear_alpha", {
		"start_alpha": current_alpha,
		"target_alpha": target_alpha,
		"duration": duration / anim_speed_scale,
		"elapsed_time": 0,
		"active": true,
		"ease_type": ease_type,
		"callback": callback,
		"callback_args": callback_args
	})

func _add_animation(obj: Node, anim_type: String, anim_data: Dictionary):
	if not animated_objects.has(obj):
		animated_objects[obj] = {}
	animated_objects[obj][anim_type] = anim_data

func _update_animation(obj: Node, anim_type: String, delta: float):
	# 检查对象和动画类型是否仍然存在
	if not animated_objects.has(obj) or not animated_objects[obj].has(anim_type):
		return
		
	var anim = animated_objects[obj][anim_type]
	
	# 检查必要的动画参数是否存在
	if not anim.has("elapsed_time") or not anim.has("duration"):
		anim["active"] = false
		return
		
	# 安全检查：确保对象有效，否则立即结束动画
	if not is_instance_valid(obj):
		# 如果对象无效，直接结束当前动画
		anim["active"] = false
		return
	
	# 尝试访问对象属性前，确保对象有所有需要的属性
	match anim_type:
		"linear_movement_combined", "linear_movement_pos", "parabolic_movement", "movement_with_scale":
			if not obj.has_method("get_position") and not "position" in obj:
				anim["active"] = false
				return
		"linear_movement_rotation", "circular_movement", "spread_out_movement":
			if not "rotation" in obj:
				anim["active"] = false
				return
		"linear_alpha":
			if not "modulate" in obj:
				anim["active"] = false
				return
		
	anim["elapsed_time"] += delta
	var raw_t = min(anim["elapsed_time"] / anim["duration"], 1.0)
	
	match anim_type:
		"linear_movement_combined":
			# 检查所有必需参数是否存在
			if not anim.has("start_pos") or not anim.has("target_pos") or not anim.has("start_rotation") or not anim.has("target_rotation") or not anim.has("ease_type"):
				anim["active"] = false
				return
				
			var t = _apply_easing(raw_t, anim["ease_type"])
			obj.position = anim["start_pos"].lerp(anim["target_pos"], t)
			obj.rotation = lerp_angle(anim["start_rotation"], anim["target_rotation"], t)
			
		"linear_movement_pos":
			# 检查所有必需参数是否存在
			if not anim.has("start_pos") or not anim.has("target") or not anim.has("ease_type"):
				anim["active"] = false
				return
				
			var t = _apply_easing(raw_t, anim["ease_type"])
			obj.position = anim["start_pos"].lerp(anim["target"], t)

		"linear_movement_rotation":
			# 检查所有必需参数是否存在
			if not anim.has("start_rotation") or not anim.has("target") or not anim.has("ease_type"):
				anim["active"] = false
				return
				
			var t = _apply_easing(raw_t, anim["ease_type"])
			obj.rotation = lerp_angle(anim["start_rotation"], anim["target"], t)
		
		"parabolic_movement":
			# 检查所有必需参数是否存在
			if not anim.has("start_pos") or not anim.has("target") or not anim.has("height"):
				anim["active"] = false
				return
				
			var pos = anim["start_pos"].lerp(anim["target"], raw_t)
			pos.y -= sin(raw_t * PI) * anim["height"]
			obj.global_position = pos
		
		"circular_movement":
			# 检查所有必需参数是否存在
			if not anim.has("start_angle") or not anim.has("center") or not anim.has("radius"):
				anim["active"] = false
				return
				
			var angle = anim["start_angle"] + raw_t * 2 * PI
			obj.global_position = anim["center"] + Vector2(cos(angle), sin(angle)) * anim["radius"]
		
		"movement_with_scale":
			# 检查所有必需参数是否存在
			if not anim.has("start_pos") or not anim.has("target") or not anim.has("start_scale") or not anim.has("target_scale"):
				anim["active"] = false
				return
			
			# 检查对象是否有scale属性
			if not "scale" in obj:
				anim["active"] = false
				return
				
			obj.global_position = anim["start_pos"].lerp(anim["target"], raw_t)
			obj.scale = anim["start_scale"].lerp(anim["target_scale"], raw_t)
		
		"rotation":
			# 检查所有必需参数是否存在
			if not anim.has("speed"):
				anim["active"] = false
				return
				
			obj.rotate(anim["speed"] * delta)

		"spread_out_movement":
			# 检查所有必需参数是否存在
			if not anim.has("start_angle") or not anim.has("center") or not anim.has("radius"):
				anim["active"] = false
				return
				
			var eased_t = ease(raw_t, 2.5)
			var current_radius = anim["radius"] * eased_t
			var current_angle = anim["start_angle"] + eased_t * PI * 0.25
			obj.global_position = anim["center"] + Vector2(cos(current_angle), sin(current_angle)) * current_radius
			obj.rotation = current_angle + PI / 2

		"linear_alpha":
			# 检查所有必需参数是否存在
			if not anim.has("start_alpha") or not anim.has("target_alpha") or not anim.has("ease_type"):
				anim["active"] = false
				return
				
			# 安全检查：确保对象有modulate属性并且可以访问其alpha值
			if not "modulate" in obj or obj.modulate == null:
				anim["active"] = false
				return
			
			# 安全操作：创建一个新的Color对象进行修改，避免直接修改.a属性导致的问题
			var new_modulate = obj.modulate
			new_modulate.a = lerp(anim["start_alpha"], anim["target_alpha"], _apply_easing(raw_t, anim["ease_type"]))
			obj.modulate = new_modulate
	
	if raw_t >= 1.0:
		_end_animation(obj, anim_type)

func _end_animation(obj: Node, anim_type: String):
	# 确保对象和动画类型仍然存在
	if not animated_objects.has(obj) or not animated_objects[obj].has(anim_type):
		return
		
	var anim = animated_objects[obj][anim_type]
	
	# 确保对象仍然有效
	if not is_instance_valid(obj):
		# 如果对象无效，直接移除相关动画数据
		animated_objects.erase(obj)
		return
	
	# 在动画结束时强制设置最终位置，每种类型做安全检查
	match anim_type:
		"linear_movement_combined":
			if anim.has("target_pos") and anim.has("target_rotation") and "position" in obj and "rotation" in obj:
				obj.position = anim["target_pos"]
				obj.rotation = anim["target_rotation"]
		"linear_movement_pos":
			if anim.has("target") and "position" in obj:
				obj.position = anim["target"]
		"linear_movement_rotation":
			if anim.has("target") and "rotation" in obj:
				obj.rotation = anim["target"]
		"linear_alpha":
			if anim.has("target_alpha") and "modulate" in obj and obj.modulate != null:
				var final_modulate = obj.modulate
				final_modulate.a = anim["target_alpha"]
				obj.modulate = final_modulate
		"parabolic_movement":
			if anim.has("target") and obj.has_method("set_global_position"):
				obj.global_position = anim["target"]
		"circular_movement":
			if anim.has("start_angle") and anim.has("center") and anim.has("radius") and obj.has_method("set_global_position"):
				var final_angle = anim["start_angle"] + 2 * PI
				obj.global_position = anim["center"] + Vector2(cos(final_angle), sin(final_angle)) * anim["radius"]
		"movement_with_scale":
			if anim.has("target") and anim.has("target_scale") and "global_position" in obj and "scale" in obj:
				obj.global_position = anim["target"]
				obj.scale = anim["target_scale"]
		"spread_out_movement":
			if anim.has("start_angle") and anim.has("center") and anim.has("radius") and obj.has_method("set_global_position") and "rotation" in obj:
				var final_angle = anim["start_angle"] + PI * 0.25
				obj.global_position = anim["center"] + Vector2(cos(final_angle), sin(final_angle)) * anim["radius"]
				obj.rotation = final_angle + PI / 2
	
	anim["active"] = false
	if anim.has("callback") and anim["callback"].is_valid():
		anim["callback"].callv(anim.get("callback_args", []))
	
	if not _has_active_animations(obj):
		animated_objects.erase(obj)

func _has_active_animations(obj: Node) -> bool:
	if not animated_objects.has(obj):
		return false
	for anim_type in animated_objects[obj].keys():
		if animated_objects[obj][anim_type]["active"]:
			return true
	return false

func is_object_animating(obj: Node, anim_type: String = "") -> bool:
	if not animated_objects.has(obj):
		return false
	if anim_type == "":
		return _has_active_animations(obj)
	return animated_objects[obj].has(anim_type) and animated_objects[obj][anim_type]["active"]

func _apply_easing(t: float, ease_type: EaseType) -> float:
	match ease_type:
		EaseType.LINEAR:
			return t
		EaseType.EASE_IN:
			return t * t
		EaseType.EASE_OUT:
			return 1.0 - (1.0 - t) * (1.0 - t)
		EaseType.EASE_IN_OUT:
			return 0.5 - cos(t * PI) / 2.0
		EaseType.BOUNCE:
			if t < 0.5:
				return 4.0 * t * t
			else:
				return (t - 1.0) * (2.0 * t - 2.0) * (2.0 * t - 2.0) + 1.0
		EaseType.ELASTIC:
			return sin(-13.0 * (t + 1.0) * PI / 2.0) * pow(2.0, -10.0 * t) + 1.0
		_:
			return t
	
# 取消指定对象的当前所有动画
func cancel_animations(obj: Node = null) -> void:
	# 如果指定了对象，则只取消该对象的动画
	if obj != null and is_instance_valid(obj):
		if animated_objects.has(obj):
			animated_objects.erase(obj)
		return
	
	# 如果未指定对象，取消所有动画
	animated_objects.clear()
	
# 安全地应用最终属性值，即使没有动画在运行
func apply_final_properties(obj: Node, anim_type: String, final_values: Dictionary) -> void:
	if not is_instance_valid(obj):
		return
		
	match anim_type:
		"linear_movement_pos":
			if "target_pos" in final_values and "position" in obj:
				obj.position = final_values["target_pos"]
		"linear_movement_rotation":
			if "target_rotation" in final_values and "rotation" in obj:
				obj.rotation = final_values["target_rotation"]
		"linear_alpha":
			if "target_alpha" in final_values and "modulate" in obj and obj.modulate != null:
				var final_modulate = obj.modulate
				final_modulate.a = final_values["target_alpha"]
				obj.modulate = final_modulate
