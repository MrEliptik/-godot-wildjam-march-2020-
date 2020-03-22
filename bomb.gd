extends RigidBody2D

signal explode(bomb)

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play('tick')

func _on_ExplosionTimer_timeout():
	emit_signal('explode', self)
	$Tween.interpolate_property($Light2D, 'energy', 0, 1.5, 0.05, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	$LightTimer.start()
	$AnimationPlayer.play('explosion')
	$Explosion.play()

func _on_LightTimer_timeout():
	$Tween.interpolate_property($Light2D, 'energy', 1.5, 0, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
