extends Node

var timer: Timer
var interval: float = 1.0  # 间隔时间（秒）
var total_calls: int = 5   # 总调用次数
var current_call: int = 0  # 当前调用次数

func _ready():
	start_timed_calls()

func start_timed_calls():
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.set_wait_time(interval)
	timer.set_one_shot(false)  # 设置为重复计时器
	timer.start()
	
	print("开始定时调用")

func _on_timer_timeout():
	current_call += 1
	print("这是第 ", current_call, " 次调用")
	
	if current_call >= total_calls:
		timer.stop()
		timer.queue_free()
		print("定时调用结束")

# 可选：手动停止定时器的函数
func stop_timed_calls():
	if timer:
		timer.stop()
		timer.queue_free()
		print("定时调用被手动停止")
