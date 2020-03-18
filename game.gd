extends Node2D

const candle = preload('res://candle.tscn')

export var hit_effect: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.connect('r_click', self, 'on_r_click')
	
func _input(event):
	if event is InputEventMouseButton and Input.is_action_just_pressed("ui_l_click"):
		print("Mouse event: ", event.position)
		print("Mouse global: ", get_global_mouse_position())
		print("Mouse viewport: ", get_viewport().get_mouse_position())
	
func _physics_process(delta):	
	# Note: this assumes you are using a action for the mouse.
	# you might need to replace this with a different method to detect
	# whether the mouse has been clicked.
	if (Input.is_action_just_pressed("ui_l_click")):
		pass
		#var mouse_position = get_global_mouse_position()
		#var mouse_position = get_viewport().get_mouse_position()
		#$Player/RayCast2D.set_cast_to(mouse_position)
		
func generate_hit_effect(hit_pos):
	var tmp = hit_effect.instance()
	add_child(tmp)
	tmp.position = hit_pos

func on_r_click(pos):
	var c = candle.instance()
	c.global_position = pos
	$CandleContainer.add_child(c)

func _on_Player_fired_shot(hit_pos):
	generate_hit_effect(hit_pos)
