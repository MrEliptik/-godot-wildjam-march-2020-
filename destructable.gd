extends StaticBody2D

signal destroyed(destructable)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func destroy():
	$CollisionShape2D.disabled = true
	$Desctrution.play()
	$AnimationPlayer.play('destruct')

func _on_Desctrution_finished():
	emit_signal('destroyed', self)
