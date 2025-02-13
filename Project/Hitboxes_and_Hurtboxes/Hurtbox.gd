extends Area2D

export var reboundX = 1
export var reboundY = 1
export (float) var inv_duration = 1.0

var invincible = false setget set_invincible

onready var invTimer = $InvincibilityTimer
signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")
		
func start_invincibility():
	self.invincible = true
	invTimer.start(inv_duration)


func _on_InvincibilityTimer_timeout():
	self.invincible = false

#Used to turn collision ON/OFF when invincible
func _on_Hurtbox_invincibility_started():
	set_deferred("monitoring", false)
	


func _on_Hurtbox_invincibility_ended():
	set_deferred("monitoring", true)
	invTimer.stop()
