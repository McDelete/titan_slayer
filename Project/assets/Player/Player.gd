extends KinematicBody2D

export  var ACCELERATION = 500
export  var MAX_SPEED = 80
export  var DASH_SPEED = 300 * 1.5 
export  var FRICTION = 500
export(float)  var DASH_COOLDOWN = 1
export(float)  var DASH_INVINCIBILITY = 0.1

var velocity = Vector2.ZERO
var dash_vector = Vector2.LEFT
var rebound_vector = Vector2.LEFT
var input_vector = Vector2.ZERO
var last_input_vector = input_vector
var canDash = true;
var justHit = true;

var state = MOVE
onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")#gives access to playback property (on/off)
onready var attackSound = $AttackSFX
onready var dashSound = $DashSFX
onready var hitSound = $HitSFX
onready var stats = PlayerStats
onready var hurtbox = $Hurtbox
onready var swordHitbox = $AttackPivot/SwordHitbox
onready var hitAnimationPlayer = $HitAnimationPlayer
onready var dashCooldown = $DashCooldown
onready var dashInvTimer = $DashInvTimer
onready var watchTimer = $WatchTimer

onready var AFTERIMAGE = preload("res://assets/SpriteEffects/Afterimage.tscn")

signal knockback_ended

enum{
	MOVE,
	ATTACK
	DASH
	REBOUND
	KNOCKBACK
	DEATH
	ENTER
	WATCH
}

func _ready():
	stats.connect("no_health", self, "_on_Stats_no_health")
	animationTree.active = true;
	swordHitbox.set_deferred("disabled", true)
	hurtbox.monitoring = true
	self.position = PlayerTransitionState.initial 
	if(PlayerTransitionState.transitioned == 1):
		state = ENTER
	

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state()
		DASH:
			dash_state()
		REBOUND:
			rebound_state(delta)
		KNOCKBACK:
			knockback_state(delta)
		DEATH:
			death_state()
		ENTER: 
			enter_state()
		WATCH:
			watch_state()
		
		
		
func move_state(delta): #Used When moving
	
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	
	if input_vector != Vector2.ZERO:
		dash_vector = input_vector
		rebound_vector = -input_vector
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Walk/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Dash/blend_position", input_vector)
		animationState.travel("Walk")
		last_input_vector = input_vector
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		animationState.travel("Idle")
	move()
	
	if Input.is_action_just_pressed("attack"): #Trigger attack state
		attackSound.play()
		state = ATTACK
	if Input.is_action_just_pressed("dash"): #Trigger dash state
		if(canDash):
			canDash = false;
			hurtbox.monitoring = false
			dashCooldown.set_wait_time(DASH_COOLDOWN)
			dashInvTimer.set_wait_time(DASH_INVINCIBILITY)
			dashCooldown.start()
			dashInvTimer.start()
			dashSound.play()
			state = DASH
	

func attack_state(): #used when attacking
	velocity = Vector2.ZERO 
	animationState.travel("Attack")
	
func dash_state(): #Used when dashing
	velocity = dash_vector * DASH_SPEED
	animationState.travel("Dash")
	afterimage()
	move()

func rebound_state(delta): #used when hitting the Golem/Boss
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	swordHitbox.set_deferred("disabled", true)
	move()
	
func knockback_state(delta):
	if(justHit): #Knockback starts
		hitSound.play()
		justHit = false
	if (velocity == Vector2.ZERO): #Knockback ends
		emit_signal("knockback_ended")
		justHit = true
	var collision = move_and_collide(velocity * delta) #Slowdown process
	if collision:
		var reflect = collision.remainder.bounce(collision.normal)
		velocity = velocity.bounce(collision.normal)
		reflect = move_and_collide(reflect)
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	swordHitbox.set_deferred("disabled", true) #Avoids Bugs

	
func enter_state(): #used when entering new scene
	velocity = MAX_SPEED * PlayerTransitionState.last_transition_vector
	animationTree.set("parameters/Walk/blend_position", PlayerTransitionState.last_transition_vector)
	animationTree.set("parameters/Idle/blend_position", PlayerTransitionState.last_transition_vector)
	animationState.travel("Walk")
	move()
	if(PlayerTransitionState.transitioned == 3):
		state = MOVE
		PlayerTransitionState.transitioned = 0
	 
	
func watch_state():
	velocity = Vector2.ZERO

func move():
	velocity = move_and_slide(velocity) #Moves the player
	
	
func attack_anim_finished():
	state = MOVE
	
func dash_state_finished():
	velocity = Vector2.ZERO
	state = MOVE

func death_state():
	animationState.travel("Death")
	hurtbox.monitoring = false
	


func afterimage():
	var afterimage = AFTERIMAGE.instance()
	afterimage.global_position = global_position + Vector2(0, -13)
	afterimage.texture = sprite.texture
	afterimage.hframes = sprite.hframes
	afterimage.vframes = sprite.vframes
	afterimage.scale = sprite.scale
	afterimage.frame = sprite.frame

	get_tree().get_root().add_child(afterimage)
	
func watch(time): #Called when boss appears (Player stays idle)
	animationState.travel("Idle")
	state = WATCH
	watchTimer.set_wait_time(time)
	watchTimer.start()

#Signals
func _on_SwordHitbox_area_entered(area):
	
	rebound_vector.x = area.reboundX
	rebound_vector.y = area.reboundY
	velocity = -last_input_vector * rebound_vector
	state = REBOUND
	

func _on_Hurtbox_area_entered(area):
	for i in area.damage:
		stats.health -= 1
	hurtbox.start_invincibility()
	
	#var knockback_vector = area.knockbackVector
	var knockback_vector = area.knockbackVector
	var knockback_strength = area.knockback
	velocity = knockback_vector *knockback_strength
	if(state != DEATH):
		state = KNOCKBACK
		

func _on_Stats_no_health():
	state = DEATH



func _on_AreaTransition_body_entered(body):
	state = ENTER

func _on_EndTransition_body_entered(body):
	state = ENTER

func _on_Hurtbox_invincibility_started():
	hitAnimationPlayer.play("Start")



func _on_Hurtbox_invincibility_ended():
	hitAnimationPlayer.play("End")

func _on_DashCooldown_timeout():
	canDash = true;
	dashCooldown.stop()

func _on_DashInvTimer_timeout():
	hurtbox.monitoring = true
	dashInvTimer.stop()

func _on_WatchTimer_timeout():
	state = MOVE
	watchTimer.stop()


func _on_Player_knockback_ended():
	state=MOVE






