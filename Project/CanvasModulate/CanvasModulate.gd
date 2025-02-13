extends CanvasModulate


const NIGHT_COLOR = Color("#5c777f")
#const DAY_COLOR = Color ("#ffffff")
#const TIME_SCALE = 0.015

#var time = 0
func _ready():
	pass

func _process(delta:float):
	#time += delta * TIME_SCALE
	color = NIGHT_COLOR
	pass
