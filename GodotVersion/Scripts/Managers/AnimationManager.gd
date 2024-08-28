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

func _update_animation(obj: Node2D, delta: float):
    var anim = animated_objects[obj]
    
    match anim["type"]:
        "linear_movement":
            anim["elapsed_time"] += delta
            var t = min(anim["elapsed_time"] / anim["duration"], 1.0)
            obj.global_position = anim["start_pos"].lerp(anim["target"], t)
            
            if t >= 1.0:
                _end_animation(obj)
        
        "parabolic_movement":
            anim["elapsed_time"] += delta
            var t = min(anim["elapsed_time"] / anim["duration"], 1.0)
            var pos = anim["start_pos"].lerp(anim["target"], t)
            pos.y -= sin(t * PI) * anim["height"]
            obj.global_position = pos
            
            if t >= 1.0:
                _end_animation(obj)

func _end_animation(obj: Node2D):
    animated_objects[obj]["active"] = false

func is_object_animating(obj: Node2D) -> bool:
    return animated_objects.has(obj) and animated_objects[obj]["active"]