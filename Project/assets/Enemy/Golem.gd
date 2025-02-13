extends KinematicBody2D

onready var sprite = $Sprite
onready var stats = BossStats
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var hitbox = $Hitbox
onready var hurtbox = $Hurtbox
onready var cooldown = $Timer
onready var hitAnimationPlayer = $HitAnimationPlayer
onready var triggerArea = $TriggerArea
onready var bossMusicStart = $BossMusicStart
onready var bossMusicLoop = $BossMusicLoop
onready var nameDrop = $NameDrop
onready var BULLET_SCENE = preload("res://assets/Enemy/Projectile.tscn")
onready var QUAD_BEAM = preload("res://assets/Enemy/special_attack/QuadLaser.tscn")
onready var DUAL_BEAM = preload("res://assets/Enemy/special_attack/DualLaser.tscn")
onready var ENERGY_BALL = preload("res://assets/Enemy/EnergyBall.tscn")
onready var player=get_node("/root/World/YSort/Player")
onready var AFTERIMAGE = preload("res://assets/SpriteEffects/Afterimage.tscn")
onready var GOLEM_DEATH_EFFECT = preload("res://assets/SpriteEffects/GolemDeathEffect.tscn")

export var MELEE_SPEED = 1000
export var FRICTION = 600
var velocity = Vector2.ZERO
var energyBall = null

signal died
signal in_fight

enum{
	APPEARANCE,
	NORMAL,
	RANGED,
	MELEE,
	LUNGE,
	QUAD,
	DUAL,
	BLOCK,
	GLOWING
	LAST
	DEATH
}
var target = null
var state = null
var next_special = DUAL
var special_counter = 0;# used to rotate between normal and special attacks
var crack_opacity = 0;
var ready = false;
var fighting = false;
var tracking = true;
var energyBallExists = false;
var vulnerable = false
var death = false

func _ready():
	sprite.set_frame(83)
	$LargeShadow.set_visible(false)
	stats.connect("no_health", self, "_on_Stats_no_health")
	

	
func fight_state():
	fighting = !fighting
	state = NORMAL
	ready = true
	emit_signal("in_fight")
	
func _physics_process(delta):
	
	
	target = player.position - position
	hitbox.knockbackVector = target.normalized()
	
	
	
	if(ready and death == false and state != LAST):
		
		ready = false;
		if(global_position.x - player.global_position.x > 0): #Golem always looks at player
			sprite.set_flip_h(true)
		else:
			sprite.set_flip_h(false)
			
		if(stats.health == 4):
			state = BLOCK
		elif stats.health< 50 and special_counter >= 3: #Special attacks
			if (next_special == DUAL):
				state=DUAL
				next_special = QUAD
			elif (next_special == QUAD):
				state=QUAD
				next_special = DUAL
			special_counter = 0
		else: # Basic attacks (used based on distance)
			var distance = sqrt(pow(target.x, 2) + pow(target.y, 2)) / 1
			var randomGen = RandomNumberGenerator.new()
			randomGen.randomize()
			var randomInt = randomGen.randi_range(10,100)
			if(distance <= randomInt): # The closer the golem is to the player the more frequent it will launch melee attacks
				state = MELEE
			else:
				state=RANGED
		special_counter += 1

	match state:
		APPEARANCE:
			appearance_state()
		NORMAL:
			normal_state()
		RANGED:
			ranged_attack()
		MELEE:		
			melee_attack()
		LUNGE:
			lunge_state(delta)
		QUAD:
			quad_laser_attack()
		DUAL:
			dual_laser_attack()
		BLOCK:
			block_state()
		GLOWING:
			glowing_state()
		LAST:
			last_state()
		DEATH:
			death_state()
			
func appearance_state():
	animationTree.active = true
	
func normal_state():
	animationState.travel("normal")

func ranged_attack():
	animationState.travel("ranged")
	
func melee_attack():
	animationState.travel("melee")
	
func quad_laser_attack():
	animationState.travel("quad_laser")
	
func dual_laser_attack():
	animationState.travel("quad_laser")
	
func block_state():
	animationState.travel("block")
	
func glowing_state():
	animationState.travel("glowing")

func last_state():
	hurtbox.set_deferred("disable", true)	
	spawn_energy_ball()
	
func death_state():
	animationState.travel("death")
	hitbox.set_deferred("disabled", true)
	hurtbox.set_deferred("disabled", true)
	death = true
	

	
	
	
func lunge_state(delta):
	lunge()
	afterimage()
	if(velocity == Vector2.ZERO):
		melee_cooldown()

#Functions tied to animations in AnimationPlayer
func ability_anim_end():
	ready = false
	state = NORMAL
	cooldown.set_wait_time(2.5)
	cooldown.start()
	

func ranged_charge_end():
	spawn_projectile()
	
func lock_on():
	set_velocity()

func melee_charge_end():
	state = LUNGE
	
func special_charge_end():
	
	ready = false
	var beam = null
	if(state == QUAD):
		beam = QUAD_BEAM.instance()
	elif(state == DUAL):
		beam = DUAL_BEAM.instance()
	spawn_laser(beam)
	state = NORMAL
	
func block_anim_end():
	state = LAST

func appearance_anim_end():
	fight_state()
	
func show_shadow():
	$LargeShadow.set_visible(true)
	
func hide_shadow():
	$LargeShadow.set_visible(false)
	
#Helper Functions
func introduction():
	var blurEffect = preload("res://ScreenEffects/BlurEffect.tscn").instance()
	get_tree().get_root().call_deferred("add_child",blurEffect)
	bossMusicStart.play()
	nameDrop.activate()
	
func spawn_projectile():
	var projectile = BULLET_SCENE.instance()
	if(sprite.flip_h):
		projectile.position=self.position + Vector2(-45,-30)
	else:
		projectile.position=self.position + Vector2(45,-30)
	projectile.player=player 
	get_parent().add_child(projectile)

func spawn_laser(beam):
	beam.position = self.position + Vector2(0, -30)
	get_parent().add_child(beam)
	cooldown.set_wait_time(4)
	cooldown.start()	
	
func spawn_energy_ball():
	if(!energyBallExists):
		hitbox.set_deferred("monitorable", false)
		energyBall = ENERGY_BALL.instance()
		energyBall.position = self.position + Vector2(0,10)
		get_tree().get_root().call_deferred("add_child", energyBall)
		energyBall.connect("deflecting", self, "deflect")
		energyBall.connect("deleted", self, "update_ball_state")
		energyBall.connect("vulnerable",self, "final_hit")
		energyBallExists = true

func update_ball_state():
	energyBallExists = false;

func deflect():
	hitbox.set_deferred("monitorable", true)
	

	
	
func final_hit():
	hurtbox.set_deferred("disable", false)	
	vulnerable = true
	bossMusicLoop.queue_free()

func afterimage():
	var afterimage = AFTERIMAGE.instance()
	if(tracking):
		if(global_position.x - player.global_position.x > 0):
			afterimage.set_flip_h(true)
		else:
			afterimage.set_flip_h(false)
	afterimage.global_position = global_position + Vector2(0, -50)
	afterimage.texture = sprite.texture
	afterimage.hframes = sprite.hframes
	afterimage.vframes = sprite.vframes
	afterimage.scale = sprite.scale
	afterimage.frame = sprite.frame
	
	get_tree().get_root().add_child(afterimage)
	tracking = false
	
func set_velocity():
	if(tracking):
		velocity = MELEE_SPEED * target.normalized()
	

func lunge():
	velocity = velocity.move_toward(Vector2.ZERO, 100)
	move_and_slide(velocity)
	sprite.set_frame(46)	
	
	

func melee_cooldown():
	state = NORMAL
	cooldown.set_wait_time(3.5)
	cooldown.start()
	tracking = true
	ready = false


func death_anim_finished():
	emit_signal("died")
	queue_free()
	var golemDeathEffect = GOLEM_DEATH_EFFECT.instance()
	golemDeathEffect.position = self.position
	get_tree().get_root().call_deferred("add_child", golemDeathEffect)
	


#Signals
func _on_Stats_no_health():
	state = DEATH


func _on_Timer_timeout():
	cooldown.stop()
	ready = true




func _on_Hurtbox_area_entered(area):
	var health_after = stats.health - area.damage
	if(not health_after < 4 or vulnerable):
		$HitSFX.play()
		hurtbox.start_invincibility()
		stats.health -= area.damage
	elif(state == BLOCK or state == LAST):
		$BlockSFX.play()
		
		
		


func _on_Hurtbox_invincibility_started():
	hitAnimationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	hitAnimationPlayer.play("End")



func _on_TriggerArea_body_entered(body):
	state = APPEARANCE
	body.watch(5)#Player stays idle for 4 seconds
	triggerArea.queue_free()


func _on_BossMusicStart_finished():
	bossMusicLoop.play()
	

func _on_BossMusicLoop_finished():
	bossMusicLoop.play()

