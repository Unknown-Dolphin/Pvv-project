extends Node2D

var bullet_speed = 150
var hit = false
var rng = RandomNumberGenerator.new()
var direction

func _physics_process(delta):
	if !hit:
		self.position.x += global.speed * bullet_speed * delta
	else:
		self.position = self.position.move_toward(direction, global.speed * 1.5 * delta * self.position.distance_to(direction))

func _on_bullet_area_2_area_entered(area):
	if area.name == "enemy" and !hit:
		direction = Vector2(self.position.x + rng.randf_range(-20, 50), self.position.y + rng.randf_range(-50, 50))
		hit = true
		var particleee = load("res://scenes/particles_square.tscn").instantiate()
		get_parent().add_child(particleee)
		particleee.position = self.position
		particleee.get_child(0).amount = 3
		particleee.get_child(0).emitting = true
		particleee.get_child(0).initial_velocity_min = 15
		particleee.get_child(0).initial_velocity_max = 25
		particleee.get_child(0).gravity.y = 20
		particleee.get_child(0).z_index = 10
		particleee.get_child(0).direction.x = -1
		particleee.get_child(0).direction.y = -1
		particleee.get_child(0).scale_amount_max = 4
		
	elif area.name == "enemy" and hit:
		var particleee = load("res://scenes/particles_square.tscn").instantiate()
		get_parent().add_child(particleee)
		particleee.position = self.position
		particleee.get_child(0).amount = 3
		particleee.get_child(0).emitting = true
		particleee.get_child(0).initial_velocity_min = 15
		particleee.get_child(0).initial_velocity_max = 25
		particleee.get_child(0).gravity.y = 20
		particleee.get_child(0).z_index = 10
		particleee.get_child(0).direction.x = -1
		particleee.get_child(0).direction.y = -1
		particleee.get_child(0).scale_amount_max = 4
		self.queue_free()

func _on_timer_timeout():
	self.queue_free()

