extends Node2D
@onready var _animated_sprite = $AnimatedSprite2D
@onready var timer = $Timer
@onready var time_up = $time_up
@onready var timer_bar = $timer_bar/TextureProgressBar
@onready var time_up_bar = $time_up_bar/TextureProgressBar
@onready var health_bar = $health_bar/TextureProgressBar
@onready var shoot_range = $shoot_range
@onready var hitbox = $hitbox

@export var state = 0
var last_state = 0
var dead = false
var power_up = 0
var particle = preload("res://scenes/particles_square.tscn")
var found_enemy = false

func particle_effect(amount, ini_min, ini_max, gravity_y, z_in):
	var particleee = particle.instantiate()
	particleee.position.y += 6
	add_child(particleee)
	particleee.get_child(0).amount = amount
	particleee.get_child(0).emitting = true
	particleee.get_child(0).initial_velocity_min = ini_min
	particleee.get_child(0).initial_velocity_max = ini_max
	particleee.get_child(0).gravity.y = gravity_y
	particleee.get_child(0).z_index = z_in

func _ready():
	health_bar.value = 100
	timer_bar.visible = false
	time_up_bar.visible = false
	time_up_bar.max_value = 183
	time_up_bar.tint_under = Color(0, 0, 0, 1)
	time_up_bar.tint_progress = Color(0.1, 0.75, 0.9, 1)

func bullet():
	var bullet1 = load("res://scenes/spike_bullet.tscn").instantiate()
	bullet1.position = self.position + Vector2(10, -7)
	bullet1.scale /= 2
	get_parent().add_child(bullet1)
	var particleee = particle.instantiate()
	particleee.position.y += 6
	add_child(particleee)
	particleee.position += Vector2(14, -12)
	particleee.get_child(0).color = Color(1, 0.37, 0.37, 1)
	particleee.get_child(0).direction.x = 1
	particleee.get_child(0).direction.y = -0.25
	particleee.get_child(0).amount = 2
	particleee.get_child(0).emitting = true
	particleee.get_child(0).initial_velocity_min = 18
	particleee.get_child(0).initial_velocity_max = 30
	particleee.get_child(0).gravity.y = 14
	particleee.get_child(0).z_index = 5
	particleee.get_child(0).scale_amount_max = 3

func _physics_process(delta):
	_animated_sprite.speed_scale = 0.8 * global.speed
	if health_bar.value <= 0:
		dead = true
	elif last_state == state:
		pass
	elif state == 0:
		last_state = state
		_animated_sprite.stop()
		_animated_sprite.play("seed")
		particle_effect(4, 9, 12, 10, 10)
	elif state == 1:
		timer.wait_time = 20
		timer.start()
		last_state = state
		timer_bar.visible = true
		_animated_sprite.stop()
		_animated_sprite.play("mini_idle")
		particle_effect(7, 22, 30, 20, 10)
	elif state == 2:
		if last_state == 1:
			particle_effect(10, 40, 55, 30, -7)
		last_state = state
		_animated_sprite.stop()
		_animated_sprite.play("idle")
		timer_bar.visible = false
		time_up.wait_time = 183
		time_up.start()
		time_up_bar.visible = true
	elif state > 2:
		last_state = state
		power_up += 10
	
	if state == 1:
		timer.start(timer.time_left - (delta * (global.speed - 1)))
		if timer.time_left < 0.6:
			timer.emit_signal("timeout")
	if state > 1:
		time_up.start(time_up.time_left - (delta * (global.speed - 1)))
		if time_up.time_left < 0.6:
			time_up.emit_signal("timeout")
	timer_bar.value = int(timer.time_left * 5)
	time_up_bar.value = int(time_up.time_left)
	
	if power_up == 10:
		_animated_sprite.play("power_up")
	elif power_up == 0 and state > 2:
		state = 2
		_animated_sprite.play("idle")
		return
	
	found_enemy = false
	for area in shoot_range.get_overlapping_areas():
		if area.name == "enemy" or area.name == "enemy_fly":
			found_enemy = true
		if area.name == "enemy" and state == 2 and _animated_sprite.animation != "action":
			_animated_sprite.play("action")
		elif area.name == "enemy_fly" and state == 2 and _animated_sprite.animation != "action":
			_animated_sprite.play("action")
	
	if !found_enemy and _animated_sprite.name != "idle" and state > 1  and power_up < 1:
		_animated_sprite.play("idle")
	
	if get_node("hitbox/CollisionShape2D").disabled:
		get_node("shoot_range/CollisionShape2D").disabled = true
	else:
		get_node("shoot_range/CollisionShape2D").disabled = false

func _on_timer_timeout():
	if state == 1:
		state += 1

func _on_animated_sprite_2d_animation_looped():
	if _animated_sprite.animation == "action":
		bullet()
	if _animated_sprite.animation == "power_up":
		bullet()
		power_up -= 1

func _on_hitbox_area_entered(area):
	if area.name == "attack_area_enemy":
			health_bar.value -= 1

func _on_time_up_timeout():
	dead = true
	time_up_bar.visible = false
