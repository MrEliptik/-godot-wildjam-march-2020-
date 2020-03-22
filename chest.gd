extends StaticBody2D

signal opened(chest)

onready var opened = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play('closed')

func _on_Area2D_body_entered(body):
	if opened: return
	if body.name != 'Player': return
	$AnimatedSprite.modulate = Color('fcf2c2')
	$AnimatedSprite.play('opened')
	$Open.play()
	opened = true
	emit_signal('opened', self)


func _on_Area2D_body_exited(body):
	if opened: return
	$AnimatedSprite.modulate = Color('ffffff')
