extends Node2D

signal pickup(object)
signal damage(value)

const candle = preload('res://candle.tscn')
const bomb = preload('res://bomb.tscn')
const normal_cursor = preload('res://art/crosshair.png')
const hit_cursor = preload('res://art/crosshair_hit.png')
const death_screen = preload('res://scenes/ui/deathScreen.tscn')

const BOMB_DAMAGE = 300
const MED_KIT_HEAL = 50

export var hit_effect: PackedScene
export var blood_effect: PackedScene

onready var player = $Player

enum COLLECTABLES {
	GUN,
	GUN_SUPPRESSED,
	RIFLE,
	MED_KIT,
	AMMO,
	BOMB
}

var collectables_str = {
	COLLECTABLES.GUN: "Gun",
	COLLECTABLES.GUN_SUPPRESSED: "Silencer",
	COLLECTABLES.RIFLE: "Rifle",
	COLLECTABLES.MED_KIT: "Med kit",
	COLLECTABLES.AMMO: "Ammo",
	COLLECTABLES.BOMB: "Bomb"
}

var objects = {
	"Chest_0": [COLLECTABLES.GUN],
	"Chest_1": [COLLECTABLES.AMMO],
	"Chest_2": [COLLECTABLES.BOMB, COLLECTABLES.AMMO],
	"Chest_3": [COLLECTABLES.MED_KIT],
	"Chest_4": [COLLECTABLES.BOMB, COLLECTABLES.AMMO]
}

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(normal_cursor)
	
	$CanvasLayer/HUD.set_health(player.health)
	
	player.connect('r_click', self, 'on_r_click')
	player.connect('hit_enemy', self, 'on_enemy_hit')
	player.connect('die', self, 'on_player_die')
	connect('pickup', player, 'on_pickup')
	
	for chest in $ChestsContainer.get_children():
		chest.connect('opened', self, 'on_player_chest')
		
	for enemy in $EnemiesContainer.get_children():
		enemy.connect('die', self, 'on_enemy_die')
		enemy.connect('attack', self, 'on_enemy_attack')
		enemy.connect('loot', self, 'on_enemy_loot')
		
	for destructable in $DestructableContainer.get_children():
		destructable.connect('destroyed', self, 'on_destructable_destroyed')
	
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
	var b = bomb.instance()
	b.global_position = (player.global_position + player.get_node('BombEmission').position.rotated(player.rotation))
	b.connect('explode', self, 'on_bomb_explode')
	$BombContainer.add_child(b)
	$CanvasLayer/HUD.update_bomb(player.bomb)

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
			$CanvasLayer/HUD.set_notification('+ 1 gun', $CanvasLayer/HUD.ICONS.GUN)
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
			$CanvasLayer/HUD.set_notification('+ 7 bullets', $CanvasLayer/HUD.ICONS.AMMO)
		elif obj == COLLECTABLES.MED_KIT:
			player.health += MED_KIT_HEAL
			if player.health > 100: player.health = 100
			$CanvasLayer/HUD.set_health(player.health)
			$CanvasLayer/HUD.set_notification('+ '+str(MED_KIT_HEAL)+' health' , $CanvasLayer/HUD.ICONS.HEART)
		elif obj == COLLECTABLES.BOMB:
			player.bomb = 3
			$CanvasLayer/HUD.update_bomb(3)
			$CanvasLayer/HUD/BombContainer .visible = true
			$CanvasLayer/HUD.set_notification('+ 3 bombs' , $CanvasLayer/HUD.ICONS.BOMB)

func on_player_die():
	get_tree().paused = true
	$CanvasLayer.add_child(death_screen.instance())

func on_enemy_hit(enemy):
	enemy.health = enemy.health - player.gun_power[player.current_gun]
	generate_blood_effect(enemy.global_position)

func on_enemy_die(enemy):
	$EnemiesContainer.remove_child(enemy)
	
func on_enemy_attack(value):
	$CanvasLayer/HUD.set_health(player.health)
	
func on_enemy_loot(obj):
	if obj == COLLECTABLES.AMMO:
		emit_signal('pickup', player.COLLECTABLES.AMMO)
		player.bullet = 7
		$CanvasLayer/HUD.update_bullet(player.bullet)
		$CanvasLayer/HUD/Bullets.visible = true
		$CanvasLayer/HUD.set_notification('+ 3 bullets', $CanvasLayer/HUD.ICONS.AMMO)
	elif obj == COLLECTABLES.MED_KIT:
		player.health += MED_KIT_HEAL
		if player.health > 100: player.health = 100
		$CanvasLayer/HUD.set_health(player.health)
		$CanvasLayer/HUD.set_notification('+ '+ str(MED_KIT_HEAL) +' health', $CanvasLayer/HUD.ICONS.HEART)
	elif obj == COLLECTABLES.BOMB:
		player.bomb = 3
		$CanvasLayer/HUD.update_bomb(3)
		$CanvasLayer/HUD/BombContainer .visible = true
		$CanvasLayer/HUD.set_notification('+ 3 bombs', $CanvasLayer/HUD.ICONS.BOMB)
	
func on_bomb_explode(bomb):
	for body in bomb.get_node('AreaExplosion').get_overlapping_bodies():
		if body is KinematicBody2D:
			if body.get_parent().name == 'BombContainer': return
			body.health -= BOMB_DAMAGE
			if body.name == 'Player':
				$CanvasLayer/HUD.set_health(player.health)
		if body is StaticBody2D:
			if body.get_parent().name == 'ChestsContainer': return
			body.destroy()

func on_destructable_destroyed(destructable):
	$DestructableContainer.remove_child(destructable)
