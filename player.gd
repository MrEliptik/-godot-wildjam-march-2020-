extends KinematicBody2D

signal r_click(pos)
signal hit_enemy(enemy)
signal fired_shot
signal die

export (int) var speed = 150

var velocity = Vector2()
var bullet_impact_pos = Vector2(0, 0)

var close_to_object = false
var bullet = 7
var health = 100
var bomb = 0
var dead = false
var win = false

enum GUN{
	NO,
	GUN,
	GUN_SUPPRESSED,
	RIFLE
}
var current_gun = GUN.NO

enum COLLECTABLES {
	GUN,
	GUN_SUPPRESSED,
	RIFLE,
	MED_KIT,
	AMMO,
	BOMB
}

var gun_node_sfx = {
	GUN.GUN: "Gunshot",
	GUN.GUN_SUPPRESSED: "Gunshot_suppressed",
	GUN.RIFLE: "Gunshot_rifle"
}

var gun_node_sprite = {
	GUN.GUN: "gun",
	GUN.GUN_SUPPRESSED: "silencer",
	GUN.RIFLE: "rifle"
}

var gun_power = {
	GUN.GUN: 100,
	GUN.GUN_SUPPRESSED: 80,
	GUN.RIFLE: 180
}

func _ready():
	pass
	
func _draw():
	#draw_line(global_position, bullet_impact_pos, Color(0.8, 0, 0))
	pass

func get_input():
	look_at(get_global_mouse_position())
	velocity = Vector2()
	if Input.is_action_pressed('ui_down'):
		velocity = Vector2(-speed, 0).rotated(rotation)
	if Input.is_action_pressed('ui_up'):
		velocity = Vector2(speed, 0).rotated(rotation)
	if Input.is_action_pressed('ui_right'):
		velocity = Vector2(0, speed).rotated(rotation)
	if Input.is_action_pressed('ui_left'):
		velocity = Vector2(0, -speed).rotated(rotation)
	if Input.is_action_just_pressed('ui_r_click'):
		if bomb == 0: return
		bomb -= 1
		emit_signal("r_click", get_global_mouse_position())
	if Input.is_action_just_pressed('ui_l_click'):
		if current_gun == GUN.NO: return
		
		if bullet == 0: 
			$Gunshot/Gunshot_empty.play()
			return
		bullet -= 1
		
		get_node('Gunshot/' + gun_node_sfx[current_gun]).play()
		$Particles2D.emitting = true
		
		if $RayCast2D.is_colliding():
			bullet_impact_pos = $RayCast2D.get_collision_point()
			emit_signal("fired_shot", bullet_impact_pos)
			#TODO: Calculate distance and delay impact ?
			var collider = $RayCast2D.get_collider()
			if collider is KinematicBody2D:
				$Gunshot/Impact_body.play()
				emit_signal('hit_enemy', collider)
			elif collider is TileMap:
				$Gunshot/Impact_concrete.play()
			#update()
		

func _physics_process(delta):
	if dead or win: return
	
	get_input()
	
	if health <= 0:
		$AnimationPlayer.play("die")
		emit_signal('die')
		dead = true

	if velocity != Vector2(0, 0) and current_gun == GUN.NO:
		$AnimatedSprite.play("hold_bw")
		var one_is_playing = false
		for footstep in $Footsteps.get_children():
			if footstep.is_playing():
				one_is_playing = true
		if !one_is_playing:
			pass
			#$Footsteps.get_child(randi()%$Footsteps.get_child_count()).play()
	elif current_gun == GUN.GUN:
		$AnimatedSprite.play('gun_bw')
	elif current_gun == GUN.GUN_SUPPRESSED:
		$AnimatedSprite.play('silencer_bw')
	else:
		$AnimatedSprite.play("idle_bw")
		
	if velocity == Vector2(0, 0): $AnimationPlayer.stop()
	else: $AnimationPlayer.play("move")
			
	velocity = move_and_slide(velocity)

func win():
	win = true
	$AnimationPlayer.stop()
	$AnimatedSprite.play('idle')

func on_pickup(object):
	if object == GUN.GUN or object == GUN.GUN_SUPPRESSED or object == GUN.RIFLE:
		current_gun = object
		$Gunshot/Gun_pickup.play()
	elif object == COLLECTABLES.AMMO:
		$Gunshot/Ammo_pickup.play()
		
func take_damage(value):
	$Camera2D.shake(0.4, 10, 5)
	health -= value
	if health < 0: health = 0
	
func take_heal(value):
	health += value
	if health > 100: health = 100
