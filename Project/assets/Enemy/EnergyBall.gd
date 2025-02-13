extends KinematicBody2D

export var SPEED = 100
export var SPEEDUP = 10
export var MAX_RETURNS = 10
onready var hitbox = $Hitbox
onready var animatedSprite = $AnimatedSprite
onready var player= null
onready var golem=get_node("/root/World/YSort/Golem")

var velocity = Vector2.ZERO
var target = Vector2.ZERO
var move = 0
var speed = SPEED
var moving = false
var activated = false
var to_boss = false #Ball direction
var return_counter = 0 #Keeps track of ball returns

signal deleted
signal deflected
signal deflecting
signal vulnerable

func _ready():
	animatedSprite.play("default")
	$ChargeSound.play()
	$Timer.set_wait_time(6)
	$Timer.start()

func _process(delta):
	player=get_node("/root/World/YSort/Player")
	if(activated):
		if(!moving):
			set_velocity(target, speed)
			hitbox.knockbackVector = velocity.normalized()
		else:
			move_and_slide(velocity)
	
	
func set_velocity(velocity, speedup):
	self.velocity = velocity.normalized() * speed
	moving = true
	


func _on_Hurtbox_area_entered(area):
	moving = false
	$Timer.stop()
	$Timer.set_wait_time(2.5)
	$Timer.start()
	if(return_counter == MAX_RETURNS):
		queue_free()
	if(to_boss):
		target = player.position - global_position
		speed += SPEEDUP
		emit_signal("deflected", return_counter)
		set_velocity(target, speed)
		to_boss  = false
		
	else:
		target = golem.position - global_position
		emit_signal("deflecting")
		return_counter += 1
		if(return_counter == MAX_RETURNS):
			emit_signal("vulnerable")
		to_boss = true
		set_velocity(target, speed)


func _on_AnimatedSprite_animation_finished():
	$LaunchSound.play()
	
	if(!activated):
		target = player.position - global_position
	activated = true
	animatedSprite.play("floating")

func _on_Timer_timeout():
		queue_free()
		emit_signal("deleted")


