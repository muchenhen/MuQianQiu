extends Node

class_name AnimationManager

var animated_objects = {}

func _process(delta):
	for obj in animated_objects.keys():
		if animated_objects[obj].has("active") and animated_objects[obj]["active"]:
			_update_animation(obj, delta)

func start_linear_movement(obj: Node2D, target: Vector2, duration: float):
	var start_pos = obj.global_position
	animated_objects[obj] = {
		"type": "linear_movement",
		"start_pos": start_pos,
		"target": target,
		"duration": duration,
		"elapsed_time": 0,
		"active": true
	}

func start_parabolic_movement(obj: Node2D, target: Vector2, height: float, duration: float):
	var start_pos = obj.global_position
	animated_objects[obj] = {
		"type": "parabolic_movement",
		"start_pos": start_pos,
		"target": target,
		"height": height,
		"duration": duration,
		"elapsed_time": 0,
		"active": true
	}

func start_circular_movement(obj: Node2D, center: Vector2, radius: float, start_angle: float, duration: float):
	animated_objects[obj] = {
		"type": "circular_movement",
		"center": center,
		"radius": radius,
		"start_angle": start_angle,
		"duration": duration,
		"elapsed_time": 0,
		"active": true
	}

func start_movement_with_scale(obj: Node2D, target: Vector2, target_scale: Vector2, duration: float):
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
		"active": true
	}

func start_rotation(obj: Node2D, speed: float, duration: float):
	animated_objects[obj] = {
		"type": "rotation",
		"speed": speed,
		"duration": duration,
		"elapsed_time": 0,
		"active": true
	}

func start_spread_out_movement(obj: Node2D, center: Vector2, radius: float, target_angle: float, duration: float):
	animated_objects[obj] = {
		"type": "spread_out_movement",
		"center": center,
		"radius": radius,
		"start_angle": target_angle,  # 起始角度就是目标角度，因为我们只想让卡片沿半径方向移动
		"target_angle": target_angle,
		"duration": duration,
		"elapsed_time": 0,
		"active": true
	}

func _update_animation(obj: Node2D, delta: float):
	var anim = animated_objects[obj]
	anim["elapsed_time"] += delta
	var t = min(anim["elapsed_time"] / anim["duration"], 1.0)
	
	match anim["type"]:
		"linear_movement":
			obj.global_position = anim["start_pos"].lerp(anim["target"], t)
		
		"parabolic_movement":
			var pos = anim["start_pos"].lerp(anim["target"], t)
			pos.y -= sin(t * PI) * anim["height"]
			obj.global_position = pos
		
		"circular_movement":
			var angle = anim["start_angle"] + t * 2 * PI
			obj.global_position = anim["center"] + Vector2(cos(angle), sin(angle)) * anim["radius"]
		
		"movement_with_scale":
			obj.global_position = anim["start_pos"].lerp(anim["target"], t)
			obj.scale = anim["start_scale"].lerp(anim["target_scale"], t)
		
		"rotation":
			obj.rotate(anim["speed"] * delta)

		"spread_out_movement":
			# 使用缓动函数来创建加速效果
			var eased_t = ease(t, 2.5)  # 调整缓动指数以获得所需的加速效果
			var current_radius = anim["radius"] * eased_t
			var current_angle = anim["start_angle"] + eased_t * PI * 0.25  # 添加一个小的旋转，范围是1/4圈
			obj.global_position = anim["center"] + Vector2(cos(current_angle), sin(current_angle)) * current_radius
			obj.rotation = current_angle + PI/2  # 使卡片始终垂直于半径
	
	if t >= 1.0:
		_end_animation(obj)

func _end_animation(obj: Node2D):
	animated_objects[obj]["active"] = false

func is_object_animating(obj: Node2D) -> bool:
	return animated_objects.has(obj) and animated_objects[obj]["active"]
