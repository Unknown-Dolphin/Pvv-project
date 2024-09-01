extends Node2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var collision = $enemy/CollisionShape2D

var rng = RandomNumberGenerator.new()
var flyspeed = 10
var hit = false
var move = 1
var type
var particle = preload("res://scenes/particles_square.tscn")

func _ready():
	_animated_sprite.play("walk")
	type = rng.randi_range(1, 3)
	match type:
		1: 
			_animated_sprite.modulate = Color(1, 0.4, 0.4, 1)
			get_node("enemy/CollisionShape2D").disabled = true
		2: 
			_animated_sprite.modulate = Color(0.5, 1, 0.5, 1)
			get_node("enemy_fly/CollisionShape2D").disabled = true
		3:
			_animated_sprite.modulate = Color(0.4, 0.6, 1, 1)
			get_node("enemy/CollisionShape2D").disabled = true
	
	var x = rng.randf_range(-9, 9)
	_animated_sprite.position.x += x
	get_node("enemy_fly").position.x += x
	_animated_sprite.position.y += rng.randf_range(-9, 9)

func _physics_process(delta):
	_animated_sprite.speed_scale = global.speed
	if hit:
		global.danger_level += 0.5
		var particleee = particle.instantiate()
		particleee.position = self.position + _animated_sprite.position
		particleee.get_child(0).amount = 6
		match type:
			1: 
				particleee.get_child(0).color = Color(1, 0.43, 0.43, 1)
				particleee.get_child(0).amount = 12
			2: particleee.get_child(0).color = Color(0.5, 1, 0.5, 1)
			3: particleee.get_child(0).color = Color(0.4, 0.6, 1, 1)
		particleee.get_child(0).emitting = true
		particleee.get_child(0).initial_velocity_min = 25
		particleee.get_child(0).initial_velocity_max = 40
		particleee.get_child(0).scale_amount_min = 1
		particleee.get_child(0).scale_amount_max = 4
		particleee.get_child(0).gravity.y = 20
		particleee.get_child(0).z_index = 10
		get_parent().add_child(particleee)
		self.queue_free()
	self.position.x -= global.speed * flyspeed * delta * move
	#match move:
		#0:
			#pass
		#1:
			#_animated_sprite.play("walk")

#func _on_enemy_area_exited(area):
	#if area.name == "hitbox" and move == 0:
		#_animated_sprite.play("walk")
		#move = 1

func _on_enemy_fly_area_entered(area):
	if area.name == "hitbox" and type == 1:
		hit = true
		for i in range(200):
			var ball = load("res://scenes/bad_attack_area.tscn").instantiate()
			ball.position = self.position
			ball.scale.x = 2
			ball.scale.y = 2
			get_parent().add_child(ball)
	if area.name == "bullet_area" and rng.randi_range(1, 10) <= 1:
		hit = true
	elif area.name == "bullet_area2" and rng.randi_range(1, 10) <= 1:
		hit = true
	elif area.name == "bullet_area3":
		hit = true
	elif area.name == "attack_area":
		hit = true

func _on_enemy_area_entered(area):
	if area.name == "bullet_area":
		hit = true
	elif area.name == "bullet_area2":
		hit = true
	elif area.name == "bullet_area3":
		hit = true
	elif area.name == "attack_area":
		hit = true
