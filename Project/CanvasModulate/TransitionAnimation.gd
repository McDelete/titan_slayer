extends CanvasLayer

signal transitioned

onready var animationPlayer = $AnimationPlayer

func _ready():
	pass
	
func transition():
	animationPlayer.play("fade_to_black")

func start():
	$AnimationPlayer.play("fade_to_normal")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		emit_signal("transitioned")
		animationPlayer.play("fade_to_normal")
