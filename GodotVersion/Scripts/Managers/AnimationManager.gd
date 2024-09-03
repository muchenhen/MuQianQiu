extends Node

class_name AnimationManager

var animated_objects = {}

enum EaseType {
	LINEAR,
	EASE_IN,
	EASE_OUT,
	EASE_IN_OUT,
	BOUNCE,
	ELASTIC
}

func _process(delta):
	for obj in animated_objects.keys():
		for anim_type in animated_objects[obj].keys():
			if animated_objects[obj][anim_type]["active"]:
				_update_animation(obj, anim_type, delta)

func start_linear_movement_pos(obj: Node, target: Vector2, duration: float, ease_type: EaseType = EaseType.LINEAR, callback: Callable = Callable(), callback_args: Array = []):
	_add_animation(obj, "linear_movement_pos", {
		"start_pos": obj.global_position,
		"target": target,
		"duration": duration,
		"elapsed_time": 0,
		"active": true,
		"ease_type": ease_type,
		"callback": callback,
		"callback_args": callback_args
	})

func start_linear_movement_rotation(obj: Node, target: float, duration: float, ease_type: EaseType = EaseType.LINEAR, callback: Callable = Callable(), callback_args: Array = []):
	_add_animation(obj, "linear_movement_rotation", {
		"start_rotation": obj.rotation,
		"target": target,
		"duration": duration,
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
	var anim = animated_objects[obj][anim_type]
	anim["elapsed_time"] += delta
	var raw_t = min(anim["elapsed_time"] / anim["duration"], 1.0)
	
	match anim_type:
		"linear_movement_pos":
			var t = _apply_easing(raw_t, anim["ease_type"])
			obj.position = anim["start_pos"].lerp(anim["target"], t)

		"linear_movement_rotation":
			var t = _apply_easing(raw_t, anim["ease_type"])
			obj.rotation = lerp_angle(anim["start_rotation"], anim["target"], t)
		
		"parabolic_movement":
			var pos = anim["start_pos"].lerp(anim["target"], raw_t)
			pos.y -= sin(raw_t * PI) * anim["height"]
			obj.global_position = pos
		
		"circular_movement":
			var angle = anim["start_angle"] + raw_t * 2 * PI
			obj.global_position = anim["center"] + Vector2(cos(angle), sin(angle)) * anim["radius"]
		
		"movement_with_scale":
			obj.global_position = anim["start_pos"].lerp(anim["target"], raw_t)
			obj.scale = anim["start_scale"].lerp(anim["target_scale"], raw_t)
		
		"rotation":
			obj.rotate(anim["speed"] * delta)

		"spread_out_movement":
			# 使用缓动函数来创建加速效果
			var eased_t = ease(raw_t, 2.5) # 调整缓动指数以获得所需的加速效果
			var current_radius = anim["radius"] * eased_t
			var current_angle = anim["start_angle"] + eased_t * PI * 0.25 # 添加一个小的旋转，范围是1/4圈
			obj.global_position = anim["center"] + Vector2(cos(current_angle), sin(current_angle)) * current_radius
			obj.rotation = current_angle + PI / 2 # 使卡片始终垂直于半径
	
	if raw_t >= 1.0:
		_end_animation(obj, anim_type)

func _end_animation(obj: Node, anim_type: String):
	var anim = animated_objects[obj][anim_type]
	anim["active"] = false
	if anim["callback"].is_valid():
		anim["callback"].callv(anim["callback_args"])
	
	# 如果对象没有其他活跃的动画，从字典中移除
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
