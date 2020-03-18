extends KinematicBody2D

signal r_click(pos)
signal fired_shot

export (int) var speed = 200

var velocity = Vector2()

func _ready():
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
		emit_signal("r_click", get_global_mouse_position())
	if Input.is_action_just_pressed('ui_l_click') and $RayCast2D.is_colliding():
		emit_signal("fired_shot", $RayCast2D.get_collision_point())

func _physics_process(delta):
	get_input()

	if velocity != Vector2(0, 0):
		$AnimatedSprite.play("hold")
		var one_is_playing = false
		for footstep in $Footsteps.get_children():
			if footstep.is_playing():
				one_is_playing = true
		if !one_is_playing:
			pass
			#$Footsteps.get_child(randi()%$Footsteps.get_child_count()).play()
	else:
		$AnimatedSprite.play("idle")
		
	if $RayCast2D.is_colliding():
		var enemy = $RayCast2D.get_collider()
		print(enemy)
			
	velocity = move_and_slide(velocity)

