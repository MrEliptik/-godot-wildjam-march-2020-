extends Control

signal restart

const normal_cursor = preload('res://art/crosshair.png')
const hit_cursor = preload('res://art/crosshair_hit.png')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#Input.set_custom_mouse_cursor(hit_cursor, CURSOR_POINTING_HAND)

func _on_Button_mouse_entered():
	Input.set_custom_mouse_cursor(hit_cursor)

func _on_Button_mouse_exited():
	Input.set_custom_mouse_cursor(normal_cursor)

func _on_Button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_Button2_pressed():
	get_tree().quit()
