extends Sprite

onready var charge = $Timer
onready var LASER = preload("res://assets/Enemy/special_attack/Laser.tscn")

export var charge_time = 1
var laser = null

func _ready():
	$SpawnSFX.play()
	charge.set_wait_time(charge_time)
	charge.start()
	laser = LASER.instance()
	laser.rotation = rotation
	laser.telegraph() #Warns through color
	get_parent().call_deferred("add_child", laser)



func _on_Timer_timeout():
	laser.activate()
	charge.stop()
	queue_free()
	
	
