extends StaticBody2D

onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox/CollisionShape2D
onready var destroyedSound = $DestroyedSFX
	
		
func create_grass_effect():
	sprite.play("Destroyed")
	destroyedSound.play()
	

func _on_Hurtbox_area_entered(area):
	hurtbox.set_deferred("disabled", true)
	$CollisionBox.set_deferred("disabled", true)
	create_grass_effect()


func _on_AnimatedSprite_animation_finished():
	queue_free()
