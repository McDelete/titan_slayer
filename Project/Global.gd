extends Node2D


onready var player = $YSort/Player
onready var camera = $Camera2D
onready var DEATH_COLOR_CONTROLLER = preload("res://CanvasModulate/DeathColorController.tscn")
onready var TRANSITION_SCREEN = preload("res://CanvasModulate/TransitionAnimation.tscn")
onready var playerStats = PlayerStats
onready var bossStats = BossStats

var initial = Vector2(204,114) #Initial spawn position of player
var enter_vector = Vector2.ZERO #Used to enter area with correct velocity


var deathColorController = null

var smooth_zoom = 0.4
var target_zoom = 0.2
var defaultAudioDB  = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
var audioDB = defaultAudioDB
var death = false;
const ZOOM_SPEED = 0.5
const AUDIO_FADE_SPEED = 0.5
func _ready():
	
	_on_ready()
	

func _on_ready():
	$Music.play()
	playerStats.connect("no_health", self, "_on_Stats_no_health")
	var transition = TRANSITION_SCREEN.instance()
	get_parent().call_deferred("add_child", transition)
	transition.start()
	reset_UI()


func _process(delta):
	
	_on_process(delta)
	
func _on_process(delta):
	if(death):
		death_zoom(delta)
		sound_fade(delta)
	if(death and deathColorController.color.r <= 0.07):
		reset()

func _on_Stats_no_health():
	if(!death):
		deathColorController = DEATH_COLOR_CONTROLLER.instance()
		get_parent().add_child(deathColorController)
		death = true;
	
func sound_fade(delta):
	audioDB = lerp(audioDB, -50, AUDIO_FADE_SPEED *delta)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), audioDB)
	
func death_zoom(delta):
	smooth_zoom = lerp(smooth_zoom, target_zoom, ZOOM_SPEED * delta)
	if smooth_zoom != target_zoom:
		camera.set_zoom(Vector2(smooth_zoom, smooth_zoom))
		
#RESETTERS

func reset_stats():
	playerStats.reset()
	bossStats.reset()
	
func reset_audio():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), defaultAudioDB)
	
func reset_color_controllers():
	deathColorController.queue_free()
	
func reset_transition():
	PlayerTransitionState.transitioned = 1

func reset_UI():
	$UserInterface/HeartUI.set_visible(true)
	
		
		
func reset():
	reset_stats()
	reset_audio()
	reset_color_controllers()
	reset_transition()	
	reset_UI()
	
	get_tree().reload_current_scene()
	

