extends Node2D

onready var first = $First
onready var second = $Second
onready var timer = $Timer
export var ROTATION_SPEED = 5
var activated = false
var returning = false
var stay = false
func _ready():
	wait(1.5)



func _process(delta):
	if(activated):
		move(first, 1, delta)
		move(second, -1, delta)
	
func move(node, signature, delta):
	if(returning):
		node.rotation -= ROTATION_SPEED * delta * 0.1 * signature 
	else:
		node.rotation += ROTATION_SPEED * delta * 0.1 * signature 
	if(node.rotation <= 0 or node.rotation >= 180):
		returning = true
		stay = true
		activated = false
		wait(1.5)
	
	
func wait(time):
	timer.set_wait_time(time)
	timer.start()


func _on_Timer_timeout():
	activated = true
	timer.stop()
