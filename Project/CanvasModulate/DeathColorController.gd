extends CanvasModulate



var death_color = "000000"
export var darken_speed = 1;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	color = color.linear_interpolate(death_color, abs(sin((darken_speed*delta*0.5))))
