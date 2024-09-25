extends Node

class_name AnimationManager

var animated_objects = {}

static var instance: AnimationManager = null

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
	for obj in animated_objects.keys():
		for anim_type in animated_objects[obj].keys():
			if animated_objects[obj][anim_type]["active"]:
				_update_animation(obj, anim_type, delta)

func start_linear_movement_combined(
	obj: Node, 
	target_pos: Vector2, 
	target_rotation: float, 
	duration: float, 
	ease_type: EaseType = EaseType.LINEAR, 
	callback: Callable = Callable(), 
	callback_args: Array = []
):
	_add_animation(obj, "linear_movement_combined", {
		"start_pos": obj.global_position,
		"target_pos": target_pos,
		"start_rotation": obj.rotation,
		"target_rotation": target_rotation,
		"duration": duration,
		"elapsed_time": 0,
		"active": true,
		"ease_type": ease_type,
		"callback": callback,
		"callback_args": callback_args
	})

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
		"linear_movement_combined":
			var t = _apply_easing(raw_t, anim["ease_type"])
			obj.position = anim["start_pos"].lerp(anim["target_pos"], t)
			obj.rotation = lerp_angle(anim["start_rotation"], anim["target_rotation"], t)
			
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
			var eased_t = ease(raw_t, 2.5)
			var current_radius = anim["radius"] * eased_t
			var current_angle = anim["start_angle"] + eased_t * PI * 0.25
			obj.global_position = anim["center"] + Vector2(cos(current_angle), sin(current_angle)) * current_radius
			obj.rotation = current_angle + PI / 2
	
	if raw_t >= 1.0:
		_end_animation(obj, anim_type)

func _end_animation(obj: Node, anim_type: String):
	var anim = animated_objects[obj][anim_type]
	
	# 在动画结束时强制设置最终位置
	match anim_type:
		"linear_movement_combined":
			obj.position = anim["target_pos"]
			obj.rotation = anim["target_rotation"]
		"linear_movement_pos":
			obj.position = anim["target"]
		"linear_movement_rotation":
			obj.rotation = anim["target"]
		"parabolic_movement":
			obj.global_position = anim["target"]
		"circular_movement":
			var final_angle = anim["start_angle"] + 2 * PI
			obj.global_position = anim["center"] + Vector2(cos(final_angle), sin(final_angle)) * anim["radius"]
		"movement_with_scale":
			obj.global_position = anim["target"]
			obj.scale = anim["target_scale"]
		"spread_out_movement":
			var final_angle = anim["start_angle"] + PI * 0.25
			obj.global_position = anim["center"] + Vector2(cos(final_angle), sin(final_angle)) * anim["radius"]
			obj.rotation = final_angle + PI / 2
	
	anim["active"] = false
	if anim["callback"].is_valid():
		anim["callback"].callv(anim["callback_args"])
	
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
