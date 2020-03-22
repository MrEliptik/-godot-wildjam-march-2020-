extends KinematicBody2D

signal die(enemy)

const MID_LIMIT = 50
const LOW_LIMIT = 30
const EXTREME_LIMIT = 15 

var health = 100
var velocity = Vector2(0, 0)
var speed = 50
var dead = false

var target_obj = null

var die_anim_finished = false
var die_sound_finished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_health(health)

func _physics_process(delta):
	if die_anim_finished and die_sound_finished:
		emit_signal('die', self)
		# Back to false to prevent multiple signals
		die_anim_finished = false
		die_sound_finished = false
		
	if dead: return
	
	set_health(health)
	if health == 0:
		$Breath.stop()
		$SFX/Die.play()
		$HealthBar.visible = false
		$AnimationPlayer.play('die')
		dead = true
		return
		
	if target_obj != null:
		var target = target_obj.global_position - global_position
		look_at(target)
		velocity = target * speed * delta
		
	if velocity != Vector2(0, 0): $AnimationPlayer.play('move')
	else: $AnimationPlayer.play('breath')
	
	velocity = move_and_slide(velocity)

func set_health(value):
	$HealthBar.value = value
	if value > MID_LIMIT:
		$HealthBar.get("custom_styles/fg").bg_color = Color("76ff0d")
	elif value <= MID_LIMIT and value > LOW_LIMIT:
		$HealthBar.get("custom_styles/fg").bg_color = Color("ffcb0d")
	elif value <= LOW_LIMIT and value > EXTREME_LIMIT:
		$HealthBar.get("custom_styles/fg").bg_color = Color("ed601f")
	elif value <= EXTREME_LIMIT:
		$HealthBar.get("custom_styles/fg").bg_color = Color("ed2d1f")

func _on_HealthBar_value_changed(value):
	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'die':
		die_anim_finished = true

func _on_Die_finished():
	die_sound_finished = true


func _on_Area2D_body_entered(body):
	target_obj = body

func _on_Area2D_body_exited(body):
	target_obj = null
