extends CanvasLayer

func _process(delta):
	if Input.is_action_just_pressed("hide_show"): 
		visible = not visible
