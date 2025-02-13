extends Control


var opacity = 0
var fadeIn = true
var active = false

func _ready():
	modulate = Color(1,1,1,opacity)

func _process(delta):
	if(active):
		if(fadeIn):
			fade_in()
		else:
			fade_out()
		modulate = Color(1,1,1,opacity)
	

func fade_in():
	opacity = lerp (opacity, 1, 0.2)

	
	
func fade_out():	
	opacity = lerp (opacity, 0, 0.02)
	if(opacity == 0):
		queue_free()

func activate():
	active = true
	$Timer.start()
	
func _on_Timer_timeout():
	fadeIn = false
	$Timer.stop()
