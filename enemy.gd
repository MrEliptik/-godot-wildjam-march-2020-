extends KinematicBody2D

signal die(enemy)
signal attack(force)
signal loot(object)

const MID_LIMIT = 50
const LOW_LIMIT = 30
const EXTREME_LIMIT = 15 

var health = 100
var velocity = Vector2(0, 0)
var speed = 40
var attack_force = 20
var dead = false

var target_obj = null
var attack_target = null

var die_anim_finished = false
var die_sound_finished = false

var last_running_sound_pos = 0

enum COLLECTABLES {
	GUN,
	GUN_SUPPRESSED,
	RIFLE,
	MED_KIT,
	AMMO,
	BOMB,
	NOTHING
}

var loot_chance = {
	COLLECTABLES.AMMO: 0.2,
	COLLECTABLES.MED_KIT: 0.15,
	COLLECTABLES.BOMB: 0.05,
	COLLECTABLES.NOTHING: 0.6,
	COLLECTABLES.GUN: 0,
	COLLECTABLES.GUN_SUPPRESSED: 0,
	COLLECTABLES.RIFLE: 0,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	set_health(health)

func _physics_process(delta):
	if die_anim_finished and die_sound_finished:
		emit_signal('die', self)
		# Back to false to prevent multiple signals
		die_anim_finished = false
		die_sound_finished = false
		
	if dead: return
	
	set_health(health)
	if health <= 0:
		emit_signal('loot', random_loot())
		$CollisionPolygon2D.disabled = true
		$Breath.stop()
		$Die.play()
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

func random_loot():
	var obj_res = []
	var selected
	var _max = 0
	for obj in COLLECTABLES.values():
		var chance = randf()*loot_chance[obj]
		if chance > _max:
			_max = chance
			selected = obj
	return selected

func _on_HealthBar_value_changed(value):
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'die':
		die_anim_finished = true

func _on_Die_finished():
	die_sound_finished = true

func _on_Area2D_body_entered(body):
	if body.name == 'Player':
		target_obj = body

func _on_Area2D_body_exited(body):
	target_obj = null

func _on_AttackArea_body_entered(body):
	if body.name == 'Player':
		attack_target = body
		$AttackDelay.start()

func _on_AttackArea_body_exited(body):
	attack_target = null
	$SFX/Attack.stop()

func _on_AttackDelay_timeout():
	if attack_target != null:
		print('Attack')
		emit_signal("attack", attack_force)
		last_running_sound_pos = $SFX/Attack.get_playback_position()
		$SFX/Attack.play(last_running_sound_pos)
		# Attack
		attack_target.health -= attack_force
		# Set cooldown timer for next attack
		$AttackCooldown.start()
		pass

func _on_AttackCooldown_timeout():
	if attack_target != null:
		print('Attack')
		emit_signal("attack", attack_force)
		last_running_sound_pos = $SFX/Attack.get_playback_position()
		$SFX/Attack.play(last_running_sound_pos)
		# Attack
		attack_target.health -= attack_force
		# Set cooldown timer for next attack
		$AttackCooldown.start()
		pass
