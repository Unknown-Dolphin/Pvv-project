extends Node2D

@onready var detection_area = $detection_area
@onready var detection_area_collision = $detection_area/CollisionShape2D
var bullet_speed = 100
var rng = RandomNumberGenerator.new()
var min_dis
var min_area
var hit = 0

func _physics_process(delta):
	min_dis = 10000
	min_area = null
	for area in detection_area.get_overlapping_areas():
		if min_dis > self.position.distance_to(area.get_parent().position) and (area.name == "enemy" or area.name == "enemy_fly"):
			min_dis = self.position.distance_to(area.get_parent().position)
			min_area = area.get_parent().position
	#if min_area != null:
		#print("rotation: " + str(self.rotation))
		#print(self.position.angle_to_point(min_area))
		#print(self.rotation + (PI))
		#print(((-2 * PI) - self.rotation) - self.position.angle_to_point(min_area))
	if min_area != null and self.position.angle_to_point(min_area) > -1.56 and self.rotation > -1.57:
		self.rotation += (self.position.angle_to_point(min_area) - self.rotation) * delta * global.speed * 3
	elif min_area != null and self.position.angle_to_point(min_area) < -1.56 and self.rotation > 0:
		self.rotation += (abs(self.position.angle_to_point(min_area) - (self.rotation - (PI * 2)))) * delta * global.speed * 3
	elif min_area != null and self.position.angle_to_point(min_area) < -1.56 and self.rotation <= 0:
		self.rotation += (self.position.angle_to_point(min_area) - (self.rotation)) * delta * global.speed * 3
	elif min_area != null and self.position.angle_to_point(min_area) > -1.56 and self.rotation <= -1.57:
		self.rotation = self.rotation + (2 * PI)
	self.position += global.speed * bullet_speed * delta * Vector2(cos(self.rotation), sin(self.rotation))
	
	if hit > 1:
		var particleee = load("res://scenes/particles_square.tscn").instantiate()
		get_parent().add_child(particleee)
		particleee.position = self.position
		particleee.get_child(0).color = Color(1, 0.37, 0.37, 1)
		particleee.get_child(0).amount = 3
		particleee.get_child(0).emitting = true
		particleee.get_child(0).initial_velocity_min = 15
		particleee.get_child(0).initial_velocity_max = 25
		particleee.get_child(0).gravity.y = 20
		particleee.get_child(0).z_index = 10
		particleee.get_child(0).direction.x = 0
		particleee.get_child(0).direction.y = 0
		particleee.get_child(0).scale_amount_max = 8
		self.queue_free()

func _on_bullet_area_3_area_entered(area):
	if area.name == "enemy":
		var particleee = load("res://scenes/particles_square.tscn").instantiate()
		get_parent().add_child(particleee)
		particleee.position = self.position
		particleee.get_child(0).color = Color(1, 0.37, 0.37, 1)
		particleee.get_child(0).amount = 3
		particleee.get_child(0).emitting = true
		particleee.get_child(0).initial_velocity_min = 15
		particleee.get_child(0).initial_velocity_max = 25
		particleee.get_child(0).gravity.y = 20
		particleee.get_child(0).z_index = 10
		particleee.get_child(0).direction.x = 0
		particleee.get_child(0).direction.y = 0
		particleee.get_child(0).scale_amount_max = 4
		self.queue_free()
	if area.name == "enemy_fly":
		hit += 1
	
func _on_timer_timeout():
	self.queue_free()

