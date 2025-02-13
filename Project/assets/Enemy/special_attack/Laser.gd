extends Node2D


const MAX_LENGTH = 2000
onready var beam = $Beam
onready var end = $End
onready var rayCast = $LaserRaycast
onready var lifespan = $Timer
onready var hitbox = $LaserRaycast/Hitbox
onready var hitboxShape = $LaserRaycast/Hitbox/CollisionShape2D

export(float) var seconds_to_live = 1

signal activated

func _ready():
	
	lifespan.set_wait_time(seconds_to_live)
	lifespan.start()
	
	
func _physics_process(delta):

	
	var max_cast_to = MAX_LENGTH * Vector2(1,0).normalized()
	rayCast.cast_to = max_cast_to
	if rayCast.is_colliding():
		end.global_position = rayCast.get_collision_point()
	else:
		end.global_position = rayCast.cast_to
	beam.rotation = rayCast.cast_to.angle()
	beam.region_rect.end.x = end.position.length()
	#hitboxShape.shape.length = end.position.length()

func telegraph(): #Warns the player
	$Beam.set_modulate(Color(0.2,0.2,0.2, 1))
	$LaserRaycast/Hitbox.set_monitorable(false)
	$End/Particles2D.set_visible(false)

func activate(): #Activatges laser
	$Beam.set_modulate(Color(0.08,0.50,0.63, 1))
	$LaserRaycast/Hitbox.set_monitorable(true)
	$End/Particles2D.set_visible(true)
	$LaserSFX.play()
	
func _on_Timer_timeout():
	
	lifespan.stop()
	queue_free()
