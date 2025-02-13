extends Sprite


var opacity = 1

func _process(delta):
	
	opacity = lerp (opacity, 0, 0.2)
	self.modulate = Color(1,1,1,opacity)
	if(opacity == 0):
		queue_free()
