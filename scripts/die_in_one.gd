extends Node2D

@onready var partiple = $CPUParticles2D
var timer = 0

func _process(delta):
	partiple.speed_scale = 2 * global.speed
	timer += delta
	if timer > 1:
		self.queue_free()
