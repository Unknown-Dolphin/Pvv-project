extends Node2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var health_bar = $health_bar/TextureProgressBar
@onready var collision = $enemy/CollisionShape2D

var slimespeed = 2
var speed_multiplier = 1
var move = 1
var particle = preload("res://scenes/particles_square.tscn")

func _ready():
	health_bar.value = 100
	_animated_sprite.play("walk")

func _physics_process(delta):
	_animated_sprite.speed_scale = 1 * global.speed
	if health_bar.value <= 0:
		global.danger_level += 1
		global.slime_count += 1
		var particleee = particle.instantiate()
		particleee.position = self.position + get_node("enemy").position
		particleee.get_child(0).color = Color(0.4, 0.6, 1, 1)
		particleee.get_child(0).amount = 10
		particleee.get_child(0).emitting = true
		particleee.get_child(0).initial_velocity_min = 25
		particleee.get_child(0).initial_velocity_max = 40
		particleee.get_child(0).gravity.y = 20
		particleee.get_child(0).z_index = 10
		get_parent().add_child(particleee)
		self.queue_free()
	self.position.x -= global.speed * slimespeed * delta * speed_multiplier * move
	match move:
		0:
			pass
		1:
			_animated_sprite.play("walk")

func _on_area_2d_area_entered(area):
	if area.name == "hitbox" and move == 1:
		_animated_sprite.play("eat")
		move = 0
	if area.name == "bullet_area":
		health_bar.value -= 10
	if area.name == "bullet_area2":
		health_bar.value -= 8
	if area.name == "bullet_area3":
		health_bar.value -= 20
	if area.name == "attack_area" or area.name == "attack_area_vine":
		health_bar.value -= 1

func _on_enemy_area_exited(area):
	if area.name == "hitbox" and move == 0:
		_animated_sprite.play("walk")
		move = 1

func _on_animated_sprite_2d_animation_looped():
	if _animated_sprite.animation == "eat":
		for i in range(20):
			var ball = load("res://scenes/bad_attack_area.tscn").instantiate()
			ball.position += Vector2(-2, 1)
			ball.scale.x = 2
			ball.scale.y = 2
			add_child(ball)
		for i in range(8):
			health_bar.value += 1

func _on_animated_sprite_2d_frame_changed():
	if speed_multiplier < 8:
		speed_multiplier *= 2
	else:
		speed_multiplier = 1
