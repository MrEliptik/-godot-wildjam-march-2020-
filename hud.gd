extends Control

const MID_LIMIT = 50
const LOW_LIMIT = 30
const EXTREME_LIMIT = 15 

onready var bullet_max = $Bullets/HBoxContainer.get_child_count()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_notification(msg):
	$Notification.text = msg
	$AnimationPlayer.play("notif_appear")
	$Timer.start()
	
func update_bullet(bullet):
	for i in range(bullet):
		get_node('Bullets/HBoxContainer/TextureRect' + str(i)).visible = true
	for i in range(bullet_max - bullet):
		get_node('Bullets/HBoxContainer/TextureRect' + str(i)).visible = false

func _on_Timer_timeout():
	$AnimationPlayer.play("notif_disappear")
	
func set_health(value):
	$HealthBar.value = value

func _on_HealthBar_value_changed(value):
	if value > MID_LIMIT:
		$HealthBar.get("custom_styles/fg").bg_color = Color("76ff0d")
	elif value <= MID_LIMIT and value > LOW_LIMIT:
		$HealthBar.get("custom_styles/fg").bg_color = Color("ffcb0d")
	elif value <= LOW_LIMIT and value > EXTREME_LIMIT:
		$HealthBar.get("custom_styles/fg").bg_color = Color("ed601f")
	elif value <= EXTREME_LIMIT:
		$HealthBar.get("custom_styles/fg").bg_color = Color("ed2d1f")
