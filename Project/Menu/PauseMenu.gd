extends Control


onready var scene_tree=get_tree()
onready var pause_overlay = $PauseOverlay

var paused := false setget set_paused


	

func _unhandled_input(event: InputEvent):
	
	if event.is_action_pressed("pause"):
		self.paused=not paused
		scene_tree.set_input_as_handled()
		if(self.paused):
			$PauseSFX.play()
		else:
			$UnpauseSFX.play()
	
		
func set_paused(value:bool):
	paused=value
	scene_tree.paused=value
	pause_overlay.visible=value
	$PauseOverlay/Menu/Continue.grab_focus()


func _on_Continue_pressed():
	self.paused=not paused
	$UnpauseSFX.play()


func _on_QuitBtn_pressed():
	get_tree().quit()
