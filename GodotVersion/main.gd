extends Node2D

var ui_start = preload("res://UI/ui_start.tscn")

func _ready():
	# 将UI界面添加到场景中，添加到当前节点的UI节点下
	var ui = ui_start.instantiate()
	var ui_node = get_node("UI")
	ui_node.add_child(ui)
