extends Control

const bullet_color = preload('res://art/objects/bullet.png')
const bullet_bw = preload('res://art/objects/bullet_bw.png')
const heart = preload('res://art/objects/heart.png')
const bomb = preload('res://art/objects/bomb.png')
const ammo = preload('res://art/objects/ammo.png')
const gun = preload('res://art/objects/gun.png')

const MID_LIMIT = 50
const LOW_LIMIT = 30
const EXTREME_LIMIT = 15 

enum ICONS {
	HEART,
	AMMO,
	GUN,
	BOMB
}

var icon_dict = {
	ICONS.HEART: heart,
	ICONS.AMMO: ammo,
	ICONS.GUN: gun,
	ICONS.BOMB: bomb
}

var notif_queue = Array()

onready var bullet_max = $Bullets/HBoxContainer.get_child_count()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	pass
	
func process_next():
	if notif_queue.empty() or $AnimationPlayer.is_playing(): return
	var msg = notif_queue.pop_front()
	display_notif(msg[0], msg[1])

func display_notif(msg, icon):
	$HBoxContainer/Icon.texture = icon_dict[icon]
	$HBoxContainer/Notification.text = msg
	$AnimationPlayer.play("notif_appear")
	$Timer.start()

func set_notification(msg, icon):
	notif_queue.append([msg, icon])
	process_next()
	
func update_bullet(bullet):
	for i in range(bullet):
		get_node('Bullets/HBoxContainer/TextureRect' + str(i)).texture = bullet_color
	for i in range(bullet_max - bullet):
		get_node('Bullets/HBoxContainer/TextureRect' + str(i)).texture = bullet_bw
		
func update_bomb(bomb):
	$BombContainer/HBoxContainer3/BombNb.text = str(bomb)

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

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'notif_disappear':
		process_next()
