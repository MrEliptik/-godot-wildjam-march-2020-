extends KinematicBody2D

signal r_click(pos)

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
	if Input.is_action_pressed('ui_r_click'):
		emit_signal("r_click", get_global_mouse_position())

func _physics_process(delta):
	get_input()
	
	
	# Note: this assumes you are using a action for the mouse.
	# you might need to replace this with a different method to detect
	# whether the mouse has been clicked.
	if (Input.is_action_just_pressed("ui_l_click")):
		var mouse_position = get_global_mouse_position()
		$RayCast2D.set_cast_to(mouse_position.rotated(deg2rad(-90)))
		
	if $RayCast2D.is_colliding():
		var enemy = $RayCast2D.get_collider()
			
			
	velocity = move_and_slide(velocity)

