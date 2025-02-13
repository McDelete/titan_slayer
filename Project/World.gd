extends "res://Global.gd"


onready var blockadePosition = $YSort/Assets/BlockadePosition
onready var areaTransition = $AreaTransition
onready var blockadeNext = $YSort/Assets/BlockadeNext
onready var  BLOCKADE_PREV= preload("res://assets/Objects/BlockadePrev.tscn")




# Called when the node enters the scene tree for the first time.
func _on_ready():
	
	reset_UI()
	
	._on_ready()
	


	
func reset_UI():
	.reset_UI()
	$BossHearts/HeartUI.set_visible(false)
		
func open_path():
	blockadeNext.queue_free()
func close_path():
	var blockadePrev = BLOCKADE_PREV.instance()
	blockadePrev.position = blockadePosition.position
	call_deferred("add_child", blockadePrev)


func _on_AreaTransition_body_exited(body):
	areaTransition.queue_free()
	close_path()
	


func _on_Golem_died():
	$GolemDeathSFX.play()
	open_path()


func _on_Golem_in_fight():
	$BossHearts/HeartUI.set_visible(true)


func _on_EndTransition_body_exited(body):
	BossStats.reset()
	PlayerStats.reset()
	PlayerTransitionState.reset()
