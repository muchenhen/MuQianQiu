extends Node

class_name GameUtils

var enable_debug_print = true

func muprint(content) -> void:
	if not enable_debug_print:
		return

	print("GameUtils: ", content)
