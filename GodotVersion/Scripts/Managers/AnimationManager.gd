# AnimationManager.gd

# 推荐将此脚本设置为 Autoload (单例)，方便全局调用。
# 操作方法：项目 -> 项目设置 -> Autoload 选项卡
# 添加一个新条目，路径指向此脚本文件，节点名设为 "AnimationManager"
extends Node

class_name AnimationManager

# 动画速度全局缩放因子，已修改为 static
# 现在可以从任何地方通过 AnimationManager.anim_speed_scale 来访问和修改
static var anim_speed_scale: float = 1.0


# --- 核心动画函数 (Async/Await) ---

## 播放一个“属性”动画，这是所有其他动画函数的基础。
## 它可以动画化任何节点的任何属性。
## @obj: 要动画化的节点对象
## @property: 属性名称 (例如 "position", "rotation_degrees", "modulate:a")
## @final_val: 属性的最终值
## @duration: 动画持续时间（秒）
## @trans_type: 动画的过渡类型 (例如 Tween.TRANS_SINE, Tween.TRANS_LINEAR)
## @ease_type: 动画的缓动类型 (例如 Tween.EASE_IN_OUT, Tween.EASE_IN)
## @delay: 动画开始前的延迟时间（秒）
static func play_property(
	obj: Node,
	property: NodePath,
	final_val,
	duration: float,
	trans_type: Tween.TransitionType = Tween.TRANS_SINE,
	ease_type: Tween.EaseType = Tween.EASE_IN_OUT,
	delay: float = 0.0
) -> void:
	# 安全检查：确保对象实例有效
	if not is_instance_valid(obj):
		push_warning("动画目标对象无效，动画已跳过。")
		return

	# 创建一个一次性的 Tween 节点来执行动画
	var tween: Tween = obj.create_tween()
	
	# 【已修正】直接访问静态变量 anim_speed_scale
	tween.set_speed_scale(anim_speed_scale)

	# 将属性动画加入到 Tween 中
	tween.tween_property(obj, property, final_val, duration)\
		.set_trans(trans_type)\
		.set_ease(ease_type)\
		.set_delay(delay)

	# 等待 Tween 完成。这是实现“阻塞式”效果的关键。
	# 当 tween 播放时，调用此函数的代码会暂停在这一行。
	await tween.finished


## 以阻塞方式播放对象的位置移动动画。
## @obj: 需要移动的 Node2D 或 Control 节点
## @target_pos: 目标全局位置
## @duration: 动画持续时间（秒）
## @trans_type: 过渡类型
## @ease_type: 缓动类型
static func play_move(
	obj: Node2D,
	target_pos: Vector2,
	duration: float,
	trans_type: Tween.TransitionType = Tween.TRANS_SINE,
	ease_type: Tween.EaseType = Tween.EASE_IN_OUT
) -> void:
	await play_property(obj, "global_position", target_pos, duration, trans_type, ease_type)


## 以阻塞方式播放对象的旋转动画。
## @obj: 需要旋转的 Node2D 节点
## @target_degrees: 目标角度（单位：度）
## @duration: 动画持续时间（秒）
## @trans_type: 过渡类型
## @ease_type: 缓动类型
static func play_rotate(
	obj: Node2D,
	target_degrees: float,
	duration: float,
	trans_type: Tween.TransitionType = Tween.TRANS_SINE,
	ease_type: Tween.EaseType = Tween.EASE_IN_OUT
) -> void:
	await play_property(obj, "rotation_degrees", target_degrees, duration, trans_type, ease_type)


## 以阻塞方式播放对象的透明度（alpha）动画。
## @obj: 需要改变透明度的 CanvasItem 节点 (例如 Sprite2D, ColorRect, Control)
## @target_alpha: 目标透明度 (0.0 完全透明, 1.0 完全不透明)
## @duration: 动画持续时间（秒）
## @trans_type: 过渡类型
## @ease_type: 缓动类型
static func play_alpha(
	obj: CanvasItem,
	target_alpha: float,
	duration: float,
	trans_type: Tween.TransitionType = Tween.TRANS_LINEAR,
	ease_type: Tween.EaseType = Tween.EASE_IN_OUT
) -> void:
	# "modulate:a" 是一个特殊的属性路径，可以直接动画化 modulate 颜色的 a (alpha) 通道
	await play_property(obj, "modulate:a", clampf(target_alpha, 0.0, 1.0), duration, trans_type, ease_type)


## 以阻塞方式同时播放移动和旋转动画。
## @obj: 需要操作的 Node2D 节点
## @target_pos: 目标全局位置
## @target_degrees: 目标角度（单位：度）
## @duration: 动画持续时间（秒）
## @trans_type: 过渡类型
## @ease_type: 缓动类型
static func play_move_and_rotate(
	obj: Node2D,
	target_pos: Vector2,
	target_degrees: float,
	duration: float,
	trans_type: Tween.TransitionType = Tween.TRANS_SINE,
	ease_type: Tween.EaseType = Tween.EASE_IN_OUT
) -> void:
	if not is_instance_valid(obj):
		push_warning("动画目标对象无效，动画已跳过。")
		return

	# 创建一个 Tween 来并行处理两个动画
	var tween: Tween = obj.create_tween().set_parallel(true)
	
	# 【已修正】直接访问静态变量 anim_speed_scale
	tween.set_speed_scale(anim_speed_scale)

	# 将移动和旋转动画都添加到这个 Tween 中
	tween.tween_property(obj, "global_position", target_pos, duration).set_trans(trans_type).set_ease(ease_type)
	tween.tween_property(obj, "rotation_degrees", target_degrees, duration).set_trans(trans_type).set_ease(ease_type)

	# 等待两个并行执行的动画都完成
	await tween.finished
