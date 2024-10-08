extends ColorRect

func _ready():
	material.set_shader_param("blur_amount", 2.0) # 设置初始模糊程度

func set_blur_amount(amount):
	material.set_shader_param("blur_amount", amount)
