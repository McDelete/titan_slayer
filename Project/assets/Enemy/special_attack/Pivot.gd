extends Position2D


export var rotation_speed = 5
var beam_rotation = 0


func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		beam_rotation += rotation_speed*delta *0.1
		rotation = beam_rotation
