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
		if animated_objects[obj].has("active") and animated_objects[obj]["active"]:
			_update_animation(obj, delta)

func start_linear_movement(obj: Node, target: Vector2, duration: float, ease_type: EaseType = EaseType.LINEAR, callback: Callable = Callable(), callback_args: Array = []):
	var start_pos = obj.global_position
	animated_objects[obj] = {
		"type": "linear_movement",
		"start_pos": start_pos,
		"target": target,
		"duration": duration,
		"elapsed_time": 0,
		"active": true,
		"ease_type": ease_type,
		"callback": callback,
		"callback_args": callback_args
	}

func start_parabolic_movement(obj: Node, target: Vector2, height: float, duration: float, callback: Callable = Callable(), callback_args: Array = []):
	var start_pos = obj.global_position
	animated_objects[obj] = {
		"type": "parabolic_movement",
		"start_pos": start_pos,
		"target": target,
		"height": height,
		"duration": duration,
		"elapsed_time": 0,
		"active": true,
		"callback": callback,
		"callback_args": callback_args
	}

func start_circular_movement(obj: Node, center: Vector2, radius: float, start_angle: float, duration: float, callback: Callable = Callable(), callback_args: Array = []):
	animated_objects[obj] = {
		"type": "circular_movement",
		"center": center,
		"radius": radius,
		"start_angle": start_angle,
		"duration": duration,
		"elapsed_time": 0,
		"active": true,
		"callback": callback,
		"callback_args": callback_args
	}

func start_movement_with_scale(obj: Node, target: Vector2, target_scale: Vector2, duration: float, callback: Callable = Callable(), callback_args: Array = []):
	var start_pos = obj.global_position
	var start_scale = obj.scale
	animated_objects[obj] = {
		"type": "movement_with_scale",
		"start_pos": start_pos,
		"target": target,
		"start_scale": start_scale,
		"target_scale": target_scale,
		"duration": duration,
		"elapsed_time": 0,
		"active": true,
		"callback": callback,
		"callback_args": callback_args
	}

func start_rotation(obj: Node, speed: float, duration: float, callback: Callable = Callable(), callback_args: Array = []):
	animated_objects[obj] = {
		"type": "rotation",
		"speed": speed,
		"duration": duration,
		"elapsed_time": 0,
		"active": true,
		"callback": callback,
		"callback_args": callback_args
	}

func start_spread_out_movement(obj: Node, center: Vector2, radius: float, target_angle: float, duration: float, callback: Callable = Callable(), callback_args: Array = []):
	animated_objects[obj] = {
		"type": "spread_out_movement",
		"center": center,
		"radius": radius,
		"start_angle": target_angle,
		"target_angle": target_angle,
		"duration": duration,
		"elapsed_time": 0,
		"active": true,
		"callback": callback,
		"callback_args": callback_args
	}

func _update_animation(obj: Node, delta: float):
	var anim = animated_objects[obj]
	anim["elapsed_time"] += delta
	var raw_t = min(anim["elapsed_time"] / anim["duration"], 1.0)
	
	match anim["type"]:
		"linear_movement":
			var t = _apply_easing(raw_t, anim["ease_type"])
			obj.global_position = anim["start_pos"].lerp(anim["target"], t)
		
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
			var eased_t = ease(raw_t, 2.5)  # 调整缓动指数以获得所需的加速效果
			var current_radius = anim["radius"] * eased_t
			var current_angle = anim["start_angle"] + eased_t * PI * 0.25  # 添加一个小的旋转，范围是1/4圈
			obj.global_position = anim["center"] + Vector2(cos(current_angle), sin(current_angle)) * current_radius
			obj.rotation = current_angle + PI/2  # 使卡片始终垂直于半径
	
	if raw_t >= 1.0:
		_end_animation(obj)

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

func _end_animation(obj: Node):
	animated_objects[obj]["active"] = false
	if animated_objects[obj]["callback"].is_valid():
		animated_objects[obj]["callback"].callv(animated_objects[obj]["callback_args"])

func is_object_animating(obj: Node) -> bool:
	return animated_objects.has(obj) and animated_objects[obj]["active"]
