extends Node2D

var bullet_speed = 150
var bullet_rotation = 10

func _physics_process(delta):
	self.position.x += global.speed * bullet_speed * delta
	self.rotation += global.speed * bullet_rotation * delta

func _on_bullet_area_area_entered(area):
	if area.name == "enemy":
		var particleee = load("res://scenes/particles_square.tscn").instantiate()
		get_parent().add_child(particleee)
		particleee.position = self.position
		particleee.get_child(0).amount = 4
		particleee.get_child(0).emitting = true
		particleee.get_child(0).initial_velocity_min = 20
		particleee.get_child(0).initial_velocity_max = 30
		particleee.get_child(0).gravity.y = 20
		particleee.get_child(0).z_index = 10
		particleee.get_child(0).direction.x = -1
		particleee.get_child(0).direction.y = -1
		self.queue_free()

func _on_timer_timeout():
	self.queue_free()
