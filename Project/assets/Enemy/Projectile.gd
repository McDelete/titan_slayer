extends "res://Hitboxes_and_Hurtboxes/Hitbox.gd"

var move=Vector2.ZERO
var target=Vector2.ZERO
onready var player=get_node("/root/World/YSort/Player")
onready var sprite = $AnimatedSprite
onready var timer = $Timer
onready var hitbox = $CollisionShape2D
onready var trail = $AnimatedSprite/Trail

export var speed=3
export var rotationSpeed = 5
var tracking = true;


func _ready():
	target = player.position - global_position
	sprite.play("default")
	timer.set_wait_time(1)
	timer.start()
	
func _physics_process(delta):
	target = player.position - global_position
	knockbackVector = target.normalized()
	
	if(tracking):
		rotateToTarget(player, delta)
	else:
		chaseTarget(target, delta)
	
	if(position.x>OS.get_window_size().x or position.y > OS.get_window_size().y 
		or position.x <-OS.get_window_size().x or position.y < -OS.get_window_size().y):
			queue_free()

func rotateToTarget(target, delta):
	target = target.position - global_position
	var angleTo = sprite.transform.x.angle_to(target)
	sprite.rotate(sign(angleTo) * min(delta*rotationSpeed, abs(angleTo)))
	$CollisionShape2D.rotate(sign(angleTo) * min(delta*rotationSpeed, abs(angleTo)))

func chaseTarget(target, delta):
	trail.set_emitting(true)
	move=move.move_toward(target, delta)
	move=move.normalized()*speed
	position += move

func _on_Timer_timeout():
	tracking = false;
