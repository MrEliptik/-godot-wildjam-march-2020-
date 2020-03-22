extends Node2D

signal pickup(object)

const candle = preload('res://candle.tscn')

export var hit_effect: PackedScene
export var blood_effect: PackedScene

onready var player = $Player

enum COLLECTABLES {
	GUN,
	GUN_SUPPRESSED,
	RIFLE,
	MED_KIT,
	AMMO
}

var collectables_str = {
	COLLECTABLES.GUN: "Gun",
	COLLECTABLES.GUN_SUPPRESSED: "Silencer",
	COLLECTABLES.RIFLE: "Rifle",
	COLLECTABLES.MED_KIT: "Med kit",
	COLLECTABLES.AMMO: "Ammo"
}

var objects = {
	"Chest_0": [COLLECTABLES.GUN],
	"Chest_1": [COLLECTABLES.AMMO],
	"Chest_2": [COLLECTABLES.GUN],
	"Chest_3": [COLLECTABLES.GUN],
	"Chest_4": [COLLECTABLES.GUN]
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/HUD.set_health(player.health)
	
	player.connect('r_click', self, 'on_r_click')
	player.connect('hit_enemy', self, 'on_enemy_hit')
	connect('pickup', player, 'on_pickup')
	
	for chest in $ChestsContainer.get_children():
		chest.connect('opened', self, 'on_player_chest')
		
	for enemy in $EnemiesContainer.get_children():
		enemy.connect('die', self, 'on_enemy_die')
	
func _input(event):
	if event is InputEventMouseButton and Input.is_action_just_pressed("ui_l_click"):
		pass
		#print("Mouse event: ", event.position)
		#print("Mouse global: ", get_global_mouse_position())
		#print("Mouse viewport: ", get_viewport().get_mouse_position())
	
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
	
func generate_blood_effect(hit_pos):
	var tmp = blood_effect.instance()
	add_child(tmp)
	tmp.position = hit_pos

func on_r_click(pos):
	var c = candle.instance()
	c.global_position = pos
	$CandleContainer.add_child(c)

func _on_Player_fired_shot(hit_pos):
	$CanvasLayer/HUD.update_bullet(player.bullet)
	if not player.get_node('RayCast2D').get_collider() is KinematicBody2D:
		generate_hit_effect(hit_pos)
		var c = candle.instance()
		c.global_position = hit_pos
		$CandleContainer.add_child(c)
	
func on_player_chest(chest):
	print(objects[chest.name])
	chest.disconnect('opened', self, 'on_player_chest')
	var loot = ""
	for obj in objects[chest.name]:
		loot += collectables_str[obj] + " " 
		if obj == COLLECTABLES.GUN:
			emit_signal('pickup', player.GUN.GUN)
			$CanvasLayer/HUD/Bullets.visible = true
		elif obj == COLLECTABLES.GUN_SUPPRESSED:
			emit_signal('pickup', player.GUN.GUN_SUPPRESSED)
			$CanvasLayer/HUD/Bullets.visible = true
		elif obj == COLLECTABLES.RIFLE:
			emit_signal('pickup', player.GUN.RIFLED)
			$CanvasLayer/HUD/Bullets.visible = true	
		elif obj == COLLECTABLES.AMMO:
			emit_signal('pickup', player.COLLECTABLES.AMMO)
			player.bullet = 7
			$CanvasLayer/HUD.update_bullet(player.bullet)
			$CanvasLayer/HUD/Bullets.visible = true
		elif obj == COLLECTABLES.MED_KIT:
			player.health = 100
		
	$CanvasLayer/HUD.set_notification('You got: ' + loot + '!')
	
func on_enemy_hit(enemy):
	enemy.health = enemy.health - player.gun_power[player.current_gun]
	generate_blood_effect(enemy.global_position)

func on_enemy_die(enemy):
	$EnemiesContainer.remove_child(enemy)
