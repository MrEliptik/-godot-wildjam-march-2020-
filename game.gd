extends Node2D

const candle = preload('res://candle.tscn')

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.connect('r_click', self, 'on_r_click')

func on_r_click(pos):
	var c = candle.instance()
	c.global_position = pos
	$CandleContainer.add_child(c)
