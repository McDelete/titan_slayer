extends Node

signal no_health
signal health_changed(value)
signal max_health_changed(value)

export(int) var max_health = 1 setget set_max_health
var health = max_health setget set_health #calls set_health everytime health is updated

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", value)

func set_health(value):
	health = value
	emit_signal("health_changed", value)
	if health <=0:
		emit_signal("no_health") #emits no health signal
	
func _ready():
	reset()
	
func reset():
	self.health = max_health
