extends WorldEnvironment

var transition = self.get_environment().dof_blur_near_transition
var target_transition = 0.1
var unblur = false
export (float) var transition_speed = 5

func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if(unblur == false):
		transition = lerp(transition, target_transition, transition_speed*delta)
		if(transition <= 0.2):
			unblur = true
	else:
		transition = lerp(transition, 5, transition_speed* delta*0.1)
		if(transition >= 4.9):
			queue_free()
	self.environment.dof_blur_near_transition = transition

