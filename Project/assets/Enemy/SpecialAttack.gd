class_name SpecialAttack
extends Node2D


export var damage_per_second := 200.0

onready var laser_beam := preload("res://assets/Enemy/Laser.tscn")
onready var shooter := owner

onready var start = $Start
onready var shooting = $Shooting
onready var end = $End

var is_firing := false setget set_is_firing
var collision_mask := 0 setget set_collision_mask


func _ready() -> void:
	set_physics_process(false)
	laser_beam.add_exception(owner)


func _physics_process(delta: float) -> void:
	if laser_beam.is_colliding():
		#add stats here
		pass


func set_is_firing(firing: bool) -> void:
	is_firing = firing

	set_physics_process(is_firing)
	laser_beam.is_casting = is_firing
	if is_firing:
		start.play()
		shooting.play()
		shooting.set_loop(true)
	else:
		shooting.end()
		end.play()


func set_collision_mask(new_mask: int) -> void:
	collision_mask = new_mask
	laser_beam.collision_mask = collision_mask
