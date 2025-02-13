extends Area2D

export(String, FILE) var next_scene_path = ""
export (Vector2) var player_spawn_location = Vector2.ZERO
export (Vector2) var exit_direction = Vector2.ZERO

onready var transitionScreen = $TransitionScreen
func _ready():
	pass # Replace with function body.




func _on_AreaTransition_body_exited(body):
	if(PlayerTransitionState.transitioned == 1 ):
		
		PlayerTransitionState.initial = player_spawn_location
		transitionScreen.transition()

	if(PlayerTransitionState.transitioned == 2 ):
		PlayerTransitionState.transitioned +=1
	
func _on_AreaTransition_body_entered(body):
	if(PlayerTransitionState.transitioned == 0 ):
		PlayerTransitionState.last_transition_vector = exit_direction
	PlayerTransitionState.transitioned +=1


func _on_TransitionScreen_transitioned():
	
	get_tree().change_scene(next_scene_path)
	
	
	



