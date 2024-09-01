extends Node2D
@onready var _animated_sprite = $AnimatedSprite2D
@onready var timer = $Timer
@onready var time_up = $time_up
@onready var sun_timer = $sun_timer
@onready var timer_bar = $timer_bar/TextureProgressBar
@onready var time_up_bar = $time_up_bar/TextureProgressBar
@onready var health_bar = $health_bar/TextureProgressBar
@onready var hitbox = $hitbox

@export var state = 0
var last_state = 0
var dead = false
var power_up = 0
var sun_time = false
var color_up = 240
var particle = preload("res://scenes/particles_square.tscn")

func _ready():
	health_bar.value = 100
	timer_bar.visible = false
	time_up_bar.visible = false
	time_up_bar.max_value = 183
	time_up_bar.tint_under = Color(0, 0, 0, 1)
	time_up_bar.tint_progress = Color(0.1, 0.75, 0.9, 1)

func bullet(num):
	for i in range(num):
		var bullet1 = load("res://scenes/spike_bullet.tscn").instantiate()
		bullet1.position = self.position + (Vector2(cos(2 * PI/num * (i - 3)), sin(2 * PI/num * (i - int(num/2)))) * 12)
		bullet1.rotation = 2 * PI/num * (i - int(num/2))
		bullet1.position.y -= 8
		bullet1.scale /= 2
		get_parent().add_child(bullet1)

func particle_effect(amount, ini_min, ini_max, gravity_y, z_in, color):
	var particleee = particle.instantiate()
	particleee.position.y += 6
	particleee.get_child(0).color = color
	add_child(particleee)
	particleee.get_child(0).amount = amount
	particleee.get_child(0).emitting = true
	particleee.get_child(0).initial_velocity_min = ini_min
	particleee.get_child(0).initial_velocity_max = ini_max
	particleee.get_child(0).gravity.y = gravity_y
	particleee.get_child(0).z_index = z_in

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
		particle_effect(4, 9, 12, 10, 10, Color(1, 0.37, 0.37, 1))
	elif state == 1:
		timer.wait_time = 20
		timer.start()
		last_state = state
		timer_bar.visible = true
		_animated_sprite.play("mini_idle")
		particle_effect(7, 22, 30, 20, 10, Color(1, 0.37, 0.37, 1))
	elif state == 2:
		#timer.start()
		timer_bar.visible = true
		if last_state != 3:
			particle_effect(10, 40, 55, 30, -7, Color(1, 0.37, 0.37, 1))
		last_state = state
		sun_timer.wait_time = 20
		sun_timer.start()
		_animated_sprite.stop()
		_animated_sprite.play("idle")
		time_up.wait_time = 183
		time_up.start()
		time_up_bar.visible = true
	elif state > 2:
		last_state = state
		power_up += 1
	
	if state == 1:
		timer.start(timer.time_left - (delta * (global.speed - 1)))
		if timer.time_left < 1:
			timer.emit_signal("timeout")
	if state > 1:
		time_up.start(time_up.time_left - (delta * (global.speed - 1)))
		sun_timer.start(sun_timer.time_left - (delta * (global.speed - 1)))
		if time_up.time_left < 0.6:
			time_up.emit_signal("timeout")
		if sun_timer.time_left < 0.6:
			sun_timer.emit_signal("timeout")
	
	if state == 1:
		timer_bar.value = int(timer.time_left * 5)
	elif state == 2:
		timer_bar.value = int(sun_timer.time_left * 5)
	time_up_bar.value = int(time_up.time_left)
	
	
	if sun_time and color_up <= 0:
		particle_effect(10, 40, 55, 30, -7, Color(1, 0.37, 0.37, 1))
		sun_time = false
		var sun_float = load("res://scenes/sun_float.tscn").instantiate()
		sun_float.position = self.position
		_animated_sprite.play("idle")
		get_parent().add_child(sun_float)
		if power_up == 0:
			bullet(6)
		else:
			power_up = 0
			state = 2
			sun_time = false
	
	if sun_time and _animated_sprite.name != "action":
		_animated_sprite.play("action")
	
	if sun_time:
		if self.modulate.r < 1.5:
			self.modulate += Color(0.01, 0.01, 0.01, 0) * global.speed
		color_up -= 5 * global.speed
	elif !sun_time and color_up < 240:
		self.modulate -= Color(0.01, 0.01, 0.01, 0) * global.speed
		color_up += 5 * global.speed
	
	if power_up > 0:
		sun_time = true
		#power_up -= 1
		#state -= 1

func _on_timer_timeout():
	if state == 1:
		state += 1

func _on_hitbox_area_entered(area):
	if area.name == "attack_area_enemy":
			health_bar.value -= 1

func _on_sun_timer_timeout():
	sun_time = true
	sun_timer.wait_time = 20
	sun_timer.start()

func _on_time_up_timeout():
	dead = true
	time_up_bar.visible = false
