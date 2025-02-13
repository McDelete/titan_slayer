extends Control

func _ready():
	$CenterContainer/VBoxContainer/StartBtn.grab_focus()
	PlayerTransitionState.transitioned = 0


func _on_StartBtn_pressed():
	get_tree().change_scene("res://Overworld.tscn")


func _on_QuitBtn_pressed():
	get_tree().quit()
