extends Node2D

signal pickup(object)
signal damage(value)

const candle = preload('res://candle.tscn')
const bomb = preload('res://bomb.tscn')
const normal_cursor = preload('res://art/crosshair.png')
const hit_cursor = preload('res://art/crosshair_hit.png')
const death_screen = preload('res://scenes/ui/deathScreen.tscn')
const win_screen = preload('res://scenes/ui/winScreen.tscn')

const BOMB_DAMAGE = 300
const MED_KIT_HEAL = 50

export var hit_effect: PackedScene
export var blood_effect: PackedScene

var hit_count = 0

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
	"Chest_4": [COLLECTABLES.BOMB, COLLECTABLES.AMMO],
	"Chest_5": [COLLECTABLES.AMMO, COLLECTABLES.BOMB],
	"Chest_6": [COLLECTABLES.MED_KIT],
	"Chest_7": [COLLECTABLES.AMMO],
	"Chest_8": [COLLECTABLES.BOMB, COLLECTABLES.MED_KIT],
	"Chest_9": [COLLECTABLES.AMMO, COLLECTABLES.MED_KIT]
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
			player.take_heal(MED_KIT_HEAL)
			$CanvasLayer/HUD.set_health(player.health)
			$CanvasLayer/HUD.set_notification('+ '+str(MED_KIT_HEAL)+' health' , $CanvasLayer/HUD.ICONS.HEART)
		elif obj == COLLECTABLES.BOMB:
			player.bomb = 3
			$CanvasLayer/HUD.update_bomb(3)
			$CanvasLayer/HUD/BombContainer .visible = true
			$CanvasLayer/HUD.set_notification('+ 3 bombs' , $CanvasLayer/HUD.ICONS.BOMB)

func on_player_die():
	$CanvasLayer/HUD.set_health(player.health)
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
		player.take_heal(MED_KIT_HEAL)
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
			if body.name == 'Player':
				player.take_damage(BOMB_DAMAGE)
				$CanvasLayer/HUD.set_health(player.health)
			else: body.health -= BOMB_DAMAGE
		if body is StaticBody2D:
			if body.get_parent().name == 'ChestsContainer': return
			body.destroy()

func on_destructable_destroyed(destructable):
	$DestructableContainer.remove_child(destructable)

func _on_EndArea_body_entered(body):
	if body.name == "Player":
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		player.get_node('BodyLight').enabled = false
		player.get_node('Camera2D').zoom += Vector2(0.2, 0.2)
		player.win()
		$AnimationPlayer.play('end')
		# 18 times - 4 sec pause
		$Hit2.play()
		$Timer.start()
		# 19 - sec pause

func _on_SlowArea_body_entered(body):
	if body.name == 'Player':
		$Hit.play()
		player.speed = 70
		player.get_node('Camera2D').zoom -= Vector2(0.2, 0.2)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'end':
		$CanvasLayer.add_child(win_screen.instance())
		$Hit3.play()
		$CanvasLayer/WinScreen/AnimationPlayer.play('win')
		player.get_node('Camera2D').zoom += Vector2(0.2, 0.2)
		$Timer2.start()

func _on_Timer_timeout():
	hit_count += 1
	$Hit2.play()
	if hit_count < 18:
		$Timer.start()

func _on_Timer2_timeout():
	$Tween.interpolate_property(player.get_node("Camera2D"), 'zoom', player.get_node('Camera2D').zoom, player.get_node('Camera2D').zoom - Vector2(0.6, 0.6), 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
