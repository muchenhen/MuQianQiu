extends CanvasLayer

func _ready():
	# 设置BackBufferCopy
	$BackBufferCopy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	
	# 创建并应用着色器材质
	var material = ShaderMaterial.new()
	material.shader = preload("res://Shaders/blur.gdshader")
	$ColorRect.material = material
	
	# ColorRect覆盖整个视口
	$ColorRect.anchor_right = 1
	$ColorRect.anchor_bottom = 1
